import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

enum ConnectionMode { unknown, local, supabase, offline }

class ConnectivityService extends ChangeNotifier {
  ConnectionMode _mode = ConnectionMode.unknown;
  String _activeBaseUrl = _defaultLocalUrl();
  Timer? _checkTimer;
  bool _isChecking = false;

  static String _defaultLocalUrl() {
    if (kIsWeb) return AppConfig.defaultLocalIP;
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:5000';
    } catch (_) {}
    return 'http://127.0.0.1:5000';
  }

  ConnectionMode get mode => _mode;
  String get baseUrl => _activeBaseUrl;
  bool get isLocal => _mode == ConnectionMode.local;
  bool get isSupabase => _mode == ConnectionMode.supabase;
  bool get isOnline => _mode != ConnectionMode.unknown && _mode != ConnectionMode.offline;

  String get statusText {
    switch (_mode) {
      case ConnectionMode.local:
        return 'محلي';
      case ConnectionMode.supabase:
        return 'إنترنت';
      case ConnectionMode.offline:
        return 'غير متصل';
      case ConnectionMode.unknown:
        return 'جاري الاتصال...';
    }
  }

  String get statusIcon {
    switch (_mode) {
      case ConnectionMode.local:
        return '\u{1F7E2}';
      case ConnectionMode.supabase:
        return '\u{1F535}';
      case ConnectionMode.offline:
        return '\u{1F534}';
      case ConnectionMode.unknown:
        return '\u{1F7E1}';
    }
  }

  // ping Flask server to confirm local availability
  Future<bool> isLocalAvailable() async {
    // Order of attempts: localhost → emulator → config IPs
    final candidates = <String>[
      'http://127.0.0.1:5000',
      'http://10.0.2.2:5000',
      ...AppConfig.computerIPs.values,
    ];
    // Deduplicate while preserving order
    final seen = <String>{};
    final unique = <String>[];
    for (final url in candidates) {
      if (seen.add(url)) unique.add(url);
    }
    for (final url in unique) {
      try {
        final response = await http
            .get(Uri.parse('$url/api/stats/today'))
            .timeout(const Duration(seconds: 2));
        if (response.statusCode == 200) {
          _activeBaseUrl = url;
          return true;
        }
      } catch (_) {}
    }
    return false;
  }

  Future<void> detectAndSwitch() async {
    if (_isChecking) return;
    _isChecking = true;

    // Windows desktop: always connect to local Flask, skip network checks
    if (!kIsWeb && Platform.isWindows) {
      _activeBaseUrl = 'http://127.0.0.1:5000';
      _mode = ConnectionMode.local;
      _isChecking = false;
      notifyListeners();
      return;
    }

    if (await isLocalAvailable()) {
      _mode = ConnectionMode.local;
    } else {
      try {
        final result = await InternetAddress.lookup('google.com')
            .timeout(const Duration(seconds: 3));
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          _mode = ConnectionMode.supabase;
        } else {
          _mode = ConnectionMode.offline;
        }
      } catch (_) {
        _mode = ConnectionMode.offline;
      }
    }

    _isChecking = false;
    notifyListeners();
  }

  // TODO: cache last known mode for faster startup
  void startPeriodicCheck() {
    _checkTimer?.cancel();
    _checkTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      detectAndSwitch();
    });
  }

  void stopPeriodicCheck() {
    _checkTimer?.cancel();
    _checkTimer = null;
  }

  @override
  void dispose() {
    stopPeriodicCheck();
    super.dispose();
  }
}
