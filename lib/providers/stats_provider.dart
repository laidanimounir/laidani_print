import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class StatsProvider extends ChangeNotifier {
  final ApiService _apiService;

  Map<String, dynamic> _stats = {};
  bool _loading = false;
  String? _error;
  DateTime? _lastFetch;

  StatsProvider(this._apiService);

  Map<String, dynamic> get stats => _stats;
  bool get loading => _loading;
  String? get error => _error;

  int get orders => _stats['orders'] as int? ?? 0;
  int get pages => _stats['pages'] as int? ?? 0;
  double get revenue => (_stats['revenue'] as num?)?.toDouble() ?? 0;
  int get activeWorkers => _stats['active_workers'] as int? ?? 0;

  bool get isCacheValid {
    if (_lastFetch == null) return false;
    return DateTime.now().difference(_lastFetch!).inMinutes < 1;
  }

  // TODO: alert manager when station exceeds 8 orders
  Future<void> loadStats({bool force = false}) async {
    if (!force && isCacheValid) return;

    _loading = true;
    notifyListeners();

    try {
      _stats = await _apiService.getTodayStats();
      _error = null;
      _lastFetch = DateTime.now();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'فشل تحميل الإحصائيات';
    }

    _loading = false;
    notifyListeners();
  }
}
