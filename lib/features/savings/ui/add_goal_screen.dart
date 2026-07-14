import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/savings_cubit.dart';
import '../data/savings_model.dart';
import 'package:uuid/uuid.dart';

class AddGoalScreen extends StatefulWidget {
  const AddGoalScreen({super.key});

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedColor = '#6C63FF';

  final List<String> _colors = [
    '#6C63FF', '#FFA726', '#42A5F5', '#EC407A', '#26A69A', '#EF5350'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("New Savings Goal")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Goal Name", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(hintText: "e.g., Dream Car, Vacations"),
            ),
            const SizedBox(height: 24),

            const Text("Target Amount", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: "0.00", prefixText: "PKR "),
            ),
            const SizedBox(height: 24),

            const Text("Theme Color", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              children: _colors.map((colorHex) {
                final color = Color(int.parse(colorHex.substring(1, 7), radix: 16) + 0xFF000000);
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = colorHex),
                  child: CircleAvatar(
                    backgroundColor: color,
                    child: _selectedColor == colorHex ? const Icon(Icons.check, color: Colors.white) : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_nameController.text.isEmpty || _amountController.text.isEmpty) return;
                  
                  final newGoal = SavingsModel(
                    id: const Uuid().v4(),
                    userId: '', // Will be set in repository
                    name: _nameController.text.trim(),
                    targetAmount: double.parse(_amountController.text),
                    currentAmount: 0,
                    color: _selectedColor,
                  );

                  context.read<SavingsCubit>().addGoal(newGoal);
                  Navigator.pop(context);
                },
                child: const Text("Create Goal"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
