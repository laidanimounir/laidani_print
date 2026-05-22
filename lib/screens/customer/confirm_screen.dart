// large order number readable from distance
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/routes.dart';
import '../../config/theme.dart';
import '../../models/order.dart';
import '../../utils/formatters.dart';

class ConfirmScreen extends StatefulWidget {
  final Order order;

  const ConfirmScreen({super.key, required this.order});

  @override
  State<ConfirmScreen> createState() => _ConfirmScreenState();
}

class _ConfirmScreenState extends State<ConfirmScreen> with SingleTickerProviderStateMixin {
  late AnimationController _checkController;
  late Animation<double> _checkAnimation;
  int _countdown = 30;
  Timer? _countdownTimer;
  Timer? _autoNavTimer;

  @override
  void initState() {
    super.initState();
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _checkAnimation = CurvedAnimation(parent: _checkController, curve: Curves.elasticOut);
    _checkController.forward();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() => _countdown--);
      }
    });

    _autoNavTimer = Timer(const Duration(seconds: 30), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.customerTrack);
      }
    });
  }

  @override
  void dispose() {
    _checkController.dispose();
    _countdownTimer?.cancel();
    _autoNavTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.light,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Animated checkmark
              ScaleTransition(
                scale: _checkAnimation,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 50),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'تم استلام طلبك بنجاح!',
                style: GoogleFonts.cairo(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'رقم الطلب',
                style: GoogleFonts.cairo(fontSize: 14, color: AppColors.textLight),
              ),
              const SizedBox(height: 4),
              Text(
                '#${widget.order.orderNumber}',
                style: GoogleFonts.cairo(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                  letterSpacing: 3,
                ),
              ),

              const SizedBox(height: 32),

              // Summary card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _summaryRow('عدد الملفات', '${widget.order.files.length}'),
                      _summaryRow('عدد النسخ', '${widget.order.copies}'),
                      _summaryRow('نوع الطباعة', widget.order.colorMode == 'color' ? 'ألوان' : 'أبيض/أسود'),
                      _summaryRow('حجم الورق', widget.order.paperSize),
                      if (widget.order.isDuplex) _summaryRow('وجهين', 'نعم'),
                      const Divider(height: 24),
                      _summaryRow(
                        'المجموع',
                        Formatters.price(widget.order.price),
                        isBold: true,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Station info
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Text('\u{1F4CD}', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'توجه إلى المحطة ${widget.order.computerId.replaceAll('PC', '')}',
                              style: GoogleFonts.cairo(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'سيتم تحضير طلبك عند وصولك',
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                color: AppColors.textLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Track button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.customerTrack,
                  ),
                  icon: const Icon(Icons.track_changes),
                  label: Text(
                    'تتبع طلبك',
                    style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.dark,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Text(
                'سيتم تحويلك تلقائياً بعد $_countdown ثانية',
                style: GoogleFonts.cairo(fontSize: 13, color: AppColors.textLight),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: AppColors.textLight,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: isBold ? 18 : 15,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
              color: isBold ? AppColors.primary : AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}
