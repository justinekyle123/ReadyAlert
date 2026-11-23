import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/database/app_database.dart';
import 'core/firebase/firebase_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await FirebaseBootstrap.initialize();
  } catch (error, stack) {
    debugPrint('Firebase warm-up failed: $error\n$stack');
  }
  try {
    await AppDatabase.configurePlatform();
    await AppDatabase.instance.database;
  } catch (error, stack) {
    // Never leave the app blank: screens report their own database errors.
    debugPrint('Database warm-up failed: $error\n$stack');
  }
  runApp(const ReadyAlertApp());
}
