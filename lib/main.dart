import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'utils/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DesktopWindowManager.configureWindow();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const LaidaniApp());
}
