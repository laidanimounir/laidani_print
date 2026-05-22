// polls every 3s — plays sound on new order
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/routes.dart';
import '../../config/theme.dart';
import '../../models/order.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../services/notification_service.dart';
import '../../utils/formatters.dart';
import '../../widgets/connection_indicator.dart';
import '../../widgets/order_card.dart';

class WorkerDashboardScreen extends StatefulWidget {
  const WorkerDashboardScreen({super.key});

  @override
  State<WorkerDashboardScreen> createState() => _WorkerDashboardScreenState();
}

class _WorkerDashboardScreenState extends State<WorkerDashboardScreen> {
  String _activeFilter = 'all';
  String _searchQuery = '';
  final _searchController = TextEditingController();
  int _prevOrderCount = 0;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() {
    final auth = context.read<AuthProvider>();
    if (auth.currentWorker != null) {
      final provider = context.read<OrderProvider>();
      provider.startPolling(auth.currentWorker!.computerId);

      // Check for new orders
      provider.addListener(_onOrdersChanged);
    }
  }

  void _onOrdersChanged() {
    final provider = context.read<OrderProvider>();
    if (provider.hasNewOrder && _prevOrderCount > 0 && provider.orders.length > _prevOrderCount) {
      NotificationService().playNewOrderSound();
    }
    _prevOrderCount = provider.orders.length;
    provider.clearNewOrderFlag();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final orderProvider = context.watch<OrderProvider>();

    final orders = _searchQuery.isEmpty
        ? orderProvider.getOrdersByStatus(_activeFilter)
        : orderProvider.searchOrders(_searchQuery);

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
                          auth.currentWorker?.fullName ?? 'عامل',
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.accent,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          auth.currentWorker?.computerId ?? '',
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Colors.white12),
                  _sidebarItem('\u{1F4CB}', 'طلباتي', true, () {}),
                  _sidebarItem('\u{1F514}', 'الإشعارات', false, () {}),
                  const Spacer(),
                  _sidebarItem('\u{1F6AA}', 'خروج', false, () {
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
                          'طلباتي',
                          style: GoogleFonts.cairo(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        if (orderProvider.orders.where((o) => o.status == 'new').isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${orderProvider.orders.where((o) => o.status == 'new').length}',
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.dark,
                              ),
                            ),
                          ),
                        const Spacer(),
                        const ConnectionIndicator(),
                        const SizedBox(width: 16),
                        Text(
                          Formatters.dateTime(DateTime.now()),
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            color: Colors.white60,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Filters
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _filterTab('الكل', 'all'),
                        _filterTab('جديد', 'new'),
                        _filterTab('طباعة', 'printing'),
                        _filterTab('منجز', 'done'),
                        const Spacer(),
                        SizedBox(
                          width: 200,
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'بحث...',
                              hintStyle: const TextStyle(color: Colors.white38),
                              prefixIcon: const Icon(Icons.search, color: Colors.white38, size: 20),
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
                  const SizedBox(height: 8),

                  // Order list
                  Expanded(
                    child: orderProvider.loading && orderProvider.orders.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : orders.isEmpty
                            ? Center(
                                child: Text(
                                  'لا توجد طلبات',
                                  style: GoogleFonts.cairo(
                                    fontSize: 16,
                                    color: Colors.white38,
                                  ),
                                ),
                              )
                            : RefreshIndicator(
                                onRefresh: () async {
                                  final auth = context.read<AuthProvider>();
                                  if (auth.currentWorker != null) {
                                    await orderProvider.loadOrders(auth.currentWorker!.computerId);
                                  }
                                },
                                child: ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: orders.length,
                                  itemBuilder: (context, index) {
                                    final order = orders[index];
                                    return OrderCard(
                                      order: order,
                                      onTap: () => Navigator.pushNamed(
                                        context,
                                        AppRoutes.orderDetail,
                                        arguments: order,
                                      ),
                                      onPrint: () => _handlePrint(order),
                                      onTransfer: () => _showTransferDialog(order),
                                      onPayment: () => _showPaymentDialog(order),
                                    );
                                  },
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

  Widget _sidebarItem(String emoji, String label, bool active, VoidCallback onTap) {
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

  Widget _filterTab(String label, String filter) {
    final active = _activeFilter == filter;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _activeFilter = filter),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: active ? AppColors.primary : Colors.white12,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: GoogleFonts.cairo(
              color: active ? Colors.white : Colors.white60,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handlePrint(Order order) async {
    try {
      final provider = context.read<OrderProvider>();
      await provider.markPrinting(order.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم بدء الطباعة')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e')),
        );
      }
    }
  }

  void _showTransferDialog(Order order) {
    final pcController = TextEditingController();
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('تحويل الطلب', style: GoogleFonts.cairo()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: pcController,
              decoration: const InputDecoration(labelText: 'المحطة المستهدفة (PC2-PC4)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(labelText: 'السبب'),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final provider = context.read<OrderProvider>();
              await provider.transferOrder(
                order.id,
                pcController.text.trim(),
                reasonController.text.trim(),
              );
            },
            child: const Text('تحويل'),
          ),
        ],
      ),
    );
  }

  void _showPaymentDialog(Order order) {
    final amountController = TextEditingController(text: order.price.toStringAsFixed(0));
    String method = 'cash';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('تسديد المبلغ', style: GoogleFonts.cairo()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'المبلغ المستحق: ${Formatters.price(order.price)}',
                style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'المبلغ المستلم'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _paymentMethod('\u{1F4B5}', 'نقداً', method == 'cash', () => setDialogState(() => method = 'cash')),
                  const SizedBox(width: 8),
                  _paymentMethod('\u{1F4B3}', 'بطاقة', method == 'card', () => setDialogState(() => method = 'card')),
                  const SizedBox(width: 8),
                  _paymentMethod('\u{1F381}', 'مجاني', method == 'free', () => setDialogState(() => method = 'free')),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final provider = context.read<OrderProvider>();
                await provider.recordPayment(
                  order.id,
                  PaymentData(
                    orderId: order.id,
                    paymentMethod: method,
                    amountReceived: double.tryParse(amountController.text) ?? order.price,
                  ),
                );
              },
              child: const Text('تأكيد الدفع'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _paymentMethod(String emoji, String label, bool selected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.gray,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  color: selected ? Colors.white : AppColors.text,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
