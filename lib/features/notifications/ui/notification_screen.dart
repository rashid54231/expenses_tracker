import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white70, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2B96F).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.notifications_active_rounded,
                          color: Color(0xFFE2B96F), size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "Notifications",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF6F7FB),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                  ),
                  child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: supabase
                        .from('notifications')
                        .stream(primaryKey: ['id'])
                        .eq('user_id', userId ?? '')
                        .order('created_at', ascending: false),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 44,
                                height: 44,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: const Color(0xFF6C63FF),
                                  backgroundColor:
                                      const Color(0xFF6C63FF).withOpacity(0.15),
                                ),
                              ),
                              const SizedBox(height: 14),
                              const Text(
                                "Loading alerts...",
                                style: TextStyle(
                                  color: Color(0xFF8A8FA8),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return _buildEmptyState();
                      }

                      final notifications = snapshot.data!;
                      final grouped = _groupByDate(notifications);

                      return RefreshIndicator(
                        color: const Color(0xFF6C63FF),
                        onRefresh: () async {},
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                          itemCount: grouped.length,
                          itemBuilder: (context, index) {
                            final group = grouped[index];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 4, bottom: 10),
                                  child: Text(
                                    group['label'],
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF9CA3C0),
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                                ...(group['items'] as List).map((notif) =>
                                    _buildNotificationCard(notif)),
                                if (index < grouped.length - 1)
                                  const SizedBox(height: 16),
                              ],
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _groupByDate(List<Map<String, dynamic>> items) {
    final Map<String, List<Map<String, dynamic>>> groups = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (var notif in items) {
      final dateStr = notif['created_at'];
      if (dateStr == null) continue;
      final date = DateTime.parse(dateStr).toLocal();
      final dateOnly = DateTime(date.year, date.month, date.day);

      String label;
      if (dateOnly == today) {
        label = 'TODAY';
      } else if (dateOnly == yesterday) {
        label = 'YESTERDAY';
      } else {
        label = DateFormat('dd MMMM yyyy').format(date).toUpperCase();
      }

      groups.putIfAbsent(label, () => []);
      groups[label]!.add(notif);
    }

    return groups.entries
        .map((e) => {'label': e.key, 'items': e.value})
        .toList();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF0F8),
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Icon(Icons.notifications_none_rounded,
                size: 44, color: Color(0xFFBCC0D6)),
          ),
          const SizedBox(height: 20),
          const Text(
            "All clear!",
            style: TextStyle(
              color: Color(0xFF4A4E6B),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "No alerts at the moment.\nYou're doing great with your budget!",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF9CA3C0),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notif) {
    final type = notif['type'] ?? '';
    final icon = _getIcon(type);
    final color = _getColor(type);
    final time = _formatTime(notif['created_at']);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1A2E).withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notif['title'] ?? 'Alert',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notif['message'] ?? '',
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              time,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFFBCC0D6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(String type) {
    if (type.contains('income_expense_critical')) {
      return Icons.error_outline_rounded;
    } else if (type.contains('income_expense_warning')) {
      return Icons.trending_up_rounded;
    } else if (type.contains('budget_exceeded')) {
      return Icons.money_off_rounded;
    } else if (type.contains('budget_warning')) {
      return Icons.account_balance_wallet_rounded;
    }
    return Icons.notifications_active_rounded;
  }

  Color _getColor(String type) {
    if (type.contains('income_expense_critical')) {
      return const Color(0xFFE53935);
    } else if (type.contains('income_expense_warning')) {
      return const Color(0xFFFF9800);
    } else if (type.contains('budget_exceeded')) {
      return const Color(0xFFE53935);
    } else if (type.contains('budget_warning')) {
      return const Color(0xFFFFA726);
    }
    return const Color(0xFF6C63FF);
  }

  String _formatTime(String? timestamp) {
    if (timestamp == null) return "";
    final date = DateTime.parse(timestamp).toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return DateFormat('hh:mm a').format(date);
    }
    return DateFormat('dd MMM').format(date);
  }
}
