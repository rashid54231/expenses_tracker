import 'package:flutter/material.dart';
import '../../dashboard/ui/dashboard_screen.dart';
import '../../analytics/ui/stats_screen.dart';
import '../../transactions/ui/add_transaction_screen.dart';
import '../../budgets/ui/set_budget_screen.dart';
import '../../notifications/ui/notification_screen.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _selectedIndex = 0;

  // Wapis 4 Screens ka setup (History ab Dashboard ke andar se open hogi)
  final List<Widget> _screens = [
    const DashboardScreen(),     // Index 0
    const StatsScreen(),         // Index 1
    const Scaffold(),            // Index 2 (Placeholder for Add)
    const SetBudgetScreen(),     // Index 3
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Expenses Tracker",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: Colors.black, size: 26),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationScreen())),
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),

      // --- MOBILE BALANCED 4 BUTTONS NAV BAR ---
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        iconSize: 22,
        selectedFontSize: 11,
        unselectedFontSize: 11,

        onTap: (index) {
          if (index == 2) {
            // Add Button click par screen push hogi
            Navigator.push(context, MaterialPageRoute(builder: (context) => const AddTransactionScreen()));
          } else {
            setState(() => _selectedIndex = index);
          }
        },
        items: [
          const BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_rounded),
              label: "Home"
          ),
          const BottomNavigationBarItem(
              icon: Icon(Icons.pie_chart_outline),
              label: "Stats"
          ),

          // ADD BUTTON (Balanced Circle)
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 20),
            ),
            label: "Add",
          ),

          const BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_outlined),
              label: "Budget"
          ),
        ],
      ),
    );
  }
}