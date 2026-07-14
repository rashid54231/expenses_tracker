import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../models/transaction_model.dart';
import '../../../core/services/notification_service.dart';
import '../../categories/data/category_model.dart';
import '../../../core/services/local_db_service.dart';
import '../../../core/services/sync_service.dart';

class TransactionRepository {
  final _supabase = Supabase.instance.client;
  final _notificationService = NotificationService();

  Future<List<TransactionModel>> getTransactions() async {
    try {
      if (await SyncService.isOnline()) {
        final response = await _supabase
            .from('transactions')
            .select()
            .order('date', ascending: false)
            .limit(10);
        await LocalDbService.saveTransactions((response as List).cast<Map<String, dynamic>>());
      }
    } catch (e) {
      print('Network error, loading from cache: $e');
    }
    
    final localData = LocalDbService.getTransactions();
    return localData.take(10).map((json) => TransactionModel.fromJson(json)).toList();
  }

  Future<List<TransactionModel>> getAllTransactions() async {
    try {
      if (await SyncService.isOnline()) {
        final response = await _supabase
            .from('transactions')
            .select()
            .order('date', ascending: false);
        await LocalDbService.saveTransactions((response as List).cast<Map<String, dynamic>>());
      }
    } catch (e) {
      print('Network error, loading from cache: $e');
    }
    
    final localData = LocalDbService.getTransactions();
    return localData.map((json) => TransactionModel.fromJson(json)).toList();
  }

  Future<Map<String, double>> getTransactionSummary() async {
    final transactions = LocalDbService.getTransactions();
    double income = 0, expense = 0;
    for (var item in transactions) {
      double amt = double.tryParse(item['amount'].toString()) ?? 0.0;
      item['type'] == 'income' ? income += amt : expense += amt;
    }
    return {'income': income, 'expense': expense, 'total': income - expense};
  }

  Future<Map<String, double>> getCategoryData() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return {};

    Map<String, String> catMap = {};
    try {
      if (await SyncService.isOnline()) {
        final categories = await _supabase
            .from('categories')
            .select('id, name')
            .eq('user_id', user.id);
        for (var c in categories) {
          catMap[c['id']] = c['name'] ?? 'General';
        }
      }
    } catch (e) { print(e); }

    final transactions = LocalDbService.getTransactions().where((t) => t['type'] == 'expense');
    Map<String, double> totals = {};
    for (var item in transactions) {
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

    try {
      if (await SyncService.isOnline()) {
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
    } catch (e) { print(e); }
    return {};
  }

  Future<void> addTransaction({required double amount, required String categoryId, required String walletId, required String type, String? note}) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final id = const Uuid().v4();
    final data = {
      'id': id,
      'user_id': user.id,
      'amount': amount,
      'category_id': categoryId,
      'wallet_id': walletId,
      'type': type,
      'note': note,
      'date': DateTime.now().toIso8601String(),
    };

    await LocalDbService.addTransactionLocal(data);
    
    var wallets = LocalDbService.getWallets();
    var wallet = wallets.firstWhere((w) => w['id'] == walletId, orElse: () => {});
    double newBalance = 0.0;
    if (wallet.isNotEmpty) {
      double currentBalance = double.tryParse(wallet['balance'].toString()) ?? 0.0;
      newBalance = type == 'income' ? currentBalance + amount : currentBalance - amount;
      await LocalDbService.updateWalletBalanceLocal(walletId, newBalance);
    }

    if (await SyncService.isOnline()) {
      try {
        await _supabase.from('transactions').insert(data);
        if (wallet.isNotEmpty) {
           await _supabase.from('wallets').update({'balance': newBalance}).eq('id', walletId);
        }
      } catch (e) {
        await LocalDbService.addToSyncQueue('transactions', 'insert', data);
        if (wallet.isNotEmpty) {
           await LocalDbService.addToSyncQueue('wallets', 'update', {'id': walletId, 'balance': newBalance});
        }
      }
    } else {
      await LocalDbService.addToSyncQueue('transactions', 'insert', data);
      if (wallet.isNotEmpty) {
         await LocalDbService.addToSyncQueue('wallets', 'update', {'id': walletId, 'balance': newBalance});
      }
    }

    if (type == 'expense' && await SyncService.isOnline()) {
      await _checkBudgetAlerts(user.id, categoryId);
      await _notificationService.checkIncomeExpenseAlert();
    }
  }

  Future<void> deleteTransaction(String id) async {
    await LocalDbService.deleteTransactionLocal(id);
    if (await SyncService.isOnline()) {
      try {
        await _supabase.from('transactions').delete().eq('id', id);
      } catch (e) {
        await LocalDbService.addToSyncQueue('transactions', 'delete', {'id': id});
      }
    } else {
      await LocalDbService.addToSyncQueue('transactions', 'delete', {'id': id});
    }
  }

  Future<void> updateTransaction({
    required String id,
    required double amount,
    required String categoryId,
    required String note,
  }) async {
    final data = {
      'id': id,
      'amount': amount,
      'category_id': categoryId,
      'note': note,
      'date': DateTime.now().toIso8601String(),
    };
    
    // Update locally - simple approach: delete and insert to keep sorting?
    // We can just rely on fetch if we just want basic support, but let's queue it.
    if (await SyncService.isOnline()) {
      try {
        await _supabase.from('transactions').update(data).eq('id', id);
      } catch (e) {
        await LocalDbService.addToSyncQueue('transactions', 'update', data);
      }
    } else {
      await LocalDbService.addToSyncQueue('transactions', 'update', data);
    }
  }

  Future<List<CategoryModel>> getAllCategories() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return [];
      if (await SyncService.isOnline()) {
        final response = await _supabase
            .from('categories')
            .select()
            .eq('user_id', user.id)
            .order('name', ascending: true);
        return (response as List).map((json) => CategoryModel.fromMap(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception("Categories load nahi ho sakeen: $e");
    }
  }

  Future<void> addNewCategory({required String name, required String type}) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final data = {
        'id': const Uuid().v4(),
        'user_id': user.id,
        'name': name,
        'type': type,
        'icon_name': 'category',
      };

      if (await SyncService.isOnline()) {
        await _supabase.from('categories').insert(data);
      } else {
        await LocalDbService.addToSyncQueue('categories', 'insert', data);
      }
    } catch (e) {
      throw Exception("Category save nahi ho saki: $e");
    }
  }

  Future<void> _checkBudgetAlerts(String userId, String categoryId) async {
    try {
      final currentMonth = DateFormat('yyyy-MM').format(DateTime.now());
      final budgetRes = await _supabase.from('budgets').select('monthly_limit').eq('user_id', userId).eq('category_id', categoryId).eq('month', currentMonth).maybeSingle();
      if (budgetRes == null) return;

      double limit = double.tryParse(budgetRes['monthly_limit'].toString()) ?? 0.0;
      if (limit <= 0) return;

      final expenseRes = await _supabase.from('transactions').select('amount').eq('user_id', userId).eq('category_id', categoryId).eq('type', 'expense').gte('date', DateTime(DateTime.now().year, DateTime.now().month, 1).toIso8601String());

      double total = 0;
      for (var item in expenseRes) total += double.tryParse(item['amount'].toString()) ?? 0.0;

      final categories = await _supabase.from('categories').select('name').eq('id', categoryId).maybeSingle();
      String catName = categories?['name'] ?? 'this category';

      double percent = (total / limit) * 100;

      if (percent >= 100) {
        if (await _notificationService.hasRecentAlert('budget_exceeded_$categoryId')) return;
        await _notificationService.sendAlert(
          title: "🚨 Budget Exceeded!",
          body: "You've spent Rs.${total.toStringAsFixed(0)} on $catName. Monthly limit of Rs.${limit.toStringAsFixed(0)} is exceeded!",
          type: 'budget_exceeded_$categoryId',
        );
      } else if (percent >= 80) {
        if (await _notificationService.hasRecentAlert('budget_warning_$categoryId')) return;
        await _notificationService.sendAlert(
          title: "⚠️ Budget Warning",
          body: "You've used ${percent.toInt()}% of your $catName budget (Rs.${total.toStringAsFixed(0)} of Rs.${limit.toStringAsFixed(0)}).",
          type: 'budget_warning_$categoryId',
        );
      }
    } catch (e) { print(e); }
  }
}