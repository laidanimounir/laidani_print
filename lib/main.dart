import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app.dart';
import 'utils/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DesktopWindowManager.configureWindow();
  await initializeDateFormatting('ar', null);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const LaidaniApp());
}
