import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../logic/wallet_cubit.dart';
import '../data/wallet_model.dart';
import 'add_wallet_screen.dart';

class WalletListScreen extends StatefulWidget {
  const WalletListScreen({super.key});

  @override
  State<WalletListScreen> createState() => _WalletListScreenState();
}

class _WalletListScreenState extends State<WalletListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<WalletCubit>().loadWallets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Wallets"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddWalletScreen()),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<WalletCubit, WalletState>(
        builder: (context, state) {
          if (state is WalletLoading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
          } else if (state is WalletError) {
            return Center(child: Text("Error: ${state.error}", style: const TextStyle(color: Colors.red)));
          } else if (state is WalletLoaded) {
            if (state.wallets.isEmpty) {
              return const Center(
                child: Text("No wallets found. Click '+' to add one.", 
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
              );
            }

            return RefreshIndicator(
              onRefresh: () => context.read<WalletCubit>().loadWallets(),
              color: AppTheme.primaryColor,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.wallets.length,
                itemBuilder: (context, index) {
                  final wallet = state.wallets[index];
                  return _buildWalletCard(wallet);
                },
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildWalletCard(WalletModel wallet) {
    FaIconData icon;
    Color color;

    switch (wallet.type.toLowerCase()) {
      case 'cash':
        icon = FontAwesomeIcons.moneyBillWave;
        color = const Color(0xFF10B981); // Green
        break;
      case 'bank':
        icon = FontAwesomeIcons.buildingColumns;
        color = const Color(0xFF3B82F6); // Blue
        break;
      case 'credit_card':
        icon = FontAwesomeIcons.creditCard;
        color = const Color(0xFFF59E0B); // Amber
        break;
      default:
        icon = FontAwesomeIcons.wallet;
        color = const Color(0xFF6366F1); // Indigo
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: FaIcon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    wallet.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    wallet.type.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              "PKR ${wallet.balance.toStringAsFixed(0)}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
