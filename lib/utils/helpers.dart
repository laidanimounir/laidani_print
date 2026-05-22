import 'dart:math';

class Helpers {
  static double calculatePrice({
    required int pageCount,
    required int copies,
    required String colorMode,
    required String paperSize,
    int discountPercent = 0,
  }) {
    const priceBW = 10.0;
    const priceColor = 30.0;
    const a3Multiplier = 2.0;

    double pagePrice = colorMode == 'color' ? priceColor : priceBW;
    double sizeMultiplier = paperSize == 'A3' ? a3Multiplier : 1.0;

    double total = pageCount * copies * pagePrice * sizeMultiplier;

    if (discountPercent > 0) {
      total = total * (1 - discountPercent / 100);
    }

    return total;
  }

  static String generateLocalOrderNumber() {
    final now = DateTime.now();
    final random = Random().nextInt(9999);
    return '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${random.toString().padLeft(4, '0')}';
  }

  static bool isPdf(String fileName) {
    return fileName.toLowerCase().endsWith('.pdf');
  }

  static bool isImage(String fileName) {
    final ext = fileName.toLowerCase();
    return ext.endsWith('.jpg') || ext.endsWith('.jpeg') ||
           ext.endsWith('.png') || ext.endsWith('.gif') ||
           ext.endsWith('.bmp') || ext.endsWith('.webp');
  }

  static bool isOffice(String fileName) {
    final ext = fileName.toLowerCase();
    return ext.endsWith('.docx') || ext.endsWith('.xlsx') ||
           ext.endsWith('.pptx') || ext.endsWith('.doc') ||
           ext.endsWith('.xls') || ext.endsWith('.ppt');
  }

  static String fileIcon(String fileName) {
    if (isPdf(fileName)) return '📄';
    if (isImage(fileName)) return '🖼️';
    if (isOffice(fileName)) return '📝';
    return '📁';
  }

  static String fileExtension(String fileName) {
    final parts = fileName.split('.');
    return parts.length > 1 ? parts.last.toUpperCase() : '';
  }

  static String statusColor(String status) {
    switch (status) {
      case 'new':
        return '#F5C518';
      case 'printing':
        return '#3498DB';
      case 'done':
        return '#2ECC71';
      case 'transferred':
        return '#95A5A6';
      default:
        return '#95A5A6';
    }
  }

  static bool isValidAlgerianPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'\s+'), '');
    return RegExp(r'^(05|06|07)\d{8}$').hasMatch(cleaned);
  }
}
