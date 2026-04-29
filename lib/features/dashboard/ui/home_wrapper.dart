import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import '../../analytics/ui/stats_screen.dart';
import '../../budgets/ui/set_budget_screen.dart';
import '../../transactions/ui/transactions_history_screen.dart';

class HomeWrapper extends StatefulWidget {
  const HomeWrapper({super.key});

  @override
  State<HomeWrapper> createState() => _HomeWrapperState();
}

class _HomeWrapperState extends State<HomeWrapper> {
  int _currentIndex = 0;

  // Updated List with 4 screens (No changes here)
  final List<Widget> _screens = [
    const DashboardScreen(),
    const TransactionsHistoryScreen(),
    const SetBudgetScreen(),
    const StatsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // PopScope use kiya hai taake back button navigation ko control kiya ja sakay
    return PopScope(
      canPop: _currentIndex == 0, // Agar index 0 (Home) hai toh hi exit ho sakegi
      onPopInvokedWithResult: (didPop, result) {
        // Agar didPop true hai (yaani app exit ho rahi hai), toh kuch nahi karna
        if (didPop) return;

        // Agar user kisi aur tab par hai (index 1, 2, ya 3), toh usey Home par le aao
        if (_currentIndex != 0) {
          setState(() {
            _currentIndex = 0;
          });
        }
      },
      child: Scaffold(
        body: IndexedStack( // IndexedStack use karna behtar hai taake screen ka state save rahay
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed, // Use fixed for 4+ items
          selectedItemColor: Colors.green.shade700,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.history_rounded), label: "History"),
            BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_rounded), label: "Budget"),
            BottomNavigationBarItem(icon: Icon(Icons.pie_chart_rounded), label: "Stats"),
          ],
        ),
      ),
    );
  }
}