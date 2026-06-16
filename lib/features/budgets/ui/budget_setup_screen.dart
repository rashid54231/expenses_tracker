import 'package:flutter/material.dart';
import '../data/budget_repository.dart';
import '../../../core/utils/formatters.dart';

class BudgetSetupScreen extends StatefulWidget {
  const BudgetSetupScreen({super.key});

  @override
  State<BudgetSetupScreen> createState() => _BudgetSetupScreenState();
}

class _BudgetSetupScreenState extends State<BudgetSetupScreen> {
  final TextEditingController _amountController = TextEditingController();
  final BudgetRepository _repo = BudgetRepository();
  String _selectedCategory = 'food';

  void _saveLimit() async {
    final String amountText = _amountController.text;
    final double? amount = double.tryParse(amountText);

    if (amount != null && amount > 0) {
      try {
        await _repo.setBudget(_selectedCategory, amount);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Budget Limit Updated Successfully!")),
          );
          // Navigator.pop ko rehne diya hai taake save ke baad
          // pichli screen par chala jaye (lekin AppBar wala button hat jayega)
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: ${e.toString()}")),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid amount")),
      );
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> categories = ['food', 'transport', 'shopping', 'bills'];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Set Budget Limits"),
        centerTitle: true,
        // --- YE 2 LINES AB ZAROOR KAAM KARENGI ---
        automaticallyImplyLeading: false,
        leading: const SizedBox.shrink(), // Ye jagah ko bilkul khatam kar dega
        // -----------------------------------------
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select Category:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: categories.map((String cat) {
                return DropdownMenuItem<String>(
                  value: cat,
                  child: Text(cat.toUpperCase()),
                );
              }).toList(),
              onChanged: (String? val) {
                if (val != null) {
                  setState(() {
                    _selectedCategory = val;
                  });
                }
              },
            ),

            const SizedBox(height: 25),
            Text(
              "Monthly Limit (${CurrencyFormatter.currencySymbol}):",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                hintText: "Enter amount (e.g. 500)",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.account_balance_wallet),
              ),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _saveLimit,
                child: const Text(
                  "Set Monthly Limit",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}