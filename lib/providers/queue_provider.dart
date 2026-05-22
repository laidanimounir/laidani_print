import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class QueueProvider extends ChangeNotifier {
  final ApiService _apiService;

  Map<String, dynamic> _queueStatus = {};
  bool _loading = false;
  String? _error;
  Timer? _refreshTimer;

  QueueProvider(this._apiService);

  Map<String, dynamic> get queueStatus => _queueStatus;
  bool get loading => _loading;
  String? get error => _error;

  List<Map<String, dynamic>> get stationLoads {
    final loads = <Map<String, dynamic>>[];
    _queueStatus.forEach((key, value) {
      if (key.startsWith('PC')) {
        loads.add({'station': key, 'count': value});
      }
    });
    loads.sort((a, b) => (a['count'] as int).compareTo(b['count'] as int));
    return loads;
  }

  String? get overloadedStation {
    for (final load in stationLoads) {
      if ((load['count'] as int) > 6) return load['station'] as String;
    }
    return null;
  }

  String? get leastBusyStation {
    if (stationLoads.isEmpty) return null;
    return stationLoads.first['station'] as String;
  }

  Future<void> loadQueueStatus() async {
    _loading = true;
    notifyListeners();

    try {
      _queueStatus = await _apiService.getQueueStatus();
      _error = null;
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'فشل تحميل حالة الطابور';
    }

    _loading = false;
    notifyListeners();
  }

  void startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      loadQueueStatus();
    });
  }

  void stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  @override
  void dispose() {
    stopAutoRefresh();
    super.dispose();
  }
}
