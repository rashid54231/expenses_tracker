import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/transaction_repository.dart';
import '../../categories/data/category_model.dart'; // Is path ko apne project ke hisab se sahi kar lein

// --- STATES ---
abstract class TransactionState {}

class TransactionInitial extends TransactionState {}
class TransactionLoading extends TransactionState {}

class DashboardDataLoaded extends TransactionState {
  final List<dynamic> transactions;
  final Map<String, double> summary;
  final Map<String, double> categoryData;
  DashboardDataLoaded(this.transactions, this.summary, this.categoryData);
}

// YEH STATE MISSING THI:
class CategoriesLoaded extends TransactionState {
  final List<CategoryModel> categories;
  CategoriesLoaded(this.categories);
}

class TransactionError extends TransactionState {
  final String message;
  TransactionError(this.message);
}

// --- CUBIT LOGIC ---
class TransactionCubit extends Cubit<TransactionState> {
  final TransactionRepository repository;

  TransactionCubit(this.repository) : super(TransactionInitial());

  // 1. Dashboard data fetch karna
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

  // 2. YEH FUNCTION MISSING THA (Categories Load karne ke liye)
  Future<void> fetchUserCategories() async {
    try {
      emit(TransactionLoading());
      final List<CategoryModel> categories = await repository.getAllCategories();
      emit(CategoriesLoaded(categories));
    } catch (e) {
      emit(TransactionError("Categories load nahi ho sakeen: $e"));
    }
  }

  // 3. YEH FUNCTION MISSING THA (Nayi Category Add karne ke liye)
  Future<void> addUserCategory(String name, String type) async {
    try {
      await repository.addNewCategory(name: name, type: type);
      // Category add hone ke baad list refresh karo
      await fetchUserCategories();
    } catch (e) {
      emit(TransactionError("Category save nahi hui: $e"));
    }
  }

  // 4. Transaction delete karna
  Future<void> removeTransaction(String id) async {
    try {
      await repository.deleteTransaction(id);
      await getDashboardData();
    } catch (e) {
      emit(TransactionError("Delete nakam hua: $e"));
    }
  }

  // 5. Transaction add karna
  Future<void> addNewTransaction({
    required double amount,
    required String categoryId,
    required String type,
    String? note
  }) async {
    try {
      emit(TransactionLoading());
      await repository.addTransaction(
          amount: amount,
          categoryId: categoryId,
          type: type,
          note: note
      );
      await getDashboardData();
    } catch (e) {
      emit(TransactionError("Transaction add nahi hui: $e"));
    }
  }
}