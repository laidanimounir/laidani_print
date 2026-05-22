// Algerian phone: must start with 05, 06, or 07
class Validators {
  static String? phone(String? value) {
    if (value == null || value.isEmpty) return 'رقم الهاتف مطلوب';
    final cleaned = value.replaceAll(RegExp(r'\s+'), '');
    if (cleaned.length != 10) return 'رقم الهاتف يجب أن يكون 10 أرقام';
    if (!RegExp(r'^(05|06|07)\d{8}$').hasMatch(cleaned)) {
      return 'رقم هاتف غير صالح';
    }
    return null;
  }

  static String? required(String? value, [String field = 'هذا الحقل']) {
    if (value == null || value.trim().isEmpty) return '$field مطلوب';
    return null;
  }

  static String? username(String? value) {
    if (value == null || value.trim().isEmpty) return 'اسم المستخدم مطلوب';
    if (value.length < 3) return 'اسم المستخدم يجب أن يكون 3 أحرف على الأقل';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'كلمة المرور مطلوبة';
    if (value.length < 4) return 'كلمة المرور يجب أن تكون 4 أحرف على الأقل';
    return null;
  }

  static String? copies(String? value) {
    if (value == null || value.isEmpty) return 'عدد النسخ مطلوب';
    final n = int.tryParse(value);
    if (n == null || n < 1) return 'عدد النسخ يجب أن يكون 1 على الأقل';
    if (n > 100) return 'الحد الأقصى 100 نسخة';
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) return null;
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'بريد إلكتروني غير صالح';
    }
    return null;
  }

  static String? discount(String? value) {
    if (value == null || value.isEmpty) return null;
    final n = int.tryParse(value);
    if (n == null || n < 0) return 'يجب أن يكون رقماً موجباً';
    if (n > 100) return 'الحد الأقصى 100%';
    return null;
  }
}
