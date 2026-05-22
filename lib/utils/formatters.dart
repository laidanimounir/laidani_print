import 'package:intl/intl.dart';

class Formatters {
  static String price(double amount) {
    final f = NumberFormat('#,##0', 'ar');
    return '${f.format(amount)} د.ج';
  }

  static String priceShort(double amount) {
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K د.ج';
    }
    return '${amount.toInt()} د.ج';
  }

  static String date(DateTime date) {
    final f = DateFormat('dd/MM/yyyy', 'ar');
    return f.format(date);
  }

  static String dateTime(DateTime date) {
    final f = DateFormat('dd/MM/yyyy HH:mm', 'ar');
    return f.format(date);
  }

  static String time(DateTime date) {
    final f = DateFormat('HH:mm', 'ar');
    return f.format(date);
  }

  static String timeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} يوم';
    return dateTime(date);
  }

  static String fileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  static String phone(String phone) {
    if (phone.length == 10) {
      return '${phone.substring(0, 3)} ${phone.substring(3, 5)} ${phone.substring(5, 7)} ${phone.substring(7)}';
    }
    return phone;
  }

  static String statusText(String status) {
    switch (status) {
      case 'new':
        return 'جديد';
      case 'printing':
        return 'قيد الطباعة';
      case 'done':
        return 'منجز';
      case 'transferred':
        return 'محوّل';
      default:
        return status;
    }
  }

  static String paymentMethodText(String? method) {
    switch (method) {
      case 'cash':
        return 'نقداً';
      case 'card':
        return 'بطاقة';
      case 'free':
        return 'مجاني';
      default:
        return '-';
    }
  }
}
