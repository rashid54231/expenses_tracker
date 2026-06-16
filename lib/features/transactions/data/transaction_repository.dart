import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../../models/transaction_model.dart';
import '../../../core/services/notification_service.dart';
// Category Model ko import karna mat bhooliye ga
import '../../categories/data/category_model.dart';

class TransactionRepository {
  final _supabase = Supabase.instance.client;
  final _notificationService = NotificationService();

  // --- EXISTING METHODS (No changes here) ---

  Future<List<TransactionModel>> getTransactions() async {
    final response = await _supabase
        .from('transactions')
        .select()
        .order('date', ascending: false)
        .limit(10);
    return (response as List).map((json) => TransactionModel.fromJson(json)).toList();
  }

  Future<List<TransactionModel>> getAllTransactions() async {
    final response = await _supabase
        .from('transactions')
        .select()
        .order('date', ascending: false);
    return (response as List).map((json) => TransactionModel.fromJson(json)).toList();
  }

  Future<Map<String, double>> getTransactionSummary() async {
    final response = await _supabase.from('transactions').select('amount, type');
    double income = 0, expense = 0;
    for (var item in response) {
      double amt = double.tryParse(item['amount'].toString()) ?? 0.0;
      item['type'] == 'income' ? income += amt : expense += amt;
    }
    return {'income': income, 'expense': expense, 'total': income - expense};
  }

  Future<Map<String, double>> getCategoryData() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return {};

    final categories = await _supabase
        .from('categories')
        .select('id, name')
        .eq('user_id', user.id);

    final catMap = <String, String>{};
    for (var c in categories) {
      catMap[c['id']] = c['name'] ?? 'General';
    }

    final response = await _supabase
        .from('transactions')
        .select('amount, category_id')
        .eq('type', 'expense');

    Map<String, double> totals = {};
    for (var item in response) {
      String catId = item['category_id'] ?? '';
      String catName = catMap[catId] ?? 'General';
      double amt = double.tryParse(item['amount'].toString()) ?? 0.0;
      totals[catName] = (totals[catName] ?? 0) + amt;
    }
    return totals;
  }

  Future<Map<String, String>> getCategoryMap() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return {};

    final categories = await _supabase
        .from('categories')
        .select('id, name')
        .eq('user_id', user.id);

    final catMap = <String, String>{};
    for (var c in categories) {
      catMap[c['id']] = c['name'] ?? 'General';
    }
    return catMap;
  }

  Future<void> addTransaction({required double amount, required String categoryId, required String type, String? note}) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    await _supabase.from('transactions').insert({
      'user_id': user.id,
      'amount': amount,
      'category_id': categoryId,
      'type': type,
      'note': note,
      'date': DateTime.now().toIso8601String(),
    });

    if (type == 'expense') await _checkBudgetAlerts(user.id, categoryId);
  }

  Future<void> deleteTransaction(String id) async {
    await _supabase.from('transactions').delete().eq('id', id);
  }

  Future<void> updateTransaction({
    required String id,
    required double amount,
    required String categoryId,
    required String note,
  }) async {
    await _supabase.from('transactions').update({
      'amount': amount,
      'category_id': categoryId,
      'note': note,
      'date': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  // --- NAYE METHODS (CATEGORIES KE LIYE) ---

  // 1. User ki banayi hui categories fetch karne ke liye
  Future<List<CategoryModel>> getAllCategories() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return [];

      final response = await _supabase
          .from('categories')
          .select()
          .eq('user_id', user.id)
          .order('name', ascending: true);

      return (response as List).map((json) => CategoryModel.fromMap(json)).toList();
    } catch (e) {
      throw Exception("Categories load nahi ho sakeen: $e");
    }
  }

  // 2. Nayi Category (Taxi, Food etc.) save karne ke liye
  Future<void> addNewCategory({required String name, required String type}) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      await _supabase.from('categories').insert({
        'user_id': user.id,
        'name': name,
        'type': type, // 'income' ya 'expense'
        'icon_name': 'category', // Default icon abhi ke liye
      });
    } catch (e) {
      throw Exception("Category save nahi ho saki: $e");
    }
  }

  // --- BUDGET LOGIC (No changes) ---

  Future<void> _checkBudgetAlerts(String userId, String categoryId) async {
    try {
      final currentMonth = DateFormat('yyyy-MM').format(DateTime.now());
      final budgetRes = await _supabase.from('budgets').select('limit_amount').eq('user_id', userId).eq('category_id', categoryId).eq('month', currentMonth).maybeSingle();
      if (budgetRes == null) return;

      double limit = double.tryParse(budgetRes['limit_amount'].toString()) ?? 0.0;
      final expenseRes = await _supabase.from('transactions').select('amount').eq('user_id', userId).eq('category_id', categoryId).eq('type', 'expense').gte('date', DateTime(DateTime.now().year, DateTime.now().month, 1).toIso8601String());

      double total = 0;
      for (var item in expenseRes) total += double.tryParse(item['amount'].toString()) ?? 0.0;

      if (total >= limit) {
        await _notificationService.showNotification(title: "🚨 Budget Full!", body: "Limit khatam!");
      } else if (total >= (limit * 0.8)) {
        await _notificationService.showNotification(title: "⚠️ 80% Used", body: "Budget khatam hone wala hai.");
      }
    } catch (e) { print(e); }
  }
}