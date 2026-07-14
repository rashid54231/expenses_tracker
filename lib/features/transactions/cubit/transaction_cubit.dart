import 'package:flutter_bloc/flutter_bloc.dart';
// Path check kar lein: Agar file 'data' folder mein hai toh ye sahi hai
import '../data/transaction_repository.dart';


// --- STATES ---
abstract class TransactionState {}

class TransactionInitial extends TransactionState {}

class TransactionLoading extends TransactionState {}

// DashboardScreen isi state ka intezar kar raha hai
class DashboardDataLoaded extends TransactionState {
  final List<dynamic> transactions;
  final Map<String, double> summary;
  final Map<String, double> categoryData;

  DashboardDataLoaded(this.transactions, this.summary, this.categoryData);
}

class TransactionError extends TransactionState {
  final String message;
  TransactionError(this.message);
}

// --- CUBIT LOGIC ---
class TransactionCubit extends Cubit<TransactionState> {
  final TransactionRepository repository;

  TransactionCubit(this.repository) : super(TransactionInitial());

  // 1. Dashboard ka saara data ek sath load karne ke liye
  Future<void> getDashboardData() async {
    try {
      emit(TransactionLoading());

      final transactions = await repository.getTransactions();
      final summary = await repository.getTransactionSummary();
      final categoryData = await repository.getCategoryData();

      emit(DashboardDataLoaded(transactions, summary, categoryData));
    } catch (e) {
      emit(TransactionError("Data load nahi ho saka: $e"));
    }
  }

  // 2. Transaction DELETE karne ka function (Jo DashboardScreen mang raha hai)
  Future<void> removeTransaction(String id) async {
    try {
      // Repository se delete karein
      await repository.deleteTransaction(id);

      // Delete ke baad dashboard refresh karein taake list se item gayab ho jaye
      await getDashboardData();
    } catch (e) {
      emit(TransactionError("Delete nakam hua: $e"));
    }
  }

  // 3. Nayi transaction ADD karne ke baad refresh karne ke liye
  Future<void> addNewTransaction({
    required double amount,
    required String categoryId,
    required String walletId,
    required String type,
    String? note
  }) async {
    try {
      emit(TransactionLoading()); // Loading dikhaein

      await repository.addTransaction(
          amount: amount,
          categoryId: categoryId,
          walletId: walletId,
          type: type,
          note: note
      );

      // Add hone ke baad dashboard ka naya data mangwayein
      await getDashboardData();
    } catch (e) {
      emit(TransactionError("Transaction add nahi hui: $e"));
    }
  }
}