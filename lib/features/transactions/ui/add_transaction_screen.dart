import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/transaction_bloc.dart';
import '../../categories/data/category_model.dart';
import '../../categories/presentation/pages/category_list_screen.dart';
import '../../wallets/data/wallet_model.dart';
import '../../wallets/logic/wallet_cubit.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../core/utils/formatters.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen>
    with SingleTickerProviderStateMixin {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String _type = 'expense';
  CategoryModel? _selectedCategory;
  WalletModel? _selectedWallet;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  String? _receiptImagePath;

  // Design constants
  static const Color _navy = Color(0xFF1A1A2E);
  static const Color _gold = Color(0xFFE2B96F);
  static const Color _incomeGreen = Color(0xFF4CAF50);
  static const Color _expenseRed = Color(0xFFFF6B6B);
  static const Color _bgGrey = Color(0xFFF6F7FB);
  static const Color _cardWhite = Colors.white;
  static const Color _subtleText = Color(0xFF9CA3C0);
  static const Color _darkText = Color(0xFF1A1A2E);

  @override
  void initState() {
    super.initState();
    context.read<TransactionCubit>().fetchUserCategories();
    context.read<WalletCubit>().loadWallets();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _animController.dispose();
    super.dispose();
  }

  bool get _isExpense => _type == 'expense';
  Color get _accentColor => _isExpense ? _expenseRed : _incomeGreen;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          context.read<TransactionCubit>().getDashboardData();
        }
      },
      child: Scaffold(
        backgroundColor: _bgGrey,
        body: BlocConsumer<TransactionCubit, TransactionState>(
          listener: (context, state) {
            if (state is DashboardDataLoaded) {
              ScaffoldMessenger.of(context).showSnackBar(
                _styledSnack("Saved Successfully!", isError: false),
              );
              Navigator.pop(context);
            } else if (state is TransactionError) {
              ScaffoldMessenger.of(context).showSnackBar(
                _styledSnack(state.message, isError: true),
              );
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTypeToggle(),
                          const SizedBox(height: 16),
                          _buildAmountCard(),
                          const SizedBox(height: 16),
                          _buildCategoryDropdown(state),
                          const SizedBox(height: 16),
                          _buildWalletDropdown(),
                          const SizedBox(height: 16),
                          _buildNoteField(),
                          const SizedBox(height: 16),
                          _buildReceiptPicker(),
                          const SizedBox(height: 28),
                          _buildSaveButton(state),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 20,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 6, 8, 20),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white70, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.add_card_rounded, color: _gold, size: 22),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  "Add Entry",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.settings_suggest_rounded,
                    color: Colors.white60, size: 22),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CategoryListScreen()),
                  ).then((_) {
                    context.read<TransactionCubit>().fetchUserCategories();
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: _cardWhite,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: _navy.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          _typeOption(
              'expense', 'Expense', Icons.remove_circle_outline_rounded, _expenseRed),
          _typeOption(
              'income', 'Income', Icons.add_circle_outline_rounded, _incomeGreen),
        ],
      ),
    );
  }

  Widget _typeOption(String value, String label, IconData icon, Color color) {
    final bool selected = _type == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _type = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: selected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(13),
            boxShadow: selected
                ? [
              BoxShadow(
                color: color.withOpacity(0.35),
                blurRadius: 10,
                offset: const Offset(0, 3),
              )
            ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 18, color: selected ? Colors.white : _subtleText),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : _subtleText,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountCard() {
    return Container(
      decoration: BoxDecoration(
        color: _cardWhite,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: _navy.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 4),
      child: TextField(
        controller: _amountController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: _accentColor,
          letterSpacing: 0.5,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: "Amount",
          labelStyle: const TextStyle(
              color: _subtleText, fontSize: 13, fontWeight: FontWeight.w500),
          floatingLabelStyle: TextStyle(color: _accentColor, fontSize: 13),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(right: 10, top: 14),
            child: Text(
              CurrencyFormatter.currencySymbol,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: _accentColor.withOpacity(0.6),
              ),
            ),
          ),
          prefixIconConstraints:
          const BoxConstraints(minWidth: 0, minHeight: 0),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown(TransactionState state) {
    List<CategoryModel> categoriesList = [];
    if (state is CategoriesLoaded) {
      categoriesList = state.categories;
    }

    return Container(
      decoration: BoxDecoration(
        color: _cardWhite,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: _navy.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      child: DropdownButtonFormField<CategoryModel>(
        value: _selectedCategory,
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _subtleText),
        dropdownColor: _cardWhite,
        decoration: const InputDecoration(
          border: InputBorder.none,
          labelText: "Category",
          labelStyle: TextStyle(
              color: _subtleText, fontSize: 13, fontWeight: FontWeight.w500),
        ),
        style: const TextStyle(
          color: _darkText,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        items: categoriesList.map((cat) {
          return DropdownMenuItem<CategoryModel>(
            value: cat,
            child: Text(cat.name),
          );
        }).toList(),
        onChanged: (newValue) {
          setState(() {
            _selectedCategory = newValue;
            if (newValue != null) {
              _type = newValue.type;
            }
          });
        },
        hint: state is TransactionLoading
            ? const Row(
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: _subtleText),
            ),
            SizedBox(width: 10),
            Text("Loading categories...",
                style: TextStyle(color: _subtleText, fontSize: 14)),
          ],
        )
            : const Text("Choose a category",
            style: TextStyle(color: _subtleText, fontSize: 14)),
      ),
    );
  }

  Widget _buildWalletDropdown() {
    return BlocBuilder<WalletCubit, WalletState>(
      builder: (context, state) {
        List<WalletModel> walletsList = [];
        if (state is WalletLoaded) {
          walletsList = state.wallets;
          // Auto-select first wallet if none is selected
          if (_selectedWallet == null && walletsList.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() => _selectedWallet = walletsList.first);
            });
          }
        }

        return Container(
          decoration: BoxDecoration(
            color: _cardWhite,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: _navy.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
          child: DropdownButtonFormField<WalletModel>(
            value: _selectedWallet,
            isExpanded: true,
            icon: const Icon(Icons.account_balance_wallet_rounded, color: _subtleText),
            dropdownColor: _cardWhite,
            decoration: const InputDecoration(
              border: InputBorder.none,
              labelText: "Wallet",
              labelStyle: TextStyle(
                  color: _subtleText, fontSize: 13, fontWeight: FontWeight.w500),
            ),
            style: const TextStyle(
              color: _darkText,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            items: walletsList.map((wallet) {
              return DropdownMenuItem<WalletModel>(
                value: wallet,
                child: Text(wallet.name),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                _selectedWallet = newValue;
              });
            },
            hint: state is WalletLoading
                ? const Row(
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: _subtleText),
                      ),
                      SizedBox(width: 10),
                      Text("Loading wallets...", style: TextStyle(color: _subtleText, fontSize: 14)),
                    ],
                  )
                : const Text("Choose a wallet", style: TextStyle(color: _subtleText, fontSize: 14)),
          ),
        );
      },
    );
  }

  Widget _buildNoteField() {
    return Container(
      decoration: BoxDecoration(
        color: _cardWhite,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: _navy.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 4),
      child: TextField(
        controller: _noteController,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: _darkText,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          labelText: "Note (Optional)",
          labelStyle: TextStyle(
              color: _subtleText, fontSize: 13, fontWeight: FontWeight.w500),
          hintText: "Add a short description...",
          hintStyle: TextStyle(color: Color(0xFFBCC0D6), fontSize: 14),
          prefixIcon: Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.notes_rounded, color: _subtleText, size: 20),
          ),
          prefixIconConstraints: BoxConstraints(minWidth: 32, minHeight: 0),
        ),
        maxLines: 2,
        minLines: 1,
      ),
    );
  }

  Widget _buildReceiptPicker() {
    return GestureDetector(
      onTap: () async {
        final picker = ImagePicker();
        final pickedFile = await picker.pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          setState(() {
            _receiptImagePath = pickedFile.path;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        decoration: BoxDecoration(
          color: _receiptImagePath == null ? _cardWhite : _accentColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _receiptImagePath == null ? Colors.transparent : _accentColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: _navy.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              _receiptImagePath == null ? Icons.camera_alt_outlined : Icons.check_circle_rounded,
              color: _receiptImagePath == null ? _subtleText : _accentColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _receiptImagePath == null ? "Attach Receipt Image" : "Receipt Attached",
                style: TextStyle(
                  color: _receiptImagePath == null ? _subtleText : _accentColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (_receiptImagePath != null)
              GestureDetector(
                onTap: () => setState(() => _receiptImagePath = null),
                child: const Icon(Icons.close_rounded, color: Colors.grey, size: 20),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(TransactionState state) {
    if (state is TransactionLoading) {
      return Center(
        child: SizedBox(
          width: 48,
          height: 48,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: _accentColor,
            backgroundColor: _accentColor.withOpacity(0.15),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        final amountStr = _amountController.text.trim();
        if (amountStr.isEmpty) {
          ScaffoldMessenger.of(context)
              .showSnackBar(_styledSnack("Please enter an amount", isError: true));
          return;
        }
        if (_selectedCategory == null) {
          ScaffoldMessenger.of(context).showSnackBar(
              _styledSnack("Please select a category", isError: true));
          return;
        }
        if (_selectedWallet == null) {
          ScaffoldMessenger.of(context).showSnackBar(
              _styledSnack("Please select a wallet", isError: true));
          return;
        }
        String finalNote = _noteController.text.trim();
        if (_receiptImagePath != null) {
          finalNote += "\n[Receipt: $_receiptImagePath]";
        }

        context.read<TransactionCubit>().addNewTransaction(
          amount: double.parse(amountStr),
          categoryId: _selectedCategory!.id,
          walletId: _selectedWallet!.id,
          type: _type,
          note: finalNote.trim(),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: double.infinity,
        height: 58,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isExpense
                ? [const Color(0xFFFF6B6B), const Color(0xFFE53935)]
                : [const Color(0xFF4CAF50), const Color(0xFF2E7D32)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: _accentColor.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isExpense
                  ? Icons.remove_circle_outline_rounded
                  : Icons.add_circle_outline_rounded,
              color: Colors.white,
              size: 22,
            ),
            const SizedBox(width: 10),
            const Text(
              "Save Transaction",
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  SnackBar _styledSnack(String message, {bool isError = false}) {
    return SnackBar(
      content: Row(
        children: [
          Icon(
            isError ? Icons.warning_amber_rounded : Icons.check_circle_rounded,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 10),
          Text(message, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
      backgroundColor: isError ? _expenseRed : _incomeGreen,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}