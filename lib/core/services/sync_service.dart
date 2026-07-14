import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'local_db_service.dart';

class SyncService {
  static final _supabase = Supabase.instance.client;
  static bool _isSyncing = false;

  static void initialize() {
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (results.isNotEmpty && results.first != ConnectivityResult.none) {
        syncNow();
      }
    });
  }

  static Future<bool> isOnline() async {
    final results = await Connectivity().checkConnectivity();
    return results.isNotEmpty && results.first != ConnectivityResult.none;
  }

  static Future<void> syncNow() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final queue = LocalDbService.getSyncQueue();
      if (queue.isEmpty) {
        _isSyncing = false;
        return;
      }

      print('Starting offline sync. Items in queue: ${queue.length}');

      for (var item in queue) {
        final table = item['table'];
        final operation = item['operation'];
        final data = item['data'];

        try {
          if (operation == 'insert') {
            await _supabase.from(table).insert(data);
          } else if (operation == 'update') {
            final id = data['id'];
            if (id != null) {
              await _supabase.from(table).update(data).eq('id', id);
            }
          } else if (operation == 'delete') {
            final id = data['id'];
            if (id != null) {
              await _supabase.from(table).delete().eq('id', id);
            }
          }
        } catch (e) {
          print('Error syncing item $item: $e');
        }
      }

      await LocalDbService.clearSyncQueue();
      print('Sync complete. Queue cleared.');
    } catch (e) {
      print('Fatal error in syncNow: $e');
    } finally {
      _isSyncing = false;
    }
  }
}
