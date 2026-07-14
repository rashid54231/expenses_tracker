import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../logic/wallet_cubit.dart';

class AddWalletScreen extends StatefulWidget {
  const AddWalletScreen({super.key});

  @override
  State<AddWalletScreen> createState() => _AddWalletScreenState();
}

class _AddWalletScreenState extends State<AddWalletScreen> {
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  String _selectedType = 'cash'; // 'cash', 'bank', 'credit_card'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Wallet"),
      ),
      body: BlocListener<WalletCubit, WalletState>(
        listener: (context, state) {
          if (state is WalletAddedSuccess) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Wallet added successfully!')),
            );
          } else if (state is WalletError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error), backgroundColor: Colors.red),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Wallet Name
              const Text("Wallet Name", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: "e.g., Meezan Bank",
                ),
              ),
              const SizedBox(height: 24),

              // Wallet Type
              const Text("Wallet Type", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(),
                items: const [
                  DropdownMenuItem(value: 'cash', child: Text("Cash")),
                  DropdownMenuItem(value: 'bank', child: Text("Bank Account")),
                  DropdownMenuItem(value: 'credit_card', child: Text("Credit Card")),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedType = value);
                  }
                },
              ),
              const SizedBox(height: 24),

              // Starting Balance
              const Text("Starting Balance", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              TextField(
                controller: _balanceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  hintText: "0.00",
                  prefixText: "PKR ",
                ),
              ),
              const SizedBox(height: 40),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: BlocBuilder<WalletCubit, WalletState>(
                  builder: (context, state) {
                    if (state is WalletLoading) {
                      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
                    }
                    return ElevatedButton(
                      onPressed: () {
                        final name = _nameController.text.trim();
                        final balanceText = _balanceController.text.trim();
                        
                        if (name.isEmpty || balanceText.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please fill all fields')),
                          );
                          return;
                        }

                        final balance = double.tryParse(balanceText);
                        if (balance == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Invalid balance amount')),
                          );
                          return;
                        }

                        context.read<WalletCubit>().addWallet(name, _selectedType, balance);
                      },
                      child: const Text("Save Wallet"),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
