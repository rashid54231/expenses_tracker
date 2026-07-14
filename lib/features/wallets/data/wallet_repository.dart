import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'wallet_model.dart';
import '../../../core/services/local_db_service.dart';
import '../../../core/services/sync_service.dart';

class WalletRepository {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  Future<List<WalletModel>> getWallets() async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) throw Exception("User not logged in");

      if (await SyncService.isOnline()) {
        final response = await _supabaseClient
            .from('wallets')
            .select()
            .eq('user_id', userId)
            .order('created_at', ascending: true);
        await LocalDbService.saveWallets((response as List).cast<Map<String, dynamic>>());
      }
    } catch (e) {
      print('Network error, loading wallets from cache: $e');
    }
    
    final localData = LocalDbService.getWallets();
    return localData.map((json) => WalletModel.fromJson(json)).toList();
  }

  Future<WalletModel> addWallet(String name, String type, double initialBalance) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) throw Exception("User not logged in");

      final id = const Uuid().v4();
      final data = {
        'id': id,
        'user_id': userId,
        'name': name,
        'type': type,
        'balance': initialBalance,
        'created_at': DateTime.now().toIso8601String(),
      };

      await LocalDbService.addWalletLocal(data);

      if (await SyncService.isOnline()) {
        try {
          await _supabaseClient.from('wallets').insert(data);
        } catch (e) {
          await LocalDbService.addToSyncQueue('wallets', 'insert', data);
        }
      } else {
        await LocalDbService.addToSyncQueue('wallets', 'insert', data);
      }

      return WalletModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to add wallet: $e');
    }
  }

  Future<WalletModel> updateWalletBalance(String walletId, double newBalance) async {
    try {
      await LocalDbService.updateWalletBalanceLocal(walletId, newBalance);
      
      final data = {'id': walletId, 'balance': newBalance};
      
      if (await SyncService.isOnline()) {
        try {
          await _supabaseClient.from('wallets').update({'balance': newBalance}).eq('id', walletId);
        } catch(e) {
          await LocalDbService.addToSyncQueue('wallets', 'update', data);
        }
      } else {
        await LocalDbService.addToSyncQueue('wallets', 'update', data);
      }
      
      // Return updated local wallet
      var wallets = LocalDbService.getWallets();
      var walletData = wallets.firstWhere((w) => w['id'] == walletId, orElse: () => data);
      return WalletModel.fromJson(walletData);
    } catch (e) {
      throw Exception('Failed to update wallet balance: $e');
    }
  }
}
