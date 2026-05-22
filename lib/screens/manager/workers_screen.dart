// TODO: add one-click rebalance across stations
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/routes.dart';
import '../../config/theme.dart';
import '../../models/worker.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

class WorkersScreen extends StatefulWidget {
  const WorkersScreen({super.key});

  @override
  State<WorkersScreen> createState() => _WorkersScreenState();
}

class _WorkersScreenState extends State<WorkersScreen> {
  List<Worker> _workers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadWorkers();
  }

  Future<void> _loadWorkers() async {
    setState(() => _loading = true);
    try {
      final api = context.read<ApiService>();
      _workers = await api.getWorkers();
    } catch (e) {
      debugPrint('Error loading workers: $e');
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _deleteWorker(Worker worker) async {
    final api = context.read<ApiService>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('حذف العامل', style: GoogleFonts.cairo()),
        content: Text('هل أنت متأكد من حذف ${worker.fullName}؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('حذف')),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await api.deleteWorker(worker.id);
        _loadWorkers();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('فشل حذف العامل')),
          );
        }
      }
    }
  }

  void _showAddDialog() {
    final nameController = TextEditingController();
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    String pcId = 'PC1';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('إضافة عامل جديد', style: GoogleFonts.cairo()),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'الاسم الكامل'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: 'اسم المستخدم'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'كلمة المرور'),
                obscureText: true,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: pcId,
                items: ['PC1', 'PC2', 'PC3', 'PC4'].map((pc) => DropdownMenuItem(
                  value: pc,
                  child: Text('المحطة ${pc.replaceAll('PC', '')}'),
                )).toList(),
                onChanged: (v) => pcId = v ?? 'PC1',
                decoration: const InputDecoration(labelText: 'المحطة'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final api = context.read<ApiService>();
                await api.addWorker(WorkerData(
                  username: usernameController.text.trim(),
                  password: passwordController.text,
                  fullName: nameController.text.trim(),
                  computerId: pcId,
                ));
                _loadWorkers();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('فشل إضافة العامل')),
                  );
                }
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
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
                      style: GoogleFonts.cairo(
                        fontSize: 18, fontWeight: FontWeight.w700,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                  const Divider(color: Colors.white12),
                  _navItem('\u{1F4CA}', 'لوحة التحكم', false, () => Navigator.pushReplacementNamed(context, AppRoutes.managerDashboard)),
                  _navItem('\u{1F465}', 'العمال', true, () {}),
                  _navItem('\u{1F4C8}', 'التقارير', false, () => Navigator.pushReplacementNamed(context, AppRoutes.managerReports)),
                  _navItem('\u{1F464}', 'الزبائن', false, () => Navigator.pushReplacementNamed(context, AppRoutes.managerCustomers)),
                  _navItem('\u{2699}', 'الإعدادات', false, () => Navigator.pushReplacementNamed(context, AppRoutes.managerSettings)),
                  const Spacer(),
                  _navItem('\u{1F6AA}', 'خروج', false, () {
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
                          'إدارة العمال',
                          style: GoogleFonts.cairo(
                            fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: _showAddDialog,
                          icon: const Icon(Icons.add),
                          label: Text('إضافة عامل', style: GoogleFonts.cairo()),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: AppColors.dark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _loading
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _workers.length,
                            itemBuilder: (context, index) {
                              final worker = _workers[index];
                              return Card(
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: AppColors.primary,
                                    child: Text(
                                      worker.fullName.isNotEmpty
                                          ? worker.fullName[0].toUpperCase()
                                          : '?',
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  title: Text(worker.fullName),
                                  subtitle: Text('${worker.computerId} • ${worker.role == 'manager' ? 'مدير' : 'عامل'}'),
                                  trailing: worker.role != 'manager'
                                      ? IconButton(
                                          icon: const Icon(Icons.delete, color: AppColors.danger),
                                          onPressed: () => _deleteWorker(worker),
                                        )
                                      : null,
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
