import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/app_config.dart';
import '../../config/routes.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _shopNameController = TextEditingController(text: AppConfig.shopName);
  final _sloganController = TextEditingController(text: AppConfig.shopSlogan);
  final _supabaseUrlController = TextEditingController(text: AppConfig.supabaseUrl);
  final _supabaseKeyController = TextEditingController(text: AppConfig.supabaseAnonKey);
  bool _supabaseActive = false;

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
                      style: GoogleFonts.cairo(
                        fontSize: 18, fontWeight: FontWeight.w700,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                  const Divider(color: Colors.white12),
                  _navItem('\u{1F4CA}', 'لوحة التحكم', false, () => Navigator.pushReplacementNamed(context, AppRoutes.managerDashboard)),
                  _navItem('\u{1F465}', 'العمال', false, () => Navigator.pushReplacementNamed(context, AppRoutes.managerWorkers)),
                  _navItem('\u{1F4C8}', 'التقارير', false, () => Navigator.pushReplacementNamed(context, AppRoutes.managerReports)),
                  _navItem('\u{1F464}', 'الزبائن', false, () => Navigator.pushReplacementNamed(context, AppRoutes.managerCustomers)),
                  _navItem('\u{2699}', 'الإعدادات', true, () {}),
                  const Spacer(),
                  _navItem('\u{1F6AA}', 'خروج', false, () {
                    auth.logout();
                    Navigator.pushReplacementNamed(context, AppRoutes.login);
                  }),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الإعدادات',
                      style: GoogleFonts.cairo(
                        fontSize: 22, fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Shop info
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'معلومات المحل',
                              style: GoogleFonts.cairo(
                                fontSize: 16, fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Divider(),
                            TextField(
                              controller: _shopNameController,
                              decoration: const InputDecoration(labelText: 'اسم المحل'),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _sloganController,
                              decoration: const InputDecoration(labelText: 'الشعار'),
                            ),
                            const SizedBox(height: 16),
                            CustomButton(
                              text: 'حفظ',
                              onPressed: () {},
                              type: ButtonType.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Pricing
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'التسعير',
                              style: GoogleFonts.cairo(
                                fontSize: 16, fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Divider(),
                            Text(
                              'أبيض/أسود: ${AppConfig.priceBWPerPage} د.ج للصفحة',
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'ألوان: ${AppConfig.priceColorPerPage} د.ج للصفحة',
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'A3: x${AppConfig.priceA3Multiplier}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Supabase
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Supabase',
                                  style: GoogleFonts.cairo(
                                    fontSize: 16, fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const Spacer(),
                                Switch(
                                  value: _supabaseActive,
                                  activeThumbColor: AppColors.info,
                                  onChanged: (v) => setState(() => _supabaseActive = v),
                                ),
                              ],
                            ),
                            const Divider(),
                            TextField(
                              controller: _supabaseUrlController,
                              decoration: const InputDecoration(labelText: 'Supabase URL'),
                              enabled: _supabaseActive,
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _supabaseKeyController,
                              decoration: const InputDecoration(labelText: 'Supabase Anon Key'),
                              enabled: _supabaseActive,
                              obscureText: true,
                            ),
                            const SizedBox(height: 16),
                            CustomButton(
                              text: 'اختبار الاتصال',
                              onPressed: _supabaseActive ? () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('اختبار الاتصال...')),
                                );
                              } : null,
                              type: ButtonType.outlined,
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
      leading: Text(emoji, style: const TextStyle(fontSize: 18)),
      title: Text(label, style: GoogleFonts.cairo(
        fontSize: 14,
        color: active ? AppColors.accent : Colors.white70,
        fontWeight: active ? FontWeight.w700 : FontWeight.w400,
      )),
      onTap: onTap,
    );
  }

}
