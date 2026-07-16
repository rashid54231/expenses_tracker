import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  final _supabase = Supabase.instance.client;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {},
    );

    if (Platform.isAndroid) {
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestNotificationsPermission();
    }

    _initialized = true;
  }

  Future<void> showLocal({
    required String title,
    required String body,
    int? id,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'expense_tracker_alerts_high_priority',
      'Expense Tracker Alerts',
      channelDescription: 'Budget and spending alerts',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      visibility: NotificationVisibility.public,
      icon: '@mipmap/ic_launcher',
    );

    const details = NotificationDetails(android: androidDetails);
    await _plugin.show(id ?? DateTime.now().millisecondsSinceEpoch, title, body, details);
  }

  Future<void> saveToDatabase({
    required String title,
    required String message,
    required String type,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    await _supabase.from('notifications').insert({
      'user_id': user.id,
      'title': title,
      'message': message,
      'type': type,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> sendAlert({
    required String title,
    required String body,
    required String type,
  }) async {
    await showLocal(title: title, body: body);
    await saveToDatabase(title: title, message: body, type: type);
  }

  Future<bool> hasRecentAlert(String type) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return false;

    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1).toIso8601String();

    final existing = await _supabase
        .from('notifications')
        .select('id')
        .eq('user_id', user.id)
        .eq('type', type)
        .gte('created_at', startOfMonth)
        .limit(1);

    return existing.isNotEmpty;
  }

  Future<void> checkIncomeExpenseAlert() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1).toIso8601String();

    final transactions = await _supabase
        .from('transactions')
        .select('amount, type')
        .eq('user_id', user.id)
        .gte('date', startOfMonth);

    double totalIncome = 0;
    double totalExpense = 0;

    for (var tx in transactions) {
      double amt = double.tryParse(tx['amount'].toString()) ?? 0.0;
      if (tx['type'] == 'income') {
        totalIncome += amt;
      } else {
        totalExpense += amt;
      }
    }

    if (totalIncome <= 0) return;

    double ratio = (totalExpense / totalIncome) * 100;
    int percent = ratio.toInt();
    int remaining = 100 - percent;
    double leftAmount = totalIncome - totalExpense;

    if (percent >= 100) {
      if (await hasRecentAlert('income_expense_critical')) return;

      await sendAlert(
        title: "🚨 Income Exhausted!",
        body: "You've spent Rs.${totalExpense.toStringAsFixed(0)} which is $percent% of your Rs.${totalIncome.toStringAsFixed(0)} income. You've gone over budget by Rs.${(totalExpense - totalIncome).toStringAsFixed(0)}!",
        type: 'income_expense_critical',
      );
    } else if (percent >= 80) {
      if (await hasRecentAlert('income_expense_warning')) return;

      await sendAlert(
        title: "⚠️ Low Savings - Only $remaining% Left",
        body: "Your save rate has dropped to $remaining%. You have Rs.${leftAmount.toStringAsFixed(0)} remaining from your Rs.${totalIncome.toStringAsFixed(0)} income. Please spend wisely!",
        type: 'income_expense_warning',
      );
    }
  }
}
