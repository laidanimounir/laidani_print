// TODO: add one-click rebalance across stations
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/app_config.dart';
import '../../config/routes.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/queue_provider.dart';
import '../../providers/stats_provider.dart';
import '../../utils/formatters.dart';
import '../../widgets/connection_indicator.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/stats_card.dart';

class ManagerDashboardScreen extends StatefulWidget {
  const ManagerDashboardScreen({super.key});

  @override
  State<ManagerDashboardScreen> createState() => _ManagerDashboardScreenState();
}

class _ManagerDashboardScreenState extends State<ManagerDashboardScreen> {
  @override
  void initState() {
    super.initState();
    final stats = context.read<StatsProvider>();
    stats.loadStats();
    final queue = context.read<QueueProvider>();
    queue.loadQueueStatus();
    queue.startAutoRefresh();
    final orders = context.read<OrderProvider>();
    orders.loadAllOrders();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stats = context.watch<StatsProvider>();
    final queue = context.watch<QueueProvider>();
    final orders = context.watch<OrderProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Row(
          children: [
            // Sidebar
            Container(
              width: 240,
              color: const Color(0xFF2C1A0E),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          auth.currentWorker?.fullName ?? 'مدير',
                          style: GoogleFonts.cairo(
                            fontSize: 18, fontWeight: FontWeight.w700,
                            color: AppColors.accent,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'مدير النظام',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Colors.white12),
                  _navItem('\u{1F4CA}', 'لوحة التحكم', true, () {}),
                  _navItem('\u{1F465}', 'العمال', false, () {
                    Navigator.pushNamed(context, AppRoutes.managerWorkers);
                  }),
                  _navItem('\u{1F4C8}', 'التقارير', false, () {
                    Navigator.pushNamed(context, AppRoutes.managerReports);
                  }),
                  _navItem('\u{1F464}', 'الزبائن', false, () {
                    Navigator.pushNamed(context, AppRoutes.managerCustomers);
                  }),
                  _navItem('\u{2699}', 'الإعدادات', false, () {
                    Navigator.pushNamed(context, AppRoutes.managerSettings);
                  }),
                  const Spacer(),
                  _navItem('\u{1F6AA}', 'خروج', false, () {
                    auth.logout();
                    Navigator.pushReplacementNamed(context, AppRoutes.login);
                  }),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // Main content
            Expanded(
              child: Column(
                children: [
                  // Top bar
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Text(
                          'لوحة التحكم — ${AppConfig.shopName}',
                          style: GoogleFonts.cairo(
                            fontSize: 20, fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        const ConnectionIndicator(),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Stats cards
                          Row(
                            children: [
                              Expanded(child: StatsCard(
                                label: 'طلبات اليوم', value: '${stats.orders}',
                                icon: Icons.receipt_long, color: AppColors.accent,
                              )),
                              const SizedBox(width: 12),
                              Expanded(child: StatsCard(
                                label: 'الصفحات', value: '${stats.pages}',
                                icon: Icons.description, color: AppColors.info,
                              )),
                              const SizedBox(width: 12),
                              Expanded(child: StatsCard(
                                label: 'الإيرادات', value: Formatters.priceShort(stats.revenue),
                                icon: Icons.monetization_on, color: AppColors.success,
                              )),
                              const SizedBox(width: 12),
                              Expanded(child: StatsCard(
                                label: 'العمال النشطين', value: '${stats.activeWorkers}',
                                icon: Icons.people, color: AppColors.primaryLight,
                              )),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Station loads
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'حالة المحطات',
                                    style: GoogleFonts.cairo(
                                      fontSize: 16, fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ...queue.stationLoads.map((load) {
                                    final count = load['count'] as int;
                                    final maxLoad = 8;
                                    final percent = (count / maxLoad).clamp(0.0, 1.0);
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                'المحطة ${load['station'].toString().replaceAll('PC', '')}',
                                                style: const TextStyle(fontWeight: FontWeight.w600),
                                              ),
                                              const Spacer(),
                                              Text(
                                                '$count طلبات',
                                                style: TextStyle(
                                                  color: percent > 0.75
                                                      ? AppColors.danger
                                                      : percent > 0.5
                                                          ? AppColors.warning
                                                          : AppColors.success,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(4),
                                            child: LinearProgressIndicator(
                                              value: percent,
                                              backgroundColor: AppColors.border,
                                              color: percent > 0.75
                                                  ? AppColors.danger
                                                  : percent > 0.5
                                                      ? AppColors.warning
                                                      : AppColors.success,
                                              minHeight: 8,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Recent orders table
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'آخر الطلبات',
                                    style: GoogleFonts.cairo(
                                      fontSize: 16, fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ...orders.orders.take(10).map((order) =>
                                    ListTile(
                                      dense: true,
                                      title: Text('#${order.orderNumber}'),
                                      subtitle: Text(Formatters.timeAgo(order.createdAt)),
                                      trailing: StatusBadge(status: order.status),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem(String emoji, String label, bool active, VoidCallback onTap) {
    return ListTile(
      leading: Text(emoji, style: const TextStyle(fontSize: 18)),
      title: Text(
        label,
        style: GoogleFonts.cairo(
          fontSize: 14,
          color: active ? AppColors.accent : Colors.white70,
          fontWeight: active ? FontWeight.w700 : FontWeight.w400,
        ),
      ),
      onTap: onTap,
    );
  }
}
