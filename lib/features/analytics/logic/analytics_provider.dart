import '../../transactions/data/transaction_repository.dart';
import '../../../models/transaction_model.dart';

class AnalyticsLogic {
  final TransactionRepository _repo = TransactionRepository();

  Future<Map<String, double>> getCategoryData() async {
    final transactions = await _repo.getTransactions();
    Map<String, double> data = {};

    for (var tx in transactions) {
      if (tx.type == 'expense') {
        data[tx.categoryId] = (data[tx.categoryId] ?? 0) + tx.amount;
      }
    }
    return data;
  }
}