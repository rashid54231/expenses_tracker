import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Bloc import kiya
import 'core/network/supabase_config.dart';
import 'core/services/notification_service.dart';
import 'features/auth/ui/login_screen.dart';
import 'features/transactions/logic/transaction_bloc.dart'; // Cubit path
import 'features/transactions/data/transaction_repository.dart'; // Repo path

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.init();
  await NotificationService().initNotification();

  runApp(
    // Global Provider: Ab poori app mein data sync rahega
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => TransactionCubit(TransactionRepository())..getDashboardData(),
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
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      ),
      home: const LoginScreen(),
    );
  }
}