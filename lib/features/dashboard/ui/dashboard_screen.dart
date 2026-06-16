import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../transactions/logic/transaction_bloc.dart';
import '../../transactions/ui/add_transaction_screen.dart';
import '../../notifications/ui/notification_screen.dart';
import '../../profile/ui/profile_screen.dart';
import '../../../core/utils/formatters.dart';

// ── FIX: StatefulWidget with ScrollController so we can detect
//         when the SliverAppBar is collapsed vs expanded.
//         When expanded  → title is transparent (invisible)
//         When collapsed → title fades in
//         This eliminates the "Expenses Tracker / there" overlap.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // How tall the hero section is
  static const double _expandedHeight = 300.0;

  late ScrollController _scrollController;
  bool _isCollapsed = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final collapsed =
        _scrollController.hasClients &&
            _scrollController.offset >
                (_expandedHeight - kToolbarHeight - 20);
    if (collapsed != _isCollapsed) {
      setState(() => _isCollapsed = collapsed);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _refreshData(BuildContext context) {
    context.read<TransactionCubit>().getDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final user = Supabase.instance.client.auth.currentUser;
    final String? avatarUrl = user?.userMetadata?['avatar_url'];
    final String userName =
        user?.userMetadata?['full_name']?.toString().split(' ').first ??
            'welcom To Homepage';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: BlocBuilder<TransactionCubit, TransactionState>(
        builder: (context, state) {
          if (state is TransactionLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF1B4332)),
            );
          }

          Map<String, double> summary = {
            'income': 0.0,
            'expense': 0.0,
            'total': 0.0,
          };
          List<dynamic> transactions = [];
          Map<String, double> categoryData = {};
          Map<String, String> categoryMap = {};

          if (state is DashboardDataLoaded) {
            summary = state.summary;
            transactions = state.transactions;
            categoryData = state.categoryData;
            categoryMap = state.categoryMap;
          }

          return RefreshIndicator(
            color: const Color(0xFF1B4332),
            onRefresh: () async => _refreshData(context),
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [

                // ── SliverAppBar ───────────────────────────────────
                SliverAppBar(
                  expandedHeight: _expandedHeight,
                  pinned: true,
                  backgroundColor: const Color(0xFF1B4332),
                  automaticallyImplyLeading: false,
                  elevation: 0,

                  // ── FIX: title is TRANSPARENT when expanded so it
                  //         doesn't overlap the hero greeting.
                  //         It fades to white only when collapsed.
                  title: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _isCollapsed ? 1.0 : 0.0,
                    child: const Text(
                      "Expenses Tracker",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),

                  // ── FIX: actions also hidden when expanded so the
                  //         bell/avatar don't double up with the hero's
                  //         own bell/avatar row.
                  actions: [
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: _isCollapsed ? 1.0 : 0.0,
                      child: IconButton(
                        icon: const Icon(
                          Icons.notifications_none_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                        onPressed: _isCollapsed
                            ? () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                            const NotificationScreen(),
                          ),
                        )
                            : null,
                      ),
                    ),
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: _isCollapsed ? 1.0 : 0.0,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16, left: 4),
                        child: GestureDetector(
                          onTap: _isCollapsed
                              ? () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ProfileScreen(),
                              ),
                            );
                            if (context.mounted) {
                              _refreshData(context);
                            }
                          }
                              : null,
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.white24,
                            backgroundImage: avatarUrl != null
                                ? NetworkImage(avatarUrl)
                                : null,
                            child: avatarUrl == null
                                ? const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 18,
                            )
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ],

                  // Hero background — shown only when expanded
                  flexibleSpace: FlexibleSpaceBar(
                    // collapseMode: none so background doesn't parallax-shift
                    collapseMode: CollapseMode.pin,
                    background: _buildHeroHeader(
                      summary,
                      screenWidth,
                      avatarUrl,
                      userName,
                      context,
                    ),
                  ),
                ),

                // ── Body ──────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        _buildQuickStats(summary),
                        const SizedBox(height: 28),

                        _buildSectionHeader(
                          "Spending Analysis",
                          Icons.donut_large_rounded,
                        ),
                        const SizedBox(height: 14),
                        _buildPieChartCard(categoryData),
                        const SizedBox(height: 28),

                        _buildSectionHeader(
                          "Recent Transactions",
                          Icons.receipt_long_rounded,
                        ),
                        const SizedBox(height: 14),

                        transactions.isEmpty
                            ? _buildEmptyState()
                            : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: transactions.length,
                          itemBuilder: (context, index) {
                            final tx = transactions[index];
                            return Dismissible(
                              key: Key(tx.id.toString()),
                              direction:
                              DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(
                                    right: 20),
                                margin: const EdgeInsets.only(
                                    bottom: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFEBEE),
                                  borderRadius:
                                  BorderRadius.circular(18),
                                ),
                                child: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: Color(0xFFEF5350),
                                  size: 24,
                                ),
                              ),
                              onDismissed: (direction) {
                                context
                                    .read<TransactionCubit>()
                                    .removeTransaction(
                                    tx.id.toString());
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                        "Transaction deleted"),
                                    behavior:
                                    SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(12),
                                    ),
                                    backgroundColor:
                                    const Color(0xFF1B4332),
                                  ),
                                );
                              },
                              child: _buildTransactionTile(tx, categoryMap),
                            );
                          },
                        ),

                        const SizedBox(height: 28),
                        _buildAddButton(context),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Hero Header ──────────────────────────────────────────────────────
  // Rendered as FlexibleSpaceBar background.
  // Has its OWN greeting row + avatar + bell — independent of the
  // SliverAppBar's title/actions which are hidden when expanded.
  Widget _buildHeroHeader(
      Map<String, double> summary,
      double width,
      String? avatarUrl,
      String userName,
      BuildContext context,
      ) {
    return Container(
      color: const Color(0xFF1B4332),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -30,
            right: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 60,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            left: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),

          // Content — SafeArea keeps it below status bar
          SafeArea(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Top row: greeting + bell + avatar ───────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Greeting
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Good ${_greeting()}, 👋",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              userName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.4,
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),

                        // Bell + Avatar
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const NotificationScreen(),
                                ),
                              ),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.notifications_none_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ProfileScreen(),
                                  ),
                                );
                                if (context.mounted) _refreshData(context);
                              },
                              child: CircleAvatar(
                                radius: 20,
                                backgroundColor:
                                Colors.white.withOpacity(0.2),
                                backgroundImage: avatarUrl != null
                                    ? NetworkImage(avatarUrl)
                                    : null,
                                child: avatarUrl == null
                                    ? const Icon(Icons.person,
                                    color: Colors.white, size: 22)
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ── Balance ──────────────────────────────────────
                    Text(
                      "Total Balance",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 13,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      CurrencyFormatter.format(summary['total'] ?? 0.0),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: width * 0.09,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.5,
                        height: 1.1,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Income / Expense pills ───────────────────────
                    Row(
                      children: [
                        _buildBalancePill(
                          label: "Income",
                          amount: summary['income'] ?? 0,
                          icon: Icons.arrow_downward_rounded,
                          iconBg: const Color(0xFF2D6A4F),
                          iconColor: const Color(0xFF95D5B2),
                        ),
                        const SizedBox(width: 12),
                        _buildBalancePill(
                          label: "Expense",
                          amount: summary['expense'] ?? 0,
                          icon: Icons.arrow_upward_rounded,
                          iconBg: const Color(0xFF6B2737),
                          iconColor: const Color(0xFFFFB3C1),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalancePill({
    required String label,
    required double amount,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.10),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 16),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  CurrencyFormatter.format(amount),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Quick Stats ──────────────────────────────────────────────────────
  Widget _buildQuickStats(Map<String, double> summary) {
    final double savings =
        (summary['income'] ?? 0) - (summary['expense'] ?? 0);
    final double savingsRate = (summary['income'] ?? 0) > 0
        ? (savings / (summary['income'] ?? 1) * 100)
        : 0;

    return Row(
      children: [
        _buildStatCard(
          label: "Saved",
          value: CurrencyFormatter.format(savings.abs(), decimalDigits: 0),
          sub: savings >= 0 ? "Great job!" : "Over budget",
          color: savings >= 0
              ? const Color(0xFF1B4332)
              : const Color(0xFFEF5350),
          bg: savings >= 0
              ? const Color(0xFFEBF5EE)
              : const Color(0xFFFFEBEE),
          icon: savings >= 0
              ? Icons.trending_up_rounded
              : Icons.trending_down_rounded,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          label: "Save rate",
          value: "${savingsRate.toStringAsFixed(0)}%",
          sub: "of income",
          color: const Color(0xFF1565C0),
          bg: const Color(0xFFE3F2FD),
          icon: Icons.pie_chart_outline_rounded,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required String sub,
    required Color color,
    required Color bg,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: color.withOpacity(0.7),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  sub,
                  style: TextStyle(
                    color: color.withOpacity(0.6),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Section Header ───────────────────────────────────────────────────
  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFF1B4332).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF1B4332), size: 17),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A2E),
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  // ── Pie Chart Card ───────────────────────────────────────────────────
  Widget _buildPieChartCard(Map<String, double> data) {
    if (data.isEmpty) return _buildEmptyState();

    final entries = data.entries.toList();
    final total = data.values.fold(0.0, (a, b) => a + b);

    const List<Color> palette = [
      Color(0xFF1B4332),
      Color(0xFF42A5F5),
      Color(0xFFFFA726),
      Color(0xFFEC407A),
      Color(0xFF26A69A),
      Color(0xFFEF5350),
      Color(0xFFAB47BC),
      Color(0xFF29B6F6),
      Color(0xFF66BB6A),
      Color(0xFFFF7043),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Pie
              SizedBox(
                height: 160,
                width: 160,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 3,
                    centerSpaceRadius: 40,
                    sections: List.generate(entries.length, (i) {
                      return PieChartSectionData(
                        value: entries[i].value,
                        title: '',
                        color: palette[i % palette.length],
                        radius: 55,
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // Legend
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(entries.length, (i) {
                    final color = palette[i % palette.length];
                    final pct = entries[i].value / total;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              entries[i].key,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF555555),
                              ),
                            ),
                          ),
                          Text(
                            "${(pct * 100).toStringAsFixed(0)}%",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Bar strip
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: List.generate(entries.length, (i) {
                final color = palette[i % palette.length];
                final pct = entries[i].value / total;
                return Expanded(
                  flex: (pct * 100).round(),
                  child: Container(height: 6, color: color),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ── Transaction Tile ─────────────────────────────────────────────────
  Widget _buildTransactionTile(dynamic tx, Map<String, String> categoryMap) {
    final bool isExpense = tx.type == 'expense';
    final Color tileColor =
    isExpense ? const Color(0xFFEF5350) : const Color(0xFF1B4332);
    final Color tileBg =
    isExpense ? const Color(0xFFFFEBEE) : const Color(0xFFEBF5EE);
    final String displayName = tx.note.isNotEmpty
        ? tx.note
        : (categoryMap[tx.categoryId] ?? 'General');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: tileBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isExpense
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
              color: tileColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded,
                        size: 10, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('dd MMM yyyy').format(tx.date),
                      style: TextStyle(
                          color: Colors.grey.shade400, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${isExpense ? '-' : '+'}${CurrencyFormatter.format(tx.amount)}",
                style: TextStyle(
                  color: tileColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 3),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: tileBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isExpense ? "Expense" : "Income",
                  style: TextStyle(
                    color: tileColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Empty State ──────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFEBF5EE),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.receipt_long_rounded,
                color: Color(0xFF1B4332), size: 30),
          ),
          const SizedBox(height: 14),
          const Text(
            "No transactions yet",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Tap the button below to add one",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ── Add Button ───────────────────────────────────────────────────────
  Widget _buildAddButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const AddTransactionScreen()),
        );
        if (context.mounted) _refreshData(context);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFF1B4332),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1B4332).withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline_rounded,
                color: Colors.white, size: 22),
            SizedBox(width: 10),
            Text(
              "Add New Transaction",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helper ───────────────────────────────────────────────────────────
  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "morning";
    if (hour < 17) return "afternoon";
    return "evening";
  }
}