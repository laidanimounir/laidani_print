import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/order.dart';
import '../../services/api_service.dart';
import '../../utils/formatters.dart';

// large order number readable from distance
class TrackOrderScreen extends StatefulWidget {
  const TrackOrderScreen({super.key});

  @override
  State<TrackOrderScreen> createState() => _TrackOrderScreenState();
}

class _TrackOrderScreenState extends State<TrackOrderScreen> {
  final _orderNumberController = TextEditingController();
  Order? _trackedOrder;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _orderNumberController.dispose();
    super.dispose();
  }

  Future<void> _trackOrder() async {
    final orderNumber = _orderNumberController.text.trim();
    if (orderNumber.isEmpty) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final api = context.read<ApiService>();
      final orders = await api.getAllOrders();
      final found = orders.where((o) => o.orderNumber == orderNumber).toList();

      if (found.isNotEmpty) {
        setState(() => _trackedOrder = found.first);
      } else {
        setState(() => _error = 'لم يتم العثور على الطلب');
      }
    } catch (e) {
      setState(() => _error = 'حدث خطأ أثناء البحث');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.light,
      appBar: AppBar(
        title: const Text('تتبع الطلب'),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _orderNumberController,
                      decoration: const InputDecoration(
                        labelText: 'رقم الطلب',
                        prefixIcon: Icon(Icons.search),
                        hintText: '#',
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _trackOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 20, height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white,
                                ),
                              )
                            : Text(
                                'بحث',
                                style: GoogleFonts.cairo(
                                  fontSize: 16, fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          _error!,
                          style: const TextStyle(color: AppColors.danger),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            if (_trackedOrder != null) ...[
              const SizedBox(height: 24),

              // Status progress
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _stepItem('تم الاستلام', _trackedOrder!.status != 'new', Icons.check_circle),
                      _stepLine(_trackedOrder!.status == 'printing' || _trackedOrder!.status == 'done'),
                      _stepItem('قيد الطباعة', _trackedOrder!.status == 'printing' || _trackedOrder!.status == 'done', Icons.print),
                      _stepLine(_trackedOrder!.status == 'done'),
                      _stepItem('جاهز للاستلام', _trackedOrder!.status == 'done', Icons.celebration),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Order details
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'تفاصيل الطلب',
                        style: GoogleFonts.cairo(
                          fontSize: 16, fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Divider(),
                      _detailRow('رقم الطلب', '#${_trackedOrder!.orderNumber}'),
                      _detailRow('رقم الهاتف', Formatters.phone(_trackedOrder!.customerPhone)),
                      _detailRow('عدد النسخ', '${_trackedOrder!.copies}'),
                      _detailRow('السعر', Formatters.price(_trackedOrder!.price)),
                      _detailRow('تاريخ الطلب', Formatters.dateTime(_trackedOrder!.createdAt)),
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

  Widget _stepItem(String label, bool completed, IconData icon) {
    return Row(
      children: [
        Icon(
          completed ? Icons.check_circle : Icons.radio_button_unchecked,
          color: completed ? AppColors.success : AppColors.textLight,
          size: 28,
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: completed ? FontWeight.w700 : FontWeight.w400,
            color: completed ? AppColors.text : AppColors.textLight,
          ),
        ),
      ],
    );
  }

  Widget _stepLine(bool active) {
    return Container(
      margin: const EdgeInsets.only(left: 13),
      width: 2,
      height: 24,
      color: active ? AppColors.success : AppColors.border,
    );
  }

  Widget _detailRow(String label, String value) {
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
}
