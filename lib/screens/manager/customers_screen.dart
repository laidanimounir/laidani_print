import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/routes.dart';
import '../../config/theme.dart';
import '../../models/customer.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../utils/formatters.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  List<Customer> _customers = [];
  List<Customer> _topCustomers = [];
  bool _loading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    setState(() => _loading = true);
    try {
      final api = context.read<ApiService>();
      _customers = await api.getCustomers();
      _topCustomers = List.from(_customers);
      _topCustomers.sort((a, b) => b.totalSpent.compareTo(a.totalSpent));
      _topCustomers = _topCustomers.take(10).toList();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل تحميل الزبائن')),
        );
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  List<Customer> get _filteredCustomers {
    if (_searchQuery.isEmpty) return _customers;
    final q = _searchQuery.toLowerCase();
    return _customers.where((c) =>
      c.phone.contains(q) ||
      (c.name?.toLowerCase().contains(q) ?? false)
    ).toList();
  }

  Future<void> _setDiscount(Customer customer) async {
    final api = context.read<ApiService>();
    final messenger = ScaffoldMessenger.of(context);
    final controller = TextEditingController(text: '${customer.discountPercent}');
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('خصم ${customer.phone}', style: GoogleFonts.cairo()),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'نسبة الخصم (%)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, int.tryParse(controller.text)),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );

    if (result != null) {
      try {
        await api.setCustomerDiscount(customer.phone, result);
        _loadCustomers();
      } catch (e) {
        messenger.showSnackBar(
          const SnackBar(content: Text('فشل تعيين الخصم')),
        );
      }
    }
  }

  Future<void> _toggleVip(Customer customer) async {
    try {
      final api = context.read<ApiService>();
      await api.toggleCustomerVip(customer.phone);
      _loadCustomers();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل تحديث VIP')),
        );
      }
    }
  }

  Future<void> _showCustomerOrders(Customer customer) async {
    try {
      final api = context.read<ApiService>();
      final data = await api.getCustomerWithOrders(customer.phone);
      final orders = data['orders'] as List<dynamic>? ?? [];
      final discount = (data['discount_percent'] as num?)?.toInt() ?? 0;
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(customer.phone, style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w700)),
            content: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('مجموع الطلبات: ${data['total_orders'] ?? 0}', style: GoogleFonts.cairo()),
                  Text('المبلغ المدفوع: ${Formatters.priceShort((data['total_spent'] as num?)?.toDouble() ?? 0)}', style: GoogleFonts.cairo()),
                  if (discount > 0)
                    Text('نسبة الخصم: ${data['discount_percent']}%', style: GoogleFonts.cairo()),
                  const Divider(),
                  Text('سجل الطلبات:', style: GoogleFonts.cairo(fontWeight: FontWeight.w700, fontSize: 14)),
                  const SizedBox(height: 8),
                  if (orders.isEmpty)
                    Text('لا توجد طلبات', style: GoogleFonts.cairo(color: AppColors.textLight)),
                  ...orders.take(10).map((o) {
                    final order = o as Map<String, dynamic>;
                    return ListTile(
                      dense: true,
                      title: Text('\u0023${order['order_number'] ?? ''}', style: const TextStyle(fontSize: 13)),
                      subtitle: Text(Formatters.statusText(order['status'] as String? ?? ''), style: const TextStyle(fontSize: 11)),
                      trailing: Text(Formatters.priceShort((order['price'] as num?)?.toDouble() ?? 0), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                    );
                  }),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('\u0625\u063A\u0644\u0627\u0642')),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('\u0641\u0634\u0644 \u062A\u062D\u0645\u064A\u0644 \u062A\u0641\u0627\u0635\u064A\u0644 \u0627\u0644\u0632\u0628\u0648\u0646'), backgroundColor: AppColors.danger),
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
                  _navItem('\u{1F464}', 'الزبائن', true, () {}),
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
                          'الزبائن',
                          style: GoogleFonts.cairo(
                            fontSize: 22, fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        SizedBox(
                          width: 250,
                          child: TextField(
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'بحث...',
                              hintStyle: const TextStyle(color: Colors.white38),
                              prefixIcon: const Icon(Icons.search, color: Colors.white38),
                              filled: true,
                              fillColor: Colors.white12,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            onChanged: (v) => setState(() => _searchQuery = v),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _loading
                        ? const Center(child: CircularProgressIndicator())
                        : Row(
                            children: [
                              // Top customers
                              Expanded(
                                flex: 1,
                                child: Card(
                                  margin: const EdgeInsets.all(8),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '\u{1F3C6} أفضل 10 زبائن',
                                          style: GoogleFonts.cairo(
                                            fontSize: 15, fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const Divider(),
                                        Expanded(
                                          child: ListView.builder(
                                            itemCount: _topCustomers.length,
                                            itemBuilder: (context, index) {
                                              final c = _topCustomers[index];
                                              return ListTile(
                                                dense: true,
                                                leading: CircleAvatar(
                                                  radius: 14,
                                                  backgroundColor: AppColors.accent,
                                                  child: Text('${index + 1}',
                                                    style: const TextStyle(
                                                      fontSize: 12, fontWeight: FontWeight.w700,
                                                      color: AppColors.dark,
                                                    ),
                                                  ),
                                                ),
                                                title: Text(c.phone, style: const TextStyle(fontSize: 13)),
                                                trailing: Text(
                                                  Formatters.priceShort(c.totalSpent),
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // All customers
                              Expanded(
                                flex: 2,
                                child: Card(
                                  margin: const EdgeInsets.all(8),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'جميع الزبائن',
                                          style: GoogleFonts.cairo(
                                            fontSize: 15, fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const Divider(),
                                        Expanded(
                                          child: ListView.builder(
                                            itemCount: _filteredCustomers.length,
                                            itemBuilder: (context, index) {
                                              final c = _filteredCustomers[index];
                                              return ListTile(
                                                dense: true,
                                                onTap: () => _showCustomerOrders(c),
                                                title: Row(
                                                  children: [
                                                    Text(c.phone, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                                    if (c.isVip)
                                                      const Padding(
                                                        padding: EdgeInsets.only(right: 4),
                                                        child: Text('\u{2B50}', style: TextStyle(fontSize: 14)),
                                                      ),
                                                  ],
                                                ),
                                                subtitle: Text(
                                                  '${c.totalOrders} طلبات • ${Formatters.priceShort(c.totalSpent)}',
                                                  style: const TextStyle(fontSize: 11),
                                                ),
                                                trailing: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    if (c.discountPercent > 0)
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                        decoration: BoxDecoration(
                                                          color: AppColors.accent.withValues(alpha: 0.2),
                                                          borderRadius: BorderRadius.circular(4),
                                                        ),
                                                        child: Text(
                                                          '${c.discountPercent}%',
                                                          style: const TextStyle(
                                                            fontSize: 11,
                                                            color: AppColors.accent,
                                                            fontWeight: FontWeight.w700,
                                                          ),
                                                        ),
                                                      ),
                                                    const SizedBox(width: 4),
                                                    IconButton(
                                                      icon: const Icon(Icons.discount, size: 18),
                                                      onPressed: () => _setDiscount(c),
                                                    ),
                                                    IconButton(
                                                      icon: Icon(
                                                        c.isVip ? Icons.star : Icons.star_border,
                                                        size: 18,
                                                        color: c.isVip ? AppColors.accent : null,
                                                      ),
                                                      onPressed: () => _toggleVip(c),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
