import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'savings_model.dart';
import '../../../core/services/local_db_service.dart';
import '../../../core/services/sync_service.dart';

class SavingsRepository {
  final _supabase = Supabase.instance.client;

  Future<List<SavingsModel>> getGoals() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    try {
      if (await SyncService.isOnline()) {
        final response = await _supabase
            .from('savings_goals')
            .select()
            .eq('user_id', user.id)
            .order('created_at', ascending: false);
        await LocalDbService.saveSavings((response as List).cast<Map<String, dynamic>>());
      }
    } catch(e) {
      print('Network error, loading savings from cache: $e');
    }
    
    final localData = LocalDbService.getSavings();
    return localData.map((map) => SavingsModel.fromMap(map)).toList();
  }

  Future<void> addGoal(SavingsModel goal) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    
    var data = goal.toMap();
    data['id'] = goal.id.isEmpty ? const Uuid().v4() : goal.id;
    data['user_id'] = user.id;

    await LocalDbService.addSavingLocal(data);

    if (await SyncService.isOnline()) {
      try {
        await _supabase.from('savings_goals').insert(data);
      } catch(e) {
        await LocalDbService.addToSyncQueue('savings_goals', 'insert', data);
      }
    } else {
      await LocalDbService.addToSyncQueue('savings_goals', 'insert', data);
    }
  }

  Future<void> updateGoalAmount(String goalId, double addAmount) async {
    await LocalDbService.addFundsLocal(goalId, addAmount);
    
    // Read new amount
    final savings = LocalDbService.getSavings();
    final saving = savings.firstWhere((s) => s['id'] == goalId, orElse: () => {});
    if (saving.isEmpty) return;
    
    double newAmount = double.tryParse(saving['current_amount'].toString()) ?? 0.0;
    final data = {'id': goalId, 'current_amount': newAmount};

    if (await SyncService.isOnline()) {
      try {
        await _supabase.from('savings_goals').update({'current_amount': newAmount}).eq('id', goalId);
      } catch(e) {
        await LocalDbService.addToSyncQueue('savings_goals', 'update', data);
      }
    } else {
      await LocalDbService.addToSyncQueue('savings_goals', 'update', data);
    }
  }

  Future<void> deleteGoal(String goalId) async {
    // Delete local is not implemented in LocalDbService for savings but we can queue it
    if (await SyncService.isOnline()) {
      try {
        await _supabase.from('savings_goals').delete().eq('id', goalId);
      } catch(e) {
        await LocalDbService.addToSyncQueue('savings_goals', 'delete', {'id': goalId});
      }
    } else {
      await LocalDbService.addToSyncQueue('savings_goals', 'delete', {'id': goalId});
    }
  }
}
