import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/order.dart';
import '../providers/auth_provider.dart';
import '../utils/formatters.dart';
import 'status_badge.dart';

// compact on mobile, full detail on desktop
class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback? onTap;
  final VoidCallback? onPrint;
  final VoidCallback? onTransfer;
  final VoidCallback? onPayment;

  const OrderCard({
    super.key,
    required this.order,
    this.onTap,
    this.onPrint,
    this.onTransfer,
    this.onPayment,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.watch<AuthProvider>().isWorker || context.watch<AuthProvider>().isManager;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border(
              left: BorderSide(
                color: _statusBorderColor,
                width: 4,
              ),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Text(
                    '#${order.orderNumber}',
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  const Spacer(),
                  StatusBadge(status: order.status, animated: order.status == 'new'),
                ],
              ),
              const SizedBox(height: 8),

              // Details
              _detailRow('\u{1F4C4}', order.fileName, order.fileType),
              if (order.files.length > 1)
                _detailRow('\u{1F4C1}', '${order.files.length} ملفات', null),
              _detailRow(
                '\u{1F4D1}',
                '${order.copies} نسخ',
                order.colorMode == 'color' ? 'ألوان' : 'أبيض/أسود',
              ),
              if (order.isDuplex)
                _detailRow('\u{1F4D6}', 'وجهين', order.duplexStatus == 'step1_done' ? 'تم الوجه الأول' : null),
              _detailRow('\u{1F4F1}', Formatters.phone(order.customerPhone), null),
              if (order.notes != null && order.notes!.isNotEmpty)
                _detailRow('\u{1F4DD}', order.notes!, null),

              const SizedBox(height: 8),

              // Footer
              Row(
                children: [
                  Text(
                    Formatters.price(order.price),
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.accent,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    Formatters.timeAgo(order.createdAt),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),

              // Desktop action buttons
              if (isDesktop && order.status != 'done') ...[
                const Divider(height: 16),
                Row(
                  children: [
                    if (order.status == 'new' && onPrint != null)
                      _actionButton('🖨️', 'طباعة', onPrint!, AppColors.info),
                    if (order.status != 'done' && onTransfer != null)
                      _actionButton('🔄', 'تحويل', onTransfer!, AppColors.warning),
                    if (order.status == 'printing' && onPayment != null)
                      _actionButton('💰', 'دفع', onPayment!, AppColors.success),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String icon, String text, String? subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (subtitle != null)
            Text(
              ' • $subtitle',
              style: const TextStyle(fontSize: 12, color: AppColors.textLight),
            ),
        ],
      ),
    );
  }

  Widget _actionButton(String icon, String label, VoidCallback onTap, Color color) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: OutlinedButton.icon(
          onPressed: onTap,
          icon: Text(icon, style: const TextStyle(fontSize: 16)),
          label: Text(label, style: const TextStyle(fontSize: 12)),
          style: OutlinedButton.styleFrom(
            foregroundColor: color,
            side: BorderSide(color: color),
            padding: const EdgeInsets.symmetric(vertical: 8),
          ),
        ),
      ),
    );
  }

  Color get _statusBorderColor {
    switch (order.status) {
      case 'new':
        return AppColors.accent;
      case 'printing':
        return AppColors.info;
      case 'done':
        return AppColors.success;
      case 'transferred':
        return AppColors.textLight;
      default:
        return AppColors.border;
    }
  }
}
