import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/routes.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

class QrScreen extends StatefulWidget {
  const QrScreen({super.key});

  @override
  State<QrScreen> createState() => _QrScreenState();
}

class _QrScreenState extends State<QrScreen> {
  final List<String> _stations = ['PC1', 'PC2', 'PC3', 'PC4'];

  Future<void> _regenerateQr(String pcId) async {
    try {
      final api = context.read<ApiService>();
      await api.regenerateQr(pcId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم إعادة توليد QR للمحطة ${pcId.replaceAll('PC', '')}'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل إعادة توليد QR'), backgroundColor: AppColors.danger),
        );
      }
    }
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
                  _navItem('1F4F7', 'رموز QR', true, () {}),
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
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Text(
                          'إدارة رموز QR',
                          style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.9,
                      ),
                      itemCount: _stations.length,
                      itemBuilder: (context, index) {
                        final pcId = _stations[index];
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.qr_code, size: 48, color: AppColors.primary),
                                const SizedBox(height: 8),
                                Text(
                                  'المحطة ${pcId.replaceAll('PC', '')}',
                                  style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w700),
                                ),
                                Text(pcId, style: GoogleFonts.cairo(color: AppColors.textLight, fontSize: 12)),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.refresh, color: AppColors.info),
                                      tooltip: 'إعادة توليد',
                                      onPressed: () => _regenerateQr(pcId),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.print, color: AppColors.accent),
                                      tooltip: 'طباعة',
                                      onPressed: () {},
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
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
      leading: Text(String.fromCharCode(int.parse(emoji, radix: 16)), style: const TextStyle(fontSize: 18)),
      title: Text(label, style: GoogleFonts.cairo(fontSize: 14, color: active ? AppColors.accent : Colors.white70, fontWeight: active ? FontWeight.w700 : FontWeight.w400)),
      onTap: onTap,
    );
  }
}
