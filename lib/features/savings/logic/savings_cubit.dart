import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/savings_model.dart';
import '../data/savings_repository.dart';

abstract class SavingsState {}
class SavingsInitial extends SavingsState {}
class SavingsLoading extends SavingsState {}
class SavingsLoaded extends SavingsState {
  final List<SavingsModel> goals;
  SavingsLoaded(this.goals);
}
class SavingsError extends SavingsState {
  final String message;
  SavingsError(this.message);
}

class SavingsCubit extends Cubit<SavingsState> {
  final SavingsRepository repository;

  SavingsCubit(this.repository) : super(SavingsInitial());

  Future<void> loadGoals() async {
    try {
      emit(SavingsLoading());
      final goals = await repository.getGoals();
      emit(SavingsLoaded(goals));
    } catch (e) {
      emit(SavingsError(e.toString()));
    }
  }

  Future<void> addGoal(SavingsModel goal) async {
    try {
      emit(SavingsLoading());
      await repository.addGoal(goal);
      await loadGoals();
    } catch (e) {
      emit(SavingsError(e.toString()));
    }
  }

  Future<void> updateGoalAmount(String goalId, double amount) async {
    try {
      await repository.updateGoalAmount(goalId, amount);
      await loadGoals();
    } catch (e) {
      emit(SavingsError(e.toString()));
    }
  }

  Future<void> deleteGoal(String goalId) async {
    try {
      await repository.deleteGoal(goalId);
      await loadGoals();
    } catch (e) {
      emit(SavingsError(e.toString()));
    }
  }
}
