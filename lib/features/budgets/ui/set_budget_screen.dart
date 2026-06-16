import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/formatters.dart';

class SetBudgetScreen extends StatefulWidget {
  const SetBudgetScreen({super.key});

  @override
  State<SetBudgetScreen> createState() => _SetBudgetScreenState();
}

class _SetBudgetScreenState extends State<SetBudgetScreen> {
  final _amountController = TextEditingController();

  String _selectedCategory = 'Food';
  final List<String> _categories = [
    'Food',
    'Transport',
    'Shopping',
    'Bills',
    'Entertainment',
    'Others'
  ];

  bool _isLoading = false;

  Future<void> _saveBudget() async {
    final String amountText = _amountController.text.trim();
    final double? amount = double.tryParse(amountText);

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Sahi amount enter karein!"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw "User login nahi hai!";

      final String currentMonth = DateFormat('yyyy-MM').format(DateTime.now());

      await Supabase.instance.client.from('budgets').upsert({
        'user_id': user.id,
        'category_id': _selectedCategory,
        'monthly_limit': amount,
        'month': currentMonth,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id,category_id,month');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Budget successfully set ho gaya!"),
            backgroundColor: Colors.green,
          ),
        );
        // Navigator.pop ko rehne diya hai taake save ke baad
        // pichli screen (Dashboard) par chala jaye.
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Error: ${e.toString()}"),
              backgroundColor: Colors.red
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Set Monthly Budget", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        // --- CHANGES START HERE ---
        automaticallyImplyLeading: false, // Default arrow hatane ke liye
        // leading wala IconButton poora delete kar diya gaya hai
        // --------------------------
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Category",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.green),
                  items: _categories.map((cat) => DropdownMenuItem(
                      value: cat,
                      child: Text(cat, style: const TextStyle(fontSize: 16))
                  )).toList(),
                  onChanged: (val) => setState(() => _selectedCategory = val!),
                ),
              ),
            ),

            const SizedBox(height: 30),

            Text(
              "Budget Limit (${CurrencyFormatter.currencySymbol})",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: "for Example: 500",
                prefixIcon: const Icon(Icons.account_balance_wallet_rounded, color: Colors.green),
                filled: true,
                fillColor: Colors.grey.shade50,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Colors.green, width: 2),
                ),
              ),
            ),

            const SizedBox(height: 50),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.green))
                  : ElevatedButton(
                onPressed: _saveBudget,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  elevation: 2,
                  shadowColor: Colors.green.withOpacity(0.3),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text(
                  "SAVE BUDGET",
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}