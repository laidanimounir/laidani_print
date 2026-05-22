import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../services/api_service.dart';

// optimistic update — UI first, confirm from server
class OrderProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<Order> _orders = [];
  bool _loading = false;
  String? _error;
  Timer? _pollTimer;
  int _lastNewOrderId = 0;
  bool _hasNewOrder = false;

  OrderProvider(this._apiService);

  List<Order> get orders => _orders;
  bool get loading => _loading;
  String? get error => _error;
  bool get hasNewOrder => _hasNewOrder;

  void clearNewOrderFlag() {
    _hasNewOrder = false;
    notifyListeners();
  }

  List<Order> getOrdersByStatus(String status) {
    if (status == 'all') return _orders;
    return _orders.where((o) => o.status == status).toList();
  }

  List<Order> searchOrders(String query) {
    if (query.isEmpty) return _orders;
    final q = query.toLowerCase();
    return _orders.where((o) =>
      o.orderNumber.toLowerCase().contains(q) ||
      o.customerPhone.contains(q)
    ).toList();
  }

  Order? getOrderById(int id) {
    try {
      return _orders.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> loadOrders(String computerId) async {
    _loading = true;
    notifyListeners();

    try {
      _orders = await _apiService.getOrders(computerId);
      if (_orders.isNotEmpty) {
        final maxId = _orders.map((o) => o.id).reduce((a, b) => a > b ? a : b);
        if (maxId > _lastNewOrderId) {
          _hasNewOrder = true;
        }
        _lastNewOrderId = maxId;
      }
      _error = null;
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'خطأ في تحميل الطلبات';
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> loadAllOrders() async {
    _loading = true;
    notifyListeners();

    try {
      _orders = await _apiService.getAllOrders();
      _error = null;
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'خطأ في تحميل الطلبات';
    }

    _loading = false;
    notifyListeners();
  }

  Future<bool> markPrinting(int orderId) async {
    try {
      await _apiService.markPrinting(orderId);
      _updateOrderStatus(orderId, 'printing');
      return true;
    } catch (e) {
      _error = 'فشل تحديث حالة الطباعة';
      notifyListeners();
      return false;
    }
  }

  Future<bool> markDone(int orderId) async {
    try {
      await _apiService.markDone(orderId);
      _updateOrderStatus(orderId, 'done');
      return true;
    } catch (e) {
      _error = 'فشل تحديث حالة الطلب';
      notifyListeners();
      return false;
    }
  }

  Future<bool> transferOrder(int orderId, String targetPc, String reason) async {
    try {
      await _apiService.transferOrder(orderId, targetPc, reason);
      _updateOrderStatus(orderId, 'transferred');
      return true;
    } catch (e) {
      _error = 'فشل تحويل الطلب';
      notifyListeners();
      return false;
    }
  }

  Future<bool> recordPayment(int orderId, PaymentData payment) async {
    try {
      await _apiService.recordPayment(orderId, payment);
      final order = getOrderById(orderId);
      if (order != null) {
        final updated = order.copyWith(
          paymentStatus: 'paid',
          paymentMethod: payment.paymentMethod,
          amountReceived: payment.amountReceived,
          status: 'done',
        );
        _replaceOrder(updated);
      }
      return true;
    } catch (e) {
      _error = 'فشل تسجيل الدفع';
      notifyListeners();
      return false;
    }
  }

  void _updateOrderStatus(int orderId, String newStatus) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index >= 0) {
      _orders[index] = _orders[index].copyWith(status: newStatus);
      notifyListeners();
    }
  }

  void _replaceOrder(Order updated) {
    final index = _orders.indexWhere((o) => o.id == updated.id);
    if (index >= 0) {
      _orders[index] = updated;
      notifyListeners();
    }
  }

  void addOrder(Order order) {
    _orders.insert(0, order);
    _hasNewOrder = true;
    notifyListeners();
  }

  void startPolling(String computerId) {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      loadOrders(computerId);
    });
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}
