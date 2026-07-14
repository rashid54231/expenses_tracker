import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/debt_cubit.dart';
import '../data/debt_model.dart';
import 'package:uuid/uuid.dart';

class AddDebtScreen extends StatefulWidget {
  const AddDebtScreen({super.key});

  @override
  State<AddDebtScreen> createState() => _AddDebtScreenState();
}

class _AddDebtScreenState extends State<AddDebtScreen> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  String _type = 'i_owe'; // 'i_owe' or 'they_owe'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Debt / Loan")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Person Name", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(hintText: "e.g., Ali, John"),
            ),
            const SizedBox(height: 24),

            const Text("Amount", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: "0.00", prefixText: "PKR "),
            ),
            const SizedBox(height: 24),

            const Text("Type", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text("I Owe Them"),
                    value: 'i_owe',
                    groupValue: _type,
                    onChanged: (val) => setState(() => _type = val!),
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text("They Owe Me"),
                    value: 'they_owe',
                    groupValue: _type,
                    onChanged: (val) => setState(() => _type = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_nameController.text.isEmpty || _amountController.text.isEmpty) return;
                  
                  final newDebt = DebtModel(
                    id: const Uuid().v4(),
                    userId: '',
                    personName: _nameController.text.trim(),
                    amount: double.parse(_amountController.text),
                    type: _type,
                  );

                  context.read<DebtCubit>().addDebt(newDebt);
                  Navigator.pop(context);
                },
                child: const Text("Save"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
