class Customer {
  final String phone;
  final String? name;
  final int totalOrders;
  final int totalPages;
  final double totalSpent;
  final int discountPercent;
  final bool isVip;
  final DateTime? lastVisit;
  final DateTime? createdAt;

  Customer({
    required this.phone,
    this.name,
    this.totalOrders = 0,
    this.totalPages = 0,
    this.totalSpent = 0,
    this.discountPercent = 0,
    this.isVip = false,
    this.lastVisit,
    this.createdAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    // Phone must be present; empty string means unknown caller
    final phone = json['phone'] as String? ?? '';
    return Customer(
      phone: phone,
      name: json['name'] as String?,
      totalOrders: json['total_orders'] as int? ?? 0,
      totalPages: json['total_pages'] as int? ?? 0,
      totalSpent: (json['total_spent'] as num?)?.toDouble() ?? 0,
      discountPercent: json['discount_percent'] as int? ?? 0,
      isVip: json['is_vip'] == true || json['is_vip'] == 1,
      lastVisit: json['last_visit'] != null
          ? DateTime.tryParse(json['last_visit'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'name': name,
      'total_orders': totalOrders,
      'total_pages': totalPages,
      'total_spent': totalSpent,
      'discount_percent': discountPercent,
      'is_vip': isVip,
      'last_visit': lastVisit?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
