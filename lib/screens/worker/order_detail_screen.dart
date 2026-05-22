import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';
import '../../services/api_service.dart';
import '../../utils/formatters.dart';
import '../../utils/helpers.dart';
import '../../widgets/status_badge.dart';

class OrderDetailScreen extends StatefulWidget {
  final Order order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late Order _order;
  String _duplexStatus = 'none';
  bool _duplexStep1Loading = false;
  bool _duplexStep2Loading = false;
  bool _showStep2 = false;
  bool _optimizing = false;
  bool _printingReceipt = false;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    _duplexStatus = _order.duplexStatus;
    if (_duplexStatus == 'step1_done') {
      _showStep2 = true;
    }
  }

  Future<void> _duplexStep1() async {
    setState(() => _duplexStep1Loading = true);
    try {
      final api = context.read<ApiService>();
      await api.duplexStep1(_order.id);
      setState(() {
        _duplexStatus = 'step1_done';
        _showStep2 = true;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تمت طباعة الوجه الأول. اقلب الورق ثم اضغط الوجه الثاني'),
            backgroundColor: AppColors.info,
          ),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _duplexStep1Loading = false);
    }
  }

  Future<void> _duplexStep2() async {
    setState(() => _duplexStep2Loading = true);
    try {
      final api = context.read<ApiService>();
      await api.duplexStep2(_order.id);
      setState(() => _duplexStatus = 'complete');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تمت طباعة الوجه الثاني بنجاح'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _duplexStep2Loading = false);
    }
  }

  Future<void> _printReceipt() async {
    setState(() => _printingReceipt = true);
    try {
      final api = context.read<ApiService>();
      await api.markPrinting(_order.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إرسال أمر طباعة الإيصال'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _printingReceipt = false);
    }
  }

  Future<void> _optimizeOrder() async {
    setState(() => _optimizing = true);
    try {
      final api = context.read<ApiService>();
      final result = await api.optimizeOrder(_order.id);
      if (mounted) {
        _showOptimizeDialog(result);
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _optimizing = false);
    }
  }

  void _showOptimizeDialog(Map<String, dynamic> result) {
    final analysis = result['analysis'] as Map<String, dynamic>?;
    final suggestions = analysis?['suggestions'] as List<dynamic>? ?? [];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.auto_awesome, color: AppColors.accent),
            const SizedBox(width: 8),
            Text(
              'اقتراحات الذكاء الاصطناعي',
              style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (suggestions.isEmpty)
                Text(
                  'لا توجد اقتراحات',
                  style: GoogleFonts.cairo(color: AppColors.textLight),
                ),
              ...suggestions.map((s) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.lightbulb_outline, color: AppColors.accent, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            s.toString(),
                            style: GoogleFonts.cairo(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'تجاهل',
              style: GoogleFonts.cairo(color: AppColors.textLight),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final api = context.read<ApiService>();
                await api.optimizeOrder(
                  _order.id,
                  fixes: suggestions.map((s) => s.toString()).toList(),
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم تطبيق التصحيحات بنجاح'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } on ApiException catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.message), backgroundColor: AppColors.danger),
                  );
                }
              }
            },
            icon: const Icon(Icons.check, size: 18),
            label: Text(
              'تطبيق التصحيح',
              style: GoogleFonts.cairo(),
            ),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          ),
        ],
      ),
    );
  }

  IconData _duplexStepIcon() {
    switch (_duplexStatus) {
      case 'none':
        return Icons.print;
      case 'step1_done':
        return Icons.flip_to_back;
      case 'complete':
        return Icons.check_circle;
      default:
        return Icons.print;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: Text('#${_order.orderNumber}'),
        backgroundColor: const Color(0xFF2C1A0E),
        actions: [
          StatusBadge(status: _order.status),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الملفات',
                      style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const Divider(),
                    ..._order.files.map((f) => _fileRow(f)),
                    if (_order.files.isEmpty)
                      _fileRowStatic(_order.fileName, _order.fileType),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'خيارات الطباعة',
                      style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const Divider(),
                    _optionRow('عدد النسخ', '${_order.copies}'),
                    _optionRow('نوع الطباعة', _order.colorMode == 'color' ? 'ألوان' : 'أبيض/أسود'),
                    _optionRow('حجم الورق', _order.paperSize),
                    _optionRow('وجهين', _order.isDuplex ? 'نعم' : 'لا'),
                    if (_duplexStatus != 'none')
                      _optionRow('حالة الطباعة الثنائية', _duplexStepLabel()),
                    if (_order.notes != null && _order.notes!.isNotEmpty)
                      _optionRow('ملاحظات', _order.notes!),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الزبون',
                      style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const Divider(),
                    _optionRow('رقم الهاتف', Formatters.phone(_order.customerPhone)),
                    _optionRow('الحالة', Formatters.statusText(_order.status)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // AI Suggestions card
            if (_order.aiSuggestions != null && _order.aiSuggestions!.isNotEmpty)
              Card(
                color: AppColors.info.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.auto_awesome, color: AppColors.accent, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'اقتراحات الذكاء الاصطناعي',
                            style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: _optimizing ? null : _optimizeOrder,
                            icon: _optimizing
                                ? const SizedBox(
                                    width: 16, height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.auto_fix_high, size: 18),
                            label: Text(
                              'تحسين',
                              style: GoogleFonts.cairo(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(_order.aiSuggestions!, style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),
            if (_order.status != 'done') ...[
              Row(
                children: [
                  if (_order.status == 'new')
                    Expanded(
                      child: _actionButton(
                        '\u{1F5A8}', 'طباعة', AppColors.info, () {
                        context.read<OrderProvider>().markPrinting(_order.id);
                        Navigator.pop(context);
                      }),
                    ),
                  if (_order.status != 'done')
                    Expanded(
                      child: _actionButton('\u{1F504}', 'تحويل', AppColors.warning, () {}),
                    ),
                  if (_order.status == 'printing' || _order.status == 'new')
                    Expanded(
                      child: _actionButton(
                        '\u{2705}', 'منجز', AppColors.success, () {
                        context.read<OrderProvider>().markDone(_order.id);
                        Navigator.pop(context);
                      }),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              // Print receipt button
              SizedBox(
                width: double.infinity,
                child: _receiptButton(context),
              ),
              // Duplex flow
              if (_order.isDuplex) ...[
                const SizedBox(height: 12),
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
                              style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                            const Spacer(),
                            Icon(_duplexStepIcon(), color: _duplexStatus == 'complete' ? AppColors.success : AppColors.accent),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (_duplexStatus != 'complete') ...[
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _duplexStep1Loading ? null : _duplexStep1,
                              icon: _duplexStep1Loading
                                  ? const SizedBox(
                                      width: 18, height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Icon(Icons.print),
                              label: Text('الوجه الأول', style: GoogleFonts.cairo()),
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.info),
                            ),
                          ),
                        ],
                        if (_showStep2 && _duplexStatus != 'complete') ...[
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _duplexStep2Loading ? null : _duplexStep2,
                              icon: _duplexStep2Loading
                                  ? const SizedBox(
                                      width: 18, height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.flip_to_back),
                              label: Text('الوجه الثاني (بعد قلب الورق)', style: GoogleFonts.cairo()),
                            ),
                          ),
                        ],
                        if (_duplexStatus == 'complete')
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.check_circle, color: AppColors.success),
                                const SizedBox(width: 8),
                                Text(
                                  'اكتملت الطباعة الثنائية',
                                  style: GoogleFonts.cairo(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ],

            if (_order.paymentStatus == 'paid') ...[
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
                          const Icon(Icons.check_circle, color: AppColors.success, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'تم الدفع',
                            style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _optionRow('طريقة الدفع', Formatters.paymentMethodText(_order.paymentMethod)),
                      _optionRow('المبلغ', Formatters.price(_order.price)),
                      if (_order.changeGiven != null && _order.changeGiven! > 0)
                        _optionRow('الباقي', Formatters.price(_order.changeGiven!)),
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

  Widget _receiptButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: _printingReceipt ? null : _printReceipt,
      icon: _printingReceipt
          ? const SizedBox(
              width: 18, height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.receipt_long),
      label: Text('طباعة الإيصال', style: GoogleFonts.cairo()),
    );
  }

  String _duplexStepLabel() {
    switch (_duplexStatus) {
      case 'step1_done':
        return 'الوجه الأول منتهي';
      case 'complete':
        return 'مكتملة';
      default:
        return _duplexStatus;
    }
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
