import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';
import 'package:window_manager/window_manager.dart';

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
    await windowManager.ensureInitialized();
    await windowManager.setMinimumSize(const Size(1200, 800));
    await windowManager.setSize(const Size(1200, 800));
    await windowManager.setTitle('LAIDANI PRINT');
    await windowManager.center();
    await windowManager.show();
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
