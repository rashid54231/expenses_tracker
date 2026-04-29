import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/budget_model.dart';

class BudgetRepository {
  final _supabase = Supabase.instance.client;

  Future<List<BudgetModel>> getBudgets() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];

      final currentMonth = "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}";

      final response = await _supabase
          .from('budgets')
          .select()
          .eq('user_id', userId)
          .eq('month', currentMonth);

      return (response as List).map((e) => BudgetModel.fromJson(e)).toList();
    } catch (e) {
      print("Error fetching budgets: $e");
      return [];
    }
  }

  Future<void> setBudget(String categoryId, double limit) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final currentMonth = "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}";

      // FIX: 'monthly_limit' column use ho raha hai
      await _supabase.from('budgets').upsert({
        'user_id': user.id,
        'category_id': categoryId,
        'monthly_limit': limit,
        'month': currentMonth,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id,category_id,month');

    } catch (e) {
      throw Exception("Budget save nahi hua: $e");
    }
  }

  Future<double?> getCategoryLimit(String categoryId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;

    final currentMonth = "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}";

    final response = await _supabase
        .from('budgets')
        .select('monthly_limit')
        .eq('user_id', userId)
        .eq('category_id', categoryId)
        .eq('month', currentMonth)
        .maybeSingle();

    return response != null ? double.tryParse(response['monthly_limit'].toString()) : null;
  }
}