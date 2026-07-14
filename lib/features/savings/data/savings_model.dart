class SavingsModel {
  final String id;
  final String userId;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime? deadline;
  final String color;

  SavingsModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    this.deadline,
    this.color = '#6C63FF',
  });

  factory SavingsModel.fromMap(Map<String, dynamic> map) {
    return SavingsModel(
      id: map['id'],
      userId: map['user_id'],
      name: map['name'],
      targetAmount: double.tryParse(map['target_amount'].toString()) ?? 0.0,
      currentAmount: double.tryParse(map['current_amount'].toString()) ?? 0.0,
      deadline: map['deadline'] != null ? DateTime.parse(map['deadline']) : null,
      color: map['color'] ?? '#6C63FF',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'name': name,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
      'deadline': deadline?.toIso8601String().split('T')[0],
      'color': color,
    };
  }

  double get progressPercentage => targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;
}
