import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/worker.dart';
import '../services/api_service.dart';

enum UserRole { customer, worker, manager }

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService;

  Worker? _currentWorker;
  UserRole _role = UserRole.customer;
  bool _loading = false;
  String? _error;
  String? _customerNumber;
  Timer? _inactivityTimer;

  AuthProvider(this._apiService);

  Worker? get currentWorker => _currentWorker;
  UserRole get role => _role;
  bool get loading => _loading;
  String? get error => _error;

  bool get isManager => _role == UserRole.manager;
  bool get isWorker => _role == UserRole.worker;
  bool get isCustomer => _role == UserRole.customer;
  bool get isLoggedIn => _currentWorker != null;
  String? get customerNumber => _customerNumber;

  Future<bool> login(String username, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final loginResult = await _apiService.login(username, password);
      if (loginResult['success'] == true) {
        _currentWorker = Worker.fromJson(loginResult);
        _role = loginResult['role'] == 'manager' ? UserRole.manager : UserRole.worker;
        await _saveSession();
        _startInactivityTimer();
        _loading = false;
        notifyListeners();
        return true;
      } else {
        _error = loginResult['message'] as String? ?? 'خطأ في تسجيل الدخول';
        _loading = false;
        notifyListeners();
        return false;
      }
    } on ApiException catch (e) {
      _error = e.message;
      _loading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'خطأ في الاتصال بالخادم';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  // session expires after 12h inactivity
  Future<void> loadSavedSession() async {
    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getInt('worker_id');
    final savedRole = prefs.getString('worker_role');

    if (savedId != null && savedRole != null) {
      final savedName = prefs.getString('worker_name');
      final savedUsername = prefs.getString('worker_username');
      final savedPc = prefs.getString('worker_computer');
      final savedTime = prefs.getInt('login_time');

      if (savedTime == null) {
        await _clearSession();
        _loadCustomerNumber(prefs);
        return;
      }
      final elapsed = DateTime.now().millisecondsSinceEpoch - savedTime;
      if (elapsed > 12 * 60 * 60 * 1000) {
        await _clearSession();
        _loadCustomerNumber(prefs);
        return;
      }

      _currentWorker = Worker(
        id: savedId,
        username: savedUsername ?? '',
        fullName: savedName ?? '',
        role: savedRole,
        computerId: savedPc ?? '',
      );
      _role = savedRole == 'manager' ? UserRole.manager : UserRole.worker;
      _startInactivityTimer();
      notifyListeners();
    } else {
      _loadCustomerNumber(prefs);
    }
  }

  void _loadCustomerNumber(SharedPreferences prefs) {
    var number = prefs.getString('customer_number');
    if (number == null) {
      final random = Random();
      final digits = (random.nextInt(9000) + 1000).toString();
      number = 'CUST-$digits';
      prefs.setString('customer_number', number);
    }
    _customerNumber = number;
    notifyListeners();
  }

  void setCustomerRole() {
    _currentWorker = null;
    _role = UserRole.customer;
    notifyListeners();
  }

  Future<void> _saveSession() async {
    if (_currentWorker == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('worker_id', _currentWorker!.id);
    await prefs.setString('worker_role', _currentWorker!.role);
    await prefs.setString('worker_name', _currentWorker!.fullName);
    await prefs.setString('worker_username', _currentWorker!.username);
    await prefs.setString('worker_computer', _currentWorker!.computerId);
    await prefs.setInt('login_time', DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('worker_id');
    await prefs.remove('worker_role');
    await prefs.remove('worker_name');
    await prefs.remove('worker_username');
    await prefs.remove('worker_computer');
    await prefs.remove('login_time');
  }

  void _startInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(const Duration(hours: 12), () {
      logout();
    });
  }

  Future<void> logout() async {
    _currentWorker = null;
    _role = UserRole.customer;
    _inactivityTimer?.cancel();
    await _clearSession();
    notifyListeners();
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    super.dispose();
  }
}
