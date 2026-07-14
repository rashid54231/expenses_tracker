import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/debt_model.dart';
import '../data/debt_repository.dart';

abstract class DebtState {}
class DebtInitial extends DebtState {}
class DebtLoading extends DebtState {}
class DebtLoaded extends DebtState {
  final List<DebtModel> debts;
  DebtLoaded(this.debts);
}
class DebtError extends DebtState {
  final String message;
  DebtError(this.message);
}

class DebtCubit extends Cubit<DebtState> {
  final DebtRepository repository;

  DebtCubit(this.repository) : super(DebtInitial());

  Future<void> loadDebts() async {
    try {
      emit(DebtLoading());
      final debts = await repository.getDebts();
      emit(DebtLoaded(debts));
    } catch (e) {
      emit(DebtError(e.toString()));
    }
  }

  Future<void> addDebt(DebtModel debt) async {
    try {
      emit(DebtLoading());
      await repository.addDebt(debt);
      await loadDebts();
    } catch (e) {
      emit(DebtError(e.toString()));
    }
  }

  Future<void> toggleSettled(String debtId, bool isSettled) async {
    try {
      await repository.toggleSettled(debtId, isSettled);
      await loadDebts();
    } catch (e) {
      emit(DebtError(e.toString()));
    }
  }

  Future<void> deleteDebt(String debtId) async {
    try {
      await repository.deleteDebt(debtId);
      await loadDebts();
    } catch (e) {
      emit(DebtError(e.toString()));
    }
  }
}
