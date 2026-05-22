class Worker {
  final int id;
  final String username;
  final String fullName;
  final String role;
  final String computerId;
  final bool isActive;
  final int? ordersToday;

  Worker({
    required this.id,
    required this.username,
    required this.fullName,
    required this.role,
    required this.computerId,
    this.isActive = true,
    this.ordersToday,
  });

  factory Worker.fromJson(Map<String, dynamic> payload) {
    final roleValue = payload['role'] as String? ?? 'worker';
    // Validate role early to avoid silent defaults in UI
    if (roleValue != 'worker' && roleValue != 'manager') {
      throw ArgumentError('Invalid worker role: $roleValue. Expected worker or manager.');
    }
    return Worker(
      id: payload['id'] as int,
      username: payload['username'] as String? ?? '',
      fullName: payload['full_name'] as String? ?? '',
      role: roleValue,
      computerId: payload['computer_id'] as String? ?? '',
      isActive: payload['is_active'] == true || payload['is_active'] == 1,
      ordersToday: payload['orders_today'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'full_name': fullName,
      'role': role,
      'computer_id': computerId,
      'is_active': isActive,
      'orders_today': ordersToday,
    };
  }
}

class WorkerData {
  final String username;
  final String password;
  final String fullName;
  final String computerId;

  WorkerData({
    required this.username,
    required this.password,
    required this.fullName,
    required this.computerId,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'full_name': fullName,
      'computer_id': computerId,
    };
  }
}
