import '../../transactions/data/transaction_repository.dart';

class AnalyticsLogic {
  final TransactionRepository _repo = TransactionRepository();

  Future<Map<String, double>> getCategoryData() async {
    final categoryMap = await _repo.getCategoryMap();

    final transactions = await _repo.getAllTransactions();
    Map<String, double> data = {};

    for (var tx in transactions) {
      if (tx.type == 'expense') {
        String catName = categoryMap[tx.categoryId] ?? 'General';
        data[catName] = (data[catName] ?? 0) + tx.amount;
      }
    }
    return data;
  }
}