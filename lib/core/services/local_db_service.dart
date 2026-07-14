import 'package:hive_flutter/hive_flutter.dart';

class LocalDbService {
  static const String transactionsBox = 'transactions_box';
  static const String walletsBox = 'wallets_box';
  static const String savingsBox = 'savings_box';
  static const String debtsBox = 'debts_box';
  static const String syncQueueBox = 'sync_queue_box';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(transactionsBox);
    await Hive.openBox(walletsBox);
    await Hive.openBox(savingsBox);
    await Hive.openBox(debtsBox);
    await Hive.openBox(syncQueueBox);
  }

  // --- Transactions ---
  static Box get _txBox => Hive.box(transactionsBox);
  
  static Future<void> saveTransactions(List<Map<String, dynamic>> transactions) async {
    await _txBox.clear();
    for (var tx in transactions) {
      await _txBox.put(tx['id'], tx);
    }
  }

  static Future<void> addTransactionLocal(Map<String, dynamic> tx) async {
    await _txBox.put(tx['id'], tx);
  }

  static Future<void> deleteTransactionLocal(String id) async {
    await _txBox.delete(id);
  }

  static List<Map<String, dynamic>> getTransactions() {
    return _txBox.values.map((e) => Map<String, dynamic>.from(e as Map)).toList()
      ..sort((a, b) {
        DateTime dateA = DateTime.parse(a['date'] ?? DateTime.now().toIso8601String());
        DateTime dateB = DateTime.parse(b['date'] ?? DateTime.now().toIso8601String());
        return dateB.compareTo(dateA); // Descending order
      });
  }

  // --- Wallets ---
  static Box get _walletBox => Hive.box(walletsBox);

  static Future<void> saveWallets(List<Map<String, dynamic>> wallets) async {
    await _walletBox.clear();
    for (var w in wallets) {
      await _walletBox.put(w['id'], w);
    }
  }
  
  static Future<void> addWalletLocal(Map<String, dynamic> wallet) async {
    await _walletBox.put(wallet['id'], wallet);
  }
  
  static Future<void> updateWalletBalanceLocal(String id, double newBalance) async {
    var wallet = _walletBox.get(id);
    if (wallet != null) {
      Map<String, dynamic> w = Map<String, dynamic>.from(wallet);
      w['balance'] = newBalance;
      await _walletBox.put(id, w);
    }
  }

  static List<Map<String, dynamic>> getWallets() {
    return _walletBox.values.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  // --- Savings Goals ---
  static Box get _savingsBox => Hive.box(savingsBox);

  static Future<void> saveSavings(List<Map<String, dynamic>> savings) async {
    await _savingsBox.clear();
    for (var s in savings) {
      await _savingsBox.put(s['id'], s);
    }
  }

  static Future<void> addSavingLocal(Map<String, dynamic> saving) async {
    await _savingsBox.put(saving['id'], saving);
  }

  static Future<void> addFundsLocal(String id, double amount) async {
    var saving = _savingsBox.get(id);
    if (saving != null) {
      Map<String, dynamic> s = Map<String, dynamic>.from(saving);
      s['current_amount'] = (double.tryParse(s['current_amount'].toString()) ?? 0.0) + amount;
      await _savingsBox.put(id, s);
    }
  }

  static List<Map<String, dynamic>> getSavings() {
    return _savingsBox.values.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  // --- Debts ---
  static Box get _debtsBox => Hive.box(debtsBox);

  static Future<void> saveDebts(List<Map<String, dynamic>> debts) async {
    await _debtsBox.clear();
    for (var d in debts) {
      await _debtsBox.put(d['id'], d);
    }
  }

  static Future<void> addDebtLocal(Map<String, dynamic> debt) async {
    await _debtsBox.put(debt['id'], debt);
  }

  static Future<void> payDebtLocal(String id, double amount) async {
    var debt = _debtsBox.get(id);
    if (debt != null) {
      Map<String, dynamic> d = Map<String, dynamic>.from(debt);
      d['paid_amount'] = (double.tryParse(d['paid_amount'].toString()) ?? 0.0) + amount;
      await _debtsBox.put(id, d);
    }
  }

  static List<Map<String, dynamic>> getDebts() {
    return _debtsBox.values.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  // --- Sync Queue ---
  static Box get _syncQueueBox => Hive.box(syncQueueBox);
  
  static Future<void> addToSyncQueue(String table, String operation, Map<String, dynamic> data) async {
    // operation: 'insert', 'update', 'delete', 'rpc'
    await _syncQueueBox.add({
      'table': table,
      'operation': operation,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  static List<Map<String, dynamic>> getSyncQueue() {
    return _syncQueueBox.values.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  static Future<void> clearSyncQueue() async {
    await _syncQueueBox.clear();
  }
}
