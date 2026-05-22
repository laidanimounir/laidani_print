// mirrors api_service.dart for remote access
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';
import '../models/order.dart';
import '../models/worker.dart';
import '../models/customer.dart';

class SupabaseService {
  SupabaseClient? _client;
  bool _initialized = false;

  SupabaseClient get client {
    if (_client == null) {
      throw StateError('Supabase not initialized. Call init() first.');
    }
    return _client!;
  }

  Future<void> init() async {
    if (_initialized) return;
    if (AppConfig.supabaseUrl == 'YOUR_SUPABASE_URL') return;
    _client = SupabaseClient(AppConfig.supabaseUrl, AppConfig.supabaseAnonKey);
    _initialized = true;
  }

  bool get isReady => _initialized;

  // ─── Orders ───

  Future<List<Order>> getOrders(String computerId) async {
    final response = await client
        .from('orders')
        .select('*, order_files(*)')
        .eq('computer_id', computerId)
        .order('created_at', ascending: false);
    return (response).map((j) => Order.fromJson(j)).toList();
  }

  Future<Order> submitOrder(Map<String, dynamic> orderPayload) async {
    final response = await client.from('orders').insert(orderPayload).select().single();
    return Order.fromJson(response);
  }

  Future<void> markPrinting(int orderId) async {
    await client.from('orders').update({'status': 'printing'}).eq('id', orderId);
  }

  Future<void> markDone(int orderId) async {
    await client.from('orders').update({'status': 'done'}).eq('id', orderId);
  }

  Future<void> transferOrder(int orderId, String targetPc, String reason) async {
    await client.from('orders').update({
      'computer_id': targetPc,
      'status': 'transferred',
    }).eq('id', orderId);
  }

  Future<void> recordPayment(int orderId, Map<String, dynamic> paymentPayload) async {
    await client.from('orders').update(paymentPayload).eq('id', orderId);
  }

  // ─── Customer ───

  Future<Customer?> getCustomer(String phone) async {
    final response = await client.from('customers').select().eq('phone', phone).maybeSingle();
    if (response != null) {
      return Customer.fromJson(response);
    }
    return null;
  }

  // ─── Stats ───

  // TODO: add connection pooling for high traffic
  Future<Map<String, dynamic>> getTodayStats() async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final response = await client
        .from('orders')
        .select('id, price, page_count, status')
        .gte('created_at', today);
    final orders = (response as List);
    int total = orders.length;
    double revenue = 0;
    int pages = 0;
    for (final order in orders) {
      revenue += (order['price'] as num?)?.toDouble() ?? 0;
      pages += (order['page_count'] as int?) ?? 0;
    }
    return {
      'orders': total,
      'revenue': revenue,
      'pages': pages,
    };
  }

  // ─── Workers ───

  Future<List<Worker>> getWorkers() async {
    final response = await client.from('workers').select();
    return response.map((j) => Worker.fromJson(j)).toList();
  }

  Future<void> addWorker(Map<String, dynamic> workerPayload) async {
    await client.from('workers').insert(workerPayload);
  }

  Future<void> deleteWorker(int workerId) async {
    await client.from('workers').delete().eq('id', workerId);
  }

  RealtimeChannel subscribeToOrders(String computerId, Function(List<Order>) onNewOrders) {
    return client
        .channel('orders-channel')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'orders',
          filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'computer_id', value: computerId),
          callback: (payload) {
            onNewOrders([Order.fromJson(payload.newRecord)]);
          },
        )
        .subscribe();
  }
}
