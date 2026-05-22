// price updates instantly on any option change
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/app_config.dart';
import '../../config/theme.dart';
import '../../models/customer.dart';
import '../../models/file_item.dart';
import '../../models/order.dart';
import '../../services/api_service.dart';
import '../../services/connectivity_service.dart';
import '../../utils/formatters.dart';
import '../../utils/helpers.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/file_picker_zone.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  List<PickedFile> _files = [];
  int _copies = 1;
  String _colorMode = 'bw';
  String _paperSize = 'A4';
  bool _isDuplex = false;
  bool _submitting = false;

  double get _totalPrice {
    if (_files.isEmpty) return 0;
    int totalPages = _files.length;
    return Helpers.calculatePrice(
      pageCount: totalPages,
      copies: _copies,
      colorMode: _colorMode,
      paperSize: _paperSize,
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitOrder() async {
    if (_files.isEmpty) {
      _showError('الرجاء اختيار ملف واحد على الأقل');
      return;
    }

    final phoneError = Validators.phone(_phoneController.text);
    if (phoneError != null) {
      _showError(phoneError);
      return;
    }

    setState(() => _submitting = true);

    try {
      final api = context.read<ApiService>();
      final submission = OrderSubmission(
        computerId: 'PC1',
        customerPhone: _phoneController.text.trim(),
        filePaths: _files.map((f) => f.path).toList(),
        fileNames: _files.map((f) => f.name).toList(),
        copies: _copies,
        colorMode: _colorMode,
        paperSize: _paperSize,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        isDuplex: _isDuplex,
      );

      final order = await api.submitOrder(submission);

      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.customerConfirm,
          arguments: order,
        );
      }
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('حدث خطأ أثناء إرسال الطلب');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.danger,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.light,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppConfig.shopName,
                        style: GoogleFonts.cairo(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        AppConfig.shopSlogan,
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  ConnectionIndicator(),
                ],
              ),
              const SizedBox(height: 24),

              // File picker
              FilePickerZone(
                files: _files,
                onFilesPicked: (files) => setState(() => _files = files),
                onRemoveFile: () {},
                loading: _submitting,
              ),

              if (_files.isNotEmpty) ...[
                const SizedBox(height: 20),

                // Copies
                Row(
                  children: [
                    const Text('\u{1F4D1}', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text('عدد النسخ:', style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    _counterButton(Icons.remove, () {
                      if (_copies > 1) setState(() => _copies--);
                    }),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('$_copies', style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.w800)),
                    ),
                    _counterButton(Icons.add, () {
                      if (_copies < 100) setState(() => _copies++);
                    }),
                  ],
                ),
                const SizedBox(height: 16),

                // Color mode toggle
                Row(
                  children: [
                    Expanded(
                      child: _toggleCard(
                        '\u{25FB}',
                        'أبيض/أسود',
                        _colorMode == 'bw',
                        () => setState(() => _colorMode = 'bw'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _toggleCard(
                        '\u{1F7E1}',
                        'ألوان',
                        _colorMode == 'color',
                        () => setState(() => _colorMode = 'color'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Paper size toggle
                Row(
                  children: [
                    Expanded(
                      child: _toggleCard(
                        '\u{1F4C4}',
                        'A4',
                        _paperSize == 'A4',
                        () => setState(() => _paperSize = 'A4'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _toggleCard(
                        '\u{1F4CB}',
                        'A3',
                        _paperSize == 'A3',
                        () => setState(() => _paperSize = 'A3'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Duplex toggle
                if (_files.any((f) => Helpers.isPdf(f.name)))
                  _toggleRow(
                    '\u{1F4D6}',
                    'وجهين (Recto-Verso)',
                    _isDuplex,
                    (v) => setState(() => _isDuplex = v),
                  ),

                const SizedBox(height: 16),

                // Notes
                TextField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'ملاحظات (اختياري)',
                    prefixIcon: Icon(Icons.edit_note),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),

                // Phone
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'رقم الهاتف',
                    prefixIcon: Icon(Icons.phone),
                    hintText: '05XX XX XX XX',
                  ),
                ),
              ],

              if (_files.isNotEmpty) ...[
                const SizedBox(height: 24),

                // Price
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.border.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'المجموع',
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          color: AppColors.textLight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        Formatters.price(_totalPrice),
                        style: GoogleFonts.cairo(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // TODO: show estimated wait time from queue
        // Submit button
                CustomButton(
                  text: 'إرسال الطلب',
                  icon: Icons.send,
                  loading: _submitting,
                  onPressed: _submitOrder,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _counterButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }

  Widget _toggleCard(String emoji, String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 0 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.cairo(
                color: selected ? Colors.white : AppColors.text,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toggleRow(String emoji, String label, bool value, ValueChanged<bool> onChanged) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Text(label, style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w600)),
        const Spacer(),
        Switch(
          value: value,
          activeThumbColor: AppColors.primary,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
