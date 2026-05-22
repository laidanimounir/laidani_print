import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order.dart';

class CacheManager {
  static const _ordersKey = 'cached_orders';
  static const _pendingUploadsKey = 'pending_uploads';

  static Future<void> cacheOrders(List<Order> orders) async {
    final prefs = await SharedPreferences.getInstance();
    final json = orders.map((o) => o.toJson()).toList();
    await prefs.setString(_ordersKey, jsonEncode(json));
  }

  static Future<List<Order>> getCachedOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_ordersKey);
    if (data == null) return [];
    try {
      final List<dynamic> json = jsonDecode(data);
      return json.map((j) => Order.fromJson(j as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> savePendingUpload(Map<String, dynamic> uploadData) async {
    final prefs = await SharedPreferences.getInstance();
    final pending = await getPendingUploads();
    pending.add(uploadData);
    await prefs.setString(_pendingUploadsKey, jsonEncode(pending));
  }

  static Future<List<Map<String, dynamic>>> getPendingUploads() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_pendingUploadsKey);
    if (data == null) return [];
    try {
      return (jsonDecode(data) as List).cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  static Future<void> removePendingUpload(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final pending = await getPendingUploads();
    if (index < pending.length) {
      pending.removeAt(index);
      await prefs.setString(_pendingUploadsKey, jsonEncode(pending));
    }
  }

  static Future<void> clearPendingUploads() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingUploadsKey);
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_ordersKey);
    await prefs.remove(_pendingUploadsKey);
  }
}
