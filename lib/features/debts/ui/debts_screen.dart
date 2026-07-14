import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/debt_cubit.dart';
import '../../../core/utils/formatters.dart';
import 'add_debt_screen.dart';

class DebtsScreen extends StatefulWidget {
  const DebtsScreen({super.key});

  @override
  State<DebtsScreen> createState() => _DebtsScreenState();
}

class _DebtsScreenState extends State<DebtsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DebtCubit>().loadDebts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text("Debts & Loans", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddDebtScreen()),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<DebtCubit, DebtState>(
        builder: (context, state) {
          if (state is DebtLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is DebtError) {
            return Center(child: Text("Error: ${state.message}"));
          } else if (state is DebtLoaded) {
            if (state.debts.isEmpty) {
              return const Center(
                child: Text("No active debts. You are all clear!"),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.debts.length,
              itemBuilder: (context, index) {
                final debt = state.debts[index];
                final isIOwe = debt.type == 'i_owe';
                final color = isIOwe ? Colors.redAccent : Colors.green;
                final label = isIOwe ? "I Owe" : "Owes Me";
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: color.withOpacity(0.2),
                      child: Icon(isIOwe ? Icons.arrow_outward : Icons.call_received, color: color),
                    ),
                    title: Text(debt.personName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
                        if (debt.isSettled)
                          const Text("Status: SETTLED", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          CurrencyFormatter.format(debt.amount),
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: debt.isSettled ? Colors.grey : color),
                        ),
                        const SizedBox(height: 4),
                        if (!debt.isSettled)
                          GestureDetector(
                            onTap: () => context.read<DebtCubit>().toggleSettled(debt.id, true),
                            child: const Text("Mark Settled", style: TextStyle(color: Colors.blueAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                          )
                        else
                           GestureDetector(
                            onTap: () => context.read<DebtCubit>().toggleSettled(debt.id, false),
                            child: const Text("Reopen", style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold)),
                          )
                      ],
                    ),
                    onLongPress: () {
                       context.read<DebtCubit>().deleteDebt(debt.id);
                    },
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
