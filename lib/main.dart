import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';

void main() {
  // Ensure bindings before any platform channel calls
  WidgetsFlutterBinding.ensureInitialized();
  // Lock to portrait for consistent upload form UX
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const LaidaniApp());
}
