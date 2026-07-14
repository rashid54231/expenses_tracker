class DebtModel {
  final String id;
  final String userId;
  final String personName;
  final double amount;
  final String type; // 'i_owe' or 'they_owe'
  final bool isSettled;
  final DateTime? dueDate;

  DebtModel({
    required this.id,
    required this.userId,
    required this.personName,
    required this.amount,
    required this.type,
    this.isSettled = false,
    this.dueDate,
  });

  factory DebtModel.fromMap(Map<String, dynamic> map) {
    return DebtModel(
      id: map['id'],
      userId: map['user_id'],
      personName: map['person_name'],
      amount: double.tryParse(map['amount'].toString()) ?? 0.0,
      type: map['type'],
      isSettled: map['is_settled'] ?? false,
      dueDate: map['due_date'] != null ? DateTime.parse(map['due_date']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'person_name': personName,
      'amount': amount,
      'type': type,
      'is_settled': isSettled,
      'due_date': dueDate?.toIso8601String().split('T')[0],
    };
  }
}
