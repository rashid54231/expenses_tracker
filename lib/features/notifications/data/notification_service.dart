import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        // Yahan click handle hota hai
      },
    );

    if (Platform.isAndroid) {
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestNotificationsPermission();
    }
  }

  static void showThresholdAlert(String category, int percent, {bool isCritical = false}) {
    final String title = isCritical ? "🚨 Budget Exceeded!" : "⚠️ Budget Warning";
    final String body = isCritical
        ? "You have spent 100% of your $category budget!"
        : "Careful! You've used $percent% of your $category budget.";

    const androidDetails = AndroidNotificationDetails(
      'budget_alerts',
      'Budget Notifications',
      channelDescription: 'Alerts for budget limits',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );

    _notifications.show(
        DateTime.now().millisecond,
        title,
        body,
        const NotificationDetails(android: androidDetails)
    );
  }
}