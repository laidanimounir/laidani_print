import 'package:flutter/foundation.dart' show kIsWeb;

class DesktopWindowManager {
  static bool get isDesktop {
    if (kIsWeb) return false;
    try {
      return bool.fromEnvironment('dart.library.io', defaultValue: false);
    } catch (_) {
      return false;
    }
  }

  static Future<void> configureWindow() async {
    if (!isDesktop) return;
    // Windows runner configuration is handled in windows/runner/main.cpp
    // This Dart utility provides runtime window management helpers
  }

  static String get platformName {
    if (kIsWeb) return 'web';
    try {
      return String.fromEnvironment('dart.library.io', defaultValue: 'unknown');
    } catch (_) {
      return 'unknown';
    }
  }
}
