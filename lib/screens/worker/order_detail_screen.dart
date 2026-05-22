// polls every 3s — plays sound on new order
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';
import '../../utils/formatters.dart';
import '../../utils/helpers.dart';
import '../../widgets/status_badge.dart';

class OrderDetailScreen extends StatelessWidget {
  final Order order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: Text('#${order.orderNumber}'),
        backgroundColor: const Color(0xFF2C1A0E),
        actions: [
          StatusBadge(status: order.status),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Files section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الملفات',
                      style: GoogleFonts.cairo(
                        fontSize: 16, fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Divider(),
                    ...order.files.map((f) => _fileRow(f)),
                    if (order.files.isEmpty)
                      _fileRowStatic(order.fileName, order.fileType),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Options card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'خيارات الطباعة',
                      style: GoogleFonts.cairo(
                        fontSize: 16, fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Divider(),
                    _optionRow('عدد النسخ', '${order.copies}'),
                    _optionRow('نوع الطباعة', order.colorMode == 'color' ? 'ألوان' : 'أبيض/أسود'),
                    _optionRow('حجم الورق', order.paperSize),
                    _optionRow('وجهين', order.isDuplex ? 'نعم' : 'لا'),
                    if (order.notes != null && order.notes!.isNotEmpty)
                      _optionRow('ملاحظات', order.notes!),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Customer card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الزبون',
                      style: GoogleFonts.cairo(
                        fontSize: 16, fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Divider(),
                    _optionRow('رقم الهاتف', Formatters.phone(order.customerPhone)),
                    _optionRow('الحالة', Formatters.statusText(order.status)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // AI Suggestions
            if (order.aiSuggestions != null && order.aiSuggestions!.isNotEmpty)
              Card(
                color: AppColors.info.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('\u{1F916}', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 8),
                          Text(
                            'اقتراحات الذكاء الاصطناعي',
                            style: GoogleFonts.cairo(
                              fontSize: 15, fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        order.aiSuggestions!,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),

            // Action buttons
            if (order.status != 'done') ...[
              const SizedBox(height: 24),
              Row(
                children: [
                  if (order.status == 'new')
                    Expanded(
                      child: _actionButton(
                        '\u{1F5A8}', 'طباعة', AppColors.info, () {
                        context.read<OrderProvider>().markPrinting(order.id);
                        Navigator.pop(context);
                      }),
                    ),
                  if (order.status != 'done')
                    Expanded(
                      child: _actionButton(
                        '\u{1F504}', 'تحويل', AppColors.warning, () {}),
                    ),
                  if (order.status == 'printing' || order.status == 'new')
                    Expanded(
                      child: _actionButton(
                        '\u{2705}', 'منجز', AppColors.success, () {
                        context.read<OrderProvider>().markDone(order.id);
                        Navigator.pop(context);
                      }),
                    ),
                ],
              ),

              // Duplex flow
              if (order.isDuplex) ...[
                const SizedBox(height: 16),
                Card(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Text('\u{1F4D6}', style: TextStyle(fontSize: 20)),
                            const SizedBox(width: 8),
                            Text(
                              'طباعة وجهين',
                              style: GoogleFonts.cairo(
                                fontSize: 16, fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final provider = context.read<OrderProvider>();
                              final messenger = ScaffoldMessenger.of(context);
                              await provider.markPrinting(order.id);
                              messenger.showSnackBar(
                                const SnackBar(content: Text('تمت طباعة الوجه الأول. اقلب الورق ثم اضغط متابعة')),
                              );
                            },
                            icon: const Icon(Icons.print),
                            label: Text('الوجه الأول', style: GoogleFonts.cairo()),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.info,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('تمت طباعة الوجه الثاني')),
                              );
                            },
                            icon: const Icon(Icons.print),
                            label: Text('الوجه الثاني (بعد قلب الورق)', style: GoogleFonts.cairo()),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],

            // Payment info
            if (order.paymentStatus == 'paid') ...[
              const SizedBox(height: 16),
              Card(
                color: AppColors.success.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('\u{2705}', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 8),
                          Text(
                            'تم الدفع',
                            style: GoogleFonts.cairo(
                              fontSize: 16, fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _optionRow('طريقة الدفع', Formatters.paymentMethodText(order.paymentMethod)),
                      _optionRow('المبلغ', Formatters.price(order.price)),
                      if (order.changeGiven != null && order.changeGiven! > 0)
                        _optionRow('الباقي', Formatters.price(order.changeGiven!)),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _fileRow(OrderFile file) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(Helpers.fileIcon(file.fileName), style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Expanded(child: Text(file.fileName)),
          Text('${file.pageCount} صفحات'),
        ],
      ),
    );
  }

  Widget _fileRowStatic(String name, String? type) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(Helpers.fileIcon(name), style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Expanded(child: Text(name)),
          Text(type ?? ''),
        ],
      ),
    );
  }

  Widget _optionRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: AppColors.textLight)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _actionButton(String emoji, String label, Color color, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Text(emoji, style: const TextStyle(fontSize: 18)),
        label: Text(label, style: GoogleFonts.cairo(fontSize: 14)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}
