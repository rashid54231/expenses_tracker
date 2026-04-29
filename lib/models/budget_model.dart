class BudgetModel {
  final String categoryId;
  final double limitAmount;
  final double currentSpent;
  final String? month;

  BudgetModel({
    required this.categoryId,
    required this.limitAmount,
    required this.currentSpent,
    this.month,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      categoryId: json['category_id'] ?? '',
      // --- DATABASE COLUMN 'monthly_limit' ---
      limitAmount: (json['monthly_limit'] as num? ?? 0.0).toDouble(),
      // Agar DB mein current_spent nahi hai to temporary 0.0
      currentSpent: (json['current_spent'] as num? ?? 0.0).toDouble(),
      month: json['month'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category_id': categoryId,
      'monthly_limit': limitAmount, // Match with Supabase Column
      'month': month,
    };
  }

  bool get isNearLimit => limitAmount > 0 && (currentSpent / limitAmount) >= 0.8;

  double get progress => limitAmount > 0 ? (currentSpent / limitAmount).clamp(0.0, 1.0) : 0.0;
}