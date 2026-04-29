import '../../notifications/data/notification_service.dart';

class BudgetLogic {

  // Is function ko hum har transaction add karne ke baad call karenge
  static void checkBudgetAlert({
    required double currentSpent,
    required double limit,
    required String categoryName
  }) {
    // 1. Percentage calculate karein
    double percentage = (currentSpent / limit) * 100;

    // 2. 80% se 99% tak Alert (Warning)
    if (percentage >= 80 && percentage < 100) {
      NotificationService.showThresholdAlert(
          categoryName,
          percentage.toInt(),
          isCritical: false
      );
      print("⚠️ WARNING: $categoryName budget is at ${percentage.toInt()}%");
    }

    // 3. 100% ya usse zyada (Critical Alert)
    else if (percentage >= 100) {
      NotificationService.showThresholdAlert(
          categoryName,
          100,
          isCritical: true
      );
      print("🚨 CRITICAL: $categoryName budget exceeded!");
    }
  }
}