class TransactionModel {
  final String id;
  final double amount;
  final String categoryId;
  final String type;
  final String note;
  final DateTime date;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.categoryId,
    required this.type,
    required this.note,
    required this.date,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      amount: double.parse(json['amount'].toString()),
      categoryId: json['category_id'],
      type: json['type'],
      note: json['note'] ?? "",
      date: DateTime.parse(json['date']),
    );
  }
}