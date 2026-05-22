import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import '../config/app_config.dart';
import '../models/order.dart';
import '../models/worker.dart';
import '../models/customer.dart';
import 'connectivity_service.dart';

class ApiService {
  final ConnectivityService _connectivity;
  late final Dio _dio;

  ApiService(this._connectivity) {
    _dio = Dio(BaseOptions(
      connectTimeout: AppConfig.connectionTimeout,
      receiveTimeout: AppConfig.connectionTimeout,
      headers: {'Accept': 'application/json'},
    ));
    _dio.options.extra['withCredentials'] = true;
  }

  String get _baseUrl => _connectivity.baseUrl;

  // ─── Order Operations ───

  Future<Order> submitOrder(OrderSubmission orderPayload) async {
    try {
      final uri = Uri.parse('$_baseUrl/submit/${orderPayload.computerId}');
      final request = http.MultipartRequest('POST', uri);
      final formFields = orderPayload.toFormData();
      request.fields.addAll(formFields.map((k, v) => MapEntry(k, v.toString())));
      for (int i = 0; i < orderPayload.filePaths.length; i++) {
        request.files.add(await http.MultipartFile.fromPath(
          'files',
          orderPayload.filePaths[i],
          filename: orderPayload.fileNames[i],
        ));
      }
      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        return Order.fromJson(json.decode(response.body));
      }
      throw ApiException('فشل إرسال الطلب', response.statusCode);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('تعذر الاتصال بالخادم', 0);
    }
  }

  Future<List<Order>> getOrders(String computerId) async {
    try {
      final response = await _dio.get('$_baseUrl/api/orders/$computerId');
      final List<dynamic> ordersPayload = response.data is List
          ? response.data
          : (response.data['orders'] ?? []);
      return ordersPayload.map((j) => Order.fromJson(j as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException('فشل تحميل الطلبات', e.response?.statusCode ?? 0);
    }
  }

  Future<List<Order>> getAllOrders() async {
    try {
      final response = await _dio.get('$_baseUrl/api/orders/all');
      final List<dynamic> ordersPayload = response.data is List
          ? response.data
          : (response.data['orders'] ?? []);
      return ordersPayload.map((j) => Order.fromJson(j as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException('فشل تحميل الطلبات', e.response?.statusCode ?? 0);
    }
  }

  Future<void> markPrinting(int orderId) async {
    try {
      await _dio.post('$_baseUrl/worker/print/$orderId');
    } on DioException catch (e) {
      throw ApiException('فشل تحديث حالة الطباعة', e.response?.statusCode ?? 0);
    }
  }

  Future<void> markDone(int orderId) async {
    try {
      await _dio.post('$_baseUrl/worker/done/$orderId');
    } on DioException catch (e) {
      throw ApiException('فشل تحديث حالة الطلب', e.response?.statusCode ?? 0);
    }
  }

  Future<void> transferOrder(int orderId, String targetPc, String reason) async {
    try {
      await _dio.post('$_baseUrl/worker/transfer/$orderId', data: {
        'target_computer': targetPc,
        'reason': reason,
      });
    } on DioException catch (e) {
      throw ApiException('فشل تحويل الطلب', e.response?.statusCode ?? 0);
    }
  }

  Future<void> recordPayment(int orderId, PaymentData paymentPayload) async {
    try {
      await _dio.post('$_baseUrl/worker/payment/$orderId', data: paymentPayload.toJson());
    } on DioException catch (e) {
      throw ApiException('فشل تسجيل الدفع', e.response?.statusCode ?? 0);
    }
  }

  Future<void> duplexStep1(int orderId) async {
    try {
      await _dio.post('$_baseUrl/worker/duplex/step1/$orderId');
    } on DioException catch (e) {
      throw ApiException('فشل طباعة الوجه الأول', e.response?.statusCode ?? 0);
    }
  }

  Future<void> duplexStep2(int orderId) async {
    try {
      await _dio.post('$_baseUrl/worker/duplex/step2/$orderId');
    } on DioException catch (e) {
      throw ApiException('فشل طباعة الوجه الثاني', e.response?.statusCode ?? 0);
    }
  }

  Future<Map<String, dynamic>> duplexStatus(int orderId) async {
    try {
      final response = await _dio.get('$_baseUrl/api/duplex/status/$orderId');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException('فشل الحصول على حالة الطباعة', e.response?.statusCode ?? 0);
    }
  }

  // ─── Customer Operations ───

  Future<Customer?> getCustomer(String phone) async {
    try {
      final response = await _dio.get('$_baseUrl/api/customer/$phone');
      if (response.statusCode == 200 && response.data is Map && response.data['exists'] != false) {
        return Customer.fromJson(response.data as Map<String, dynamic>);
      }
      return null;
    } on DioException {
      return null;
    }
  }

  // ─── Statistics ───

  Future<Map<String, dynamic>> getTodayStats() async {
    try {
      final response = await _dio.get('$_baseUrl/api/stats/today');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException('فشل تحميل الإحصائيات', e.response?.statusCode ?? 0);
    }
  }

  Future<Map<String, dynamic>> getQueueStatus() async {
    try {
      final response = await _dio.get('$_baseUrl/api/queue/status');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException('فشل تحميل حالة الطابور', e.response?.statusCode ?? 0);
    }
  }

  // ─── Authentication ───

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _dio.post('$_baseUrl/api/login', data: {
        'username': username,
        'password': password,
      });
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException('فشل تسجيل الدخول', e.response?.statusCode ?? 0);
    }
  }

  Future<Map<String, dynamic>> checkAuth() async {
    try {
      final response = await _dio.get('$_baseUrl/api/me');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException('غير مصرح', e.response?.statusCode ?? 0);
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('$_baseUrl/api/logout');
    } on DioException {
      // logout should succeed even if server unreachable
    }
  }

  // ─── Manager Operations ───

  Future<List<Worker>> getWorkers() async {
    try {
      final response = await _dio.get('$_baseUrl/api/workers');
      final List<dynamic> workersPayload = response.data is List
          ? response.data
          : (response.data['workers'] ?? []);
      return workersPayload.map((j) => Worker.fromJson(j as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException('فشل تحميل العمال', e.response?.statusCode ?? 0);
    }
  }

  Future<void> addWorker(WorkerData workerPayload) async {
    try {
      await _dio.post('$_baseUrl/manager/workers/add', data: workerPayload.toJson());
    } on DioException catch (e) {
      throw ApiException('فشل إضافة عامل', e.response?.statusCode ?? 0);
    }
  }

  Future<void> deleteWorker(int workerId) async {
    try {
      await _dio.post('$_baseUrl/manager/workers/delete/$workerId');
    } on DioException catch (e) {
      throw ApiException('فشل حذف العامل', e.response?.statusCode ?? 0);
    }
  }

  Future<Map<String, dynamic>> getReports({String? range}) async {
    try {
      final response = await _dio.get('$_baseUrl/api/reports', queryParameters: {
        if (range != null) 'range': range,
      });
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException('فشل تحميل التقارير', e.response?.statusCode ?? 0);
    }
  }

  Future<List<Customer>> getCustomers() async {
    try {
      final response = await _dio.get('$_baseUrl/api/customers');
      final List<dynamic> customersPayload = response.data is List
          ? response.data
          : (response.data['customers'] ?? []);
      return customersPayload.map((j) => Customer.fromJson(j as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException('فشل تحميل الزبائن', e.response?.statusCode ?? 0);
    }
  }

  Future<void> setCustomerDiscount(String phone, int discountPercent) async {
    try {
      await _dio.post('$_baseUrl/manager/customers/discount', data: {
        'phone': phone,
        'discount': discountPercent,
      });
    } on DioException catch (e) {
      throw ApiException('فشل تعيين الخصم', e.response?.statusCode ?? 0);
    }
  }

  Future<void> toggleCustomerVip(String phone) async {
    try {
      await _dio.post('$_baseUrl/manager/customers/vip', data: {'phone': phone});
    } on DioException catch (e) {
      throw ApiException('فشل تحديث VIP', e.response?.statusCode ?? 0);
    }
  }

  Future<List<Map<String, dynamic>>> getBackups() async {
    try {
      final response = await _dio.get('$_baseUrl/api/backups');
      final List<dynamic> backupsPayload = response.data is List
          ? response.data
          : (response.data['backups'] ?? []);
      return backupsPayload.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw ApiException('فشل تحميل النسخ الاحتياطية', e.response?.statusCode ?? 0);
    }
  }

  Future<void> createBackup() async {
    try {
      await _dio.post('$_baseUrl/manager/backups/now');
    } on DioException catch (e) {
      throw ApiException('فشل إنشاء نسخة احتياطية', e.response?.statusCode ?? 0);
    }
  }

  Future<void> saveSettings(Map<String, dynamic> data) async {
    try {
      await _dio.post('$_baseUrl/manager/settings', data: data);
    } on DioException catch (e) {
      throw ApiException('فشل حفظ الإعدادات', e.response?.statusCode ?? 0);
    }
  }

  Future<void> exportReports({String? range}) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/report_${DateTime.now().millisecondsSinceEpoch}.pdf';
      await _dio.download(
        '$_baseUrl/manager/reports/export',
        filePath,
        queryParameters: {if (range != null) 'range': range},
      );
      await OpenFile.open(filePath);
    } on DioException catch (e) {
      throw ApiException('فشل تصدير التقرير', e.response?.statusCode ?? 0);
    }
  }

  Future<void> deleteBackup(String filename) async {
    try {
      await _dio.post('$_baseUrl/manager/backups/delete/$filename');
    } on DioException catch (e) {
      throw ApiException('فشل حذف النسخة الاحتياطية', e.response?.statusCode ?? 0);
    }
  }

  Future<Map<String, dynamic>> optimizeOrder(int orderId, {List<String>? fixes}) async {
    try {
      final response = await _dio.post('$_baseUrl/worker/optimize/$orderId', data: {
        'fixes': fixes ?? [],
      });
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException('فشل تحسين الملف', e.response?.statusCode ?? 0);
    }
  }

  Future<Map<String, dynamic>> redirectOrder(int orderId, String targetPc) async {
    try {
      final response = await _dio.post('$_baseUrl/api/queue/redirect/$orderId/$targetPc');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException('فشل تحويل الطلب', e.response?.statusCode ?? 0);
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, this.statusCode);

  @override
  String toString() => message;
}
