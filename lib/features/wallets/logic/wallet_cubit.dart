import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/wallet_model.dart';
import '../data/wallet_repository.dart';

// --- States ---
abstract class WalletState extends Equatable {
  const WalletState();

  @override
  List<Object> get props => [];
}

class WalletInitial extends WalletState {}

class WalletLoading extends WalletState {}

class WalletLoaded extends WalletState {
  final List<WalletModel> wallets;
  final double totalBalance;

  const WalletLoaded(this.wallets, this.totalBalance);

  @override
  List<Object> get props => [wallets, totalBalance];
}

class WalletError extends WalletState {
  final String error;

  const WalletError(this.error);

  @override
  List<Object> get props => [error];
}

class WalletAddedSuccess extends WalletState {}

// --- Cubit ---
class WalletCubit extends Cubit<WalletState> {
  final WalletRepository _repository;

  WalletCubit(this._repository) : super(WalletInitial());

  Future<void> loadWallets() async {
    emit(WalletLoading());
    try {
      final wallets = await _repository.getWallets();
      final totalBalance = wallets.fold(0.0, (sum, wallet) => sum + wallet.balance);
      emit(WalletLoaded(wallets, totalBalance));
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }

  Future<void> addWallet(String name, String type, double initialBalance) async {
    emit(WalletLoading());
    try {
      await _repository.addWallet(name, type, initialBalance);
      emit(WalletAddedSuccess());
      // Reload wallets after adding
      await loadWallets();
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }
}
