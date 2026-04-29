import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../logic/analytics_provider.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  // ── FIX 1: Color by index so ANY key (including UUIDs) gets a
  //           unique color. Named categories still match by name first.
  Color _getCategoryColor(String cat, {int index = 0}) {
    switch (cat.toLowerCase()) {
      case 'food':      return const Color(0xFFFFA726);
      case 'transport': return const Color(0xFF42A5F5);
      case 'shopping':  return const Color(0xFFEC407A);
      case 'bills':     return const Color(0xFFEF5350);
      case 'general':   return const Color(0xFF26A69A);
    }
    // Fallback palette cycled by index
    const palette = [
      Color(0xFF6C63FF),
      Color(0xFFFFA726),
      Color(0xFF42A5F5),
      Color(0xFFEC407A),
      Color(0xFF26A69A),
      Color(0xFFEF5350),
      Color(0xFFAB47BC),
      Color(0xFF29B6F6),
      Color(0xFF66BB6A),
      Color(0xFFFF7043),
    ];
    return palette[index % palette.length];
  }

  IconData _getCategoryIcon(String cat) {
    switch (cat.toLowerCase()) {
      case 'food':      return Icons.restaurant_rounded;
      case 'transport': return Icons.directions_car_rounded;
      case 'shopping':  return Icons.shopping_bag_rounded;
      case 'bills':     return Icons.receipt_long_rounded;
      case 'general':   return Icons.category_rounded;
      default:          return Icons.attach_money_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final logic = AnalyticsLogic();

    return FutureBuilder<Map<String, double>>(
      future: logic.getCategoryData(),
      builder: (context, snapshot) {

        // ── Loading ──────────────────────────────────────────────────
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            color: const Color(0xFFF0F2FA),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF6C63FF),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Loading stats...",
                    style: TextStyle(
                      color: Color(0xFF9E9E9E),
                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // ── Empty ────────────────────────────────────────────────────
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(
            color: const Color(0xFFF0F2FA),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.bar_chart_rounded,
                      size: 40,
                      color: Color(0xFFBDBDBD),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "No expense data available",
                    style: TextStyle(
                      color: Color(0xFF757575),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Add expenses to see your breakdown",
                    style: TextStyle(
                      color: Color(0xFFBDBDBD),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final data = snapshot.data!;
        final entries = data.entries.toList(); // indexed list for color lookup
        final total = data.values.fold(0.0, (a, b) => a + b);

        return Container(
          color: const Color(0xFFF0F2FA),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Dark App Bar ─────────────────────────────────────
                Container(
                  width: double.infinity,
                  color: const Color(0xFF1A1A2E),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "OVERVIEW",
                                  style: TextStyle(
                                    color: Color(0x80FFFFFF),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  "Expense Breakup",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.search_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),

                // ── Curved Transition ────────────────────────────────
                Container(
                  color: const Color(0xFF1A1A2E),
                  child: Container(
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF0F2FA),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // ── Summary Cards ────────────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "TOTAL SPENT",
                                    style: TextStyle(
                                      color: Color(0xFF9E9E9E),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.6,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "\$${total.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      color: Color(0xFF1A1A2E),
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    "↑ this month",
                                    style: TextStyle(
                                      color: Color(0xFF6C63FF),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6C63FF),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "CATEGORIES",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.65),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.6,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${data.length}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "active this month",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // ── Chart Card ───────────────────────────────
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            // Header row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Breakdown",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1A1A2E),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5F4FF),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    "This Month",
                                    style: TextStyle(
                                      color: Color(0xFF6C63FF),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // ── Pie Chart with Category Names ───────────────
                            Center(
                              child: SizedBox(
                                height: 200,
                                width: 200,
                                child: PieChart(
                                  PieChartData(
                                    sectionsSpace: 3,
                                    centerSpaceRadius: 50,
                                    sections: List.generate(
                                      entries.length,
                                          (i) {
                                        final e = entries[i];
                                        final pct = (e.value / total * 100)
                                            .toStringAsFixed(1);
                                        final color = _getCategoryColor(
                                          e.key,
                                          index: i,
                                        );

                                        // Shortened name to fit inside pie chart
                                        String displayName = e.key.length > 15
                                            ? "${e.key.substring(0, 12)}..."
                                            : e.key;

                                        return PieChartSectionData(
                                          value: e.value,
                                          title: "$displayName\n$pct%",
                                          radius: 60,
                                          titleStyle: const TextStyle(
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                            height: 1.25,
                                            shadows: [
                                              Shadow(
                                                color: Colors.black38,
                                                blurRadius: 5,
                                              ),
                                            ],
                                          ),
                                          color: color,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // ── Legend BELOW chart ─────────────────────────
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: entries.length,
                              gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 12,
                                childAspectRatio: 3.6,
                              ),
                              itemBuilder: (context, i) {
                                final e = entries[i];
                                final pct = e.value / total;
                                final color =
                                _getCategoryColor(e.key, index: i);
                                return Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: color,
                                        borderRadius:
                                        BorderRadius.circular(3),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            e.key,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF555555),
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: ClipRRect(
                                                  borderRadius:
                                                  BorderRadius.circular(4),
                                                  child:
                                                  LinearProgressIndicator(
                                                    value: pct,
                                                    minHeight: 3,
                                                    backgroundColor: color
                                                        .withOpacity(0.15),
                                                    valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(color),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                "${(pct * 100).toStringAsFixed(0)}%",
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w700,
                                                  color: color,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Categories Label ─────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Categories",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A2E),
                              letterSpacing: -0.2,
                            ),
                          ),
                          Text(
                            "${data.length} items",
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFFBDBDBD),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // ── Category Cards ───────────────────────────
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: entries.length,
                        separatorBuilder: (_, __) =>
                        const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final e = entries[index];
                          final pct = e.value / total;
                          final color =
                          _getCategoryColor(e.key, index: index);

                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      // Icon badge
                                      Container(
                                        width: 46,
                                        height: 46,
                                        decoration: BoxDecoration(
                                          color: color.withOpacity(0.10),
                                          borderRadius:
                                          BorderRadius.circular(15),
                                        ),
                                        child: Icon(
                                          _getCategoryIcon(e.key),
                                          color: color,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      // Name — always ellipsized
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              e.key.toUpperCase(),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 13,
                                                color: Color(0xFF1A1A2E),
                                                letterSpacing: 0.6,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              "${(pct * 100).toStringAsFixed(1)}% of total",
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Color(0xFFBDBDBD),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      // Amount
                                      Text(
                                        "\$${e.value.toStringAsFixed(2)}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 17,
                                          color: color,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  // Progress bar
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: pct,
                                      minHeight: 5,
                                      backgroundColor:
                                      color.withOpacity(0.10),
                                      valueColor:
                                      AlwaysStoppedAnimation<Color>(color),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}