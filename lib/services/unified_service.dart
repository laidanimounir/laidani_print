// single entry point — caller never knows which backend
import '../config/app_config.dart';
import '../models/order.dart';
import '../models/worker.dart';
import '../models/customer.dart';
import 'api_service.dart';
import 'supabase_service.dart';
import 'connectivity_service.dart';

class UnifiedService {
  final ApiService _apiService;
  final SupabaseService _supabaseService;
  final ConnectivityService _connectivity;

  UnifiedService(this._apiService, this._supabaseService, this._connectivity);

  bool get _useSupabase =>
      AppConfig.supabaseUrl != 'YOUR_SUPABASE_URL' &&
      _supabaseService.isReady &&
      !_connectivity.isLocal;

  Future<T> _call<T>(Future<T> Function() localCall, Future<T> Function() remoteCall) async {
    if (_useSupabase) return remoteCall();
    return localCall();
  }

  // ─── Orders ───

  Future<Order> submitOrder(OrderSubmission data) {
    return _call(
      () => _apiService.submitOrder(data),
      () => _supabaseService.submitOrder(data.toFormData()),
    );
  }

  Future<List<Order>> getOrders(String computerId) {
    return _call(
      () => _apiService.getOrders(computerId),
      () => _supabaseService.getOrders(computerId),
    );
  }

  Future<void> markPrinting(int orderId) {
    return _call(
      () => _apiService.markPrinting(orderId),
      () => _supabaseService.markPrinting(orderId),
    );
  }

  Future<void> markDone(int orderId) {
    return _call(
      () => _apiService.markDone(orderId),
      () => _supabaseService.markDone(orderId),
    );
  }

  Future<void> transferOrder(int orderId, String targetPc, String reason) {
    return _call(
      () => _apiService.transferOrder(orderId, targetPc, reason),
      () => _supabaseService.transferOrder(orderId, targetPc, reason),
    );
  }

  Future<void> recordPayment(int orderId, PaymentData payment) {
    return _call(
      () => _apiService.recordPayment(orderId, payment),
      () => _supabaseService.recordPayment(orderId, payment.toJson()),
    );
  }

  // ─── Customer ───

  Future<Customer?> getCustomer(String phone) {
    return _call(
      () => _apiService.getCustomer(phone),
      () => _supabaseService.getCustomer(phone),
    );
  }

  // ─── Stats ───

  Future<Map<String, dynamic>> getTodayStats() {
    return _call(
      () => _apiService.getTodayStats(),
      () => _supabaseService.getTodayStats(),
    );
  }

  Future<Map<String, dynamic>> getQueueStatus() {
    return _call(
      () => _apiService.getQueueStatus(),
      () => Future.value({'error': 'Queue status unavailable on Supabase'}),
    );
  }

  // ─── Workers ───

  Future<List<Worker>> getWorkers() {
    return _call(
      () => _apiService.getWorkers(),
      () => _supabaseService.getWorkers(),
    );
  }

  Future<void> addWorker(WorkerData data) {
    return _call(
      () => _apiService.addWorker(data),
      () => _supabaseService.addWorker(data.toJson()),
    );
  }

  Future<void> deleteWorker(int workerId) {
    return _call(
      () => _apiService.deleteWorker(workerId),
      () => _supabaseService.deleteWorker(workerId),
    );
  }

  Future<Map<String, dynamic>> getReports({String? range}) {
    return _call(
      () => _apiService.getReports(range: range),
      () => Future.value({'error': 'Reports unavailable on Supabase'}),
    );
  }
}
