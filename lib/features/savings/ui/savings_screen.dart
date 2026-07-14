import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/savings_cubit.dart';
import '../../../core/utils/formatters.dart';
import 'add_goal_screen.dart';

class SavingsScreen extends StatefulWidget {
  const SavingsScreen({super.key});

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SavingsCubit>().loadGoals();
  }

  Color _hexToColor(String code) {
    return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text("Savings Goals", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddGoalScreen()),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<SavingsCubit, SavingsState>(
        builder: (context, state) {
          if (state is SavingsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SavingsError) {
            return Center(child: Text("Error: ${state.message}"));
          } else if (state is SavingsLoaded) {
            if (state.goals.isEmpty) {
              return const Center(
                child: Text("No goals set yet. Start saving for your dreams!"),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.goals.length,
              itemBuilder: (context, index) {
                final goal = state.goals[index];
                final color = _hexToColor(goal.color);
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(goal.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              onPressed: () => context.read<SavingsCubit>().deleteGoal(goal.id),
                            )
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Saved: ${CurrencyFormatter.format(goal.currentAmount)}", style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                            Text("Target: ${CurrencyFormatter.format(goal.targetAmount)}", style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: goal.progressPercentage,
                            minHeight: 10,
                            backgroundColor: color.withOpacity(0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: color.withOpacity(0.1),
                                  foregroundColor: color,
                                  elevation: 0,
                                ),
                                icon: const Icon(Icons.add),
                                label: const Text("Add Funds"),
                                onPressed: () {
                                  _showAddFundsDialog(context, goal.id);
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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

  void _showAddFundsDialog(BuildContext context, String goalId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Add Funds to Goal"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "Amount", prefixText: "PKR "),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                final amount = double.tryParse(controller.text) ?? 0;
                context.read<SavingsCubit>().updateGoalAmount(goalId, amount);
                Navigator.pop(ctx);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }
}
