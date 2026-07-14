import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'debt_model.dart';
import '../../../core/services/local_db_service.dart';
import '../../../core/services/sync_service.dart';

class DebtRepository {
  final _supabase = Supabase.instance.client;

  Future<List<DebtModel>> getDebts() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    try {
      if (await SyncService.isOnline()) {
        final response = await _supabase
            .from('debts')
            .select()
            .eq('user_id', user.id)
            .order('created_at', ascending: false);
        await LocalDbService.saveDebts((response as List).cast<Map<String, dynamic>>());
      }
    } catch(e) {
      print('Network error, loading debts from cache: $e');
    }
    
    final localData = LocalDbService.getDebts();
    return localData.map((map) => DebtModel.fromMap(map)).toList();
  }

  Future<void> addDebt(DebtModel debt) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    
    var data = debt.toMap();
    data['id'] = debt.id.isEmpty ? const Uuid().v4() : debt.id;
    data['user_id'] = user.id;

    await LocalDbService.addDebtLocal(data);

    if (await SyncService.isOnline()) {
      try {
        await _supabase.from('debts').insert(data);
      } catch(e) {
        await LocalDbService.addToSyncQueue('debts', 'insert', data);
      }
    } else {
      await LocalDbService.addToSyncQueue('debts', 'insert', data);
    }
  }

  Future<void> toggleSettled(String debtId, bool isSettled) async {
    var debts = LocalDbService.getDebts();
    var debt = debts.firstWhere((d) => d['id'] == debtId, orElse: () => {});
    if (debt.isNotEmpty) {
      debt['is_settled'] = isSettled;
      await LocalDbService.addDebtLocal(debt); 
    }

    final data = {'id': debtId, 'is_settled': isSettled};

    if (await SyncService.isOnline()) {
      try {
        await _supabase.from('debts').update({'is_settled': isSettled}).eq('id', debtId);
      } catch(e) {
        await LocalDbService.addToSyncQueue('debts', 'update', data);
      }
    } else {
      await LocalDbService.addToSyncQueue('debts', 'update', data);
    }
  }

  Future<void> deleteDebt(String debtId) async {
    if (await SyncService.isOnline()) {
      try {
        await _supabase.from('debts').delete().eq('id', debtId);
      } catch(e) {
        await LocalDbService.addToSyncQueue('debts', 'delete', {'id': debtId});
      }
    } else {
      await LocalDbService.addToSyncQueue('debts', 'delete', {'id': debtId});
    }
  }
}
