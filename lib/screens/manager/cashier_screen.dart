import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/routes.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../utils/formatters.dart';
import '../../widgets/stats_card.dart';

class CashierScreen extends StatefulWidget {
  const CashierScreen({super.key});

  @override
  State<CashierScreen> createState() => _CashierScreenState();
}

class _CashierScreenState extends State<CashierScreen> {
  Map<String, dynamic>? _summary;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    setState(() => _loading = true);
    try {
      final api = context.read<ApiService>();
      _summary = await api.getCashierSummary();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل تحميل محضر الكاشير'), backgroundColor: AppColors.danger),
        );
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Row(
          children: [
            Container(
              width: 240,
              color: const Color(0xFF2C1A0E),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      auth.currentWorker?.fullName ?? 'مدير',
                      style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.accent),
                    ),
                  ),
                  const Divider(color: Colors.white12),
                  _navItem('1F4CA', 'لوحة التحكم', false, () => Navigator.pushReplacementNamed(context, AppRoutes.managerDashboard)),
                  _navItem('1F465', 'العمال', false, () => Navigator.pushReplacementNamed(context, AppRoutes.managerWorkers)),
                  _navItem('1F4C8', 'التقارير', false, () => Navigator.pushReplacementNamed(context, AppRoutes.managerReports)),
                  _navItem('1F464', 'الزبائن', false, () => Navigator.pushReplacementNamed(context, AppRoutes.managerCustomers)),
                  _navItem('1F4B0', 'الكاشير', true, () {}),
                  _navItem('2699', 'الإعدادات', false, () => Navigator.pushReplacementNamed(context, AppRoutes.managerSettings)),
                  const Spacer(),
                  _navItem('1F6AA', 'خروج', false, () {
                    auth.logout();
                    Navigator.pushReplacementNamed(context, AppRoutes.login);
                  }),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'محضر الكاشير',
                            style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'اليوم',
                            style: GoogleFonts.cairo(fontSize: 14, color: AppColors.textLight),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: StatsCard(
                                  label: 'المبلغ النقدي',
                                  value: Formatters.price((_summary?['cash_total'] as num?)?.toDouble() ?? 0),
                                  icon: Icons.monetization_on,
                                  color: AppColors.success,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: StatsCard(
                                  label: 'بطاقة',
                                  value: Formatters.price((_summary?['card_total'] as num?)?.toDouble() ?? 0),
                                  icon: Icons.credit_card,
                                  color: AppColors.info,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: StatsCard(
                                  label: 'مجاني',
                                  value: '${_summary?['free_count'] ?? 0}',
                                  icon: Icons.card_giftcard,
                                  color: AppColors.warning,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: StatsCard(
                                  label: 'غير مدفوع',
                                  value: '${_summary?['unpaid_count'] ?? 0}',
                                  icon: Icons.pending,
                                  color: AppColors.danger,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  Text(
                                    'المجموع الكلي',
                                    style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w700),
                                  ),
                                  const Spacer(),
                                  Text(
                                    Formatters.price((_summary?['total_collected'] as num?)?.toDouble() ?? 0),
                                    style: GoogleFonts.cairo(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.primary,
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
    );
  }

  Widget _navItem(String emoji, String label, bool active, VoidCallback onTap) {
    return ListTile(
      leading: Text(String.fromCharCode(int.parse(emoji, radix: 16)), style: const TextStyle(fontSize: 18)),
      title: Text(label, style: GoogleFonts.cairo(fontSize: 14, color: active ? AppColors.accent : Colors.white70, fontWeight: active ? FontWeight.w700 : FontWeight.w400)),
      onTap: onTap,
    );
  }
}
