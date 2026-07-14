import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/network/supabase_config.dart';
import 'core/services/notification_service.dart';
import 'features/auth/ui/login_screen.dart';
import 'features/splash/ui/splash_screen.dart';
import 'core/theme/app_theme.dart';
import 'features/transactions/logic/transaction_bloc.dart';
import 'features/transactions/data/transaction_repository.dart';
import 'features/wallets/logic/wallet_cubit.dart';
import 'features/wallets/data/wallet_repository.dart';
import 'features/savings/data/savings_repository.dart';
import 'features/savings/logic/savings_cubit.dart';
import 'features/debts/data/debt_repository.dart';
import 'features/debts/logic/debt_cubit.dart';
import 'core/services/local_db_service.dart';
import 'core/services/sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.init();
  await NotificationService().init();
  
  await LocalDbService.init();
  SyncService.initialize();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => TransactionCubit(TransactionRepository())..getDashboardData(),
        ),
        BlocProvider(
          create: (context) => WalletCubit(WalletRepository())..loadWallets(),
        ),
        BlocProvider(
          create: (context) => SavingsCubit(SavingsRepository())..loadGoals(),
        ),
        BlocProvider(
          create: (context) => DebtCubit(DebtRepository())..loadDebts(),
        ),
      ],
      child: const ExpenseTrackerApp(),
    ),
  );
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
