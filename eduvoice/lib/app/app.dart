import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../core/theme/theme_controller.dart';
import 'app_launcher.dart';

class ReadyAlertApp extends StatefulWidget {
  const ReadyAlertApp({
    super.key,
    this.showSplash = true,
    this.showLogin = true,
  });

  /// Tests can disable the timed splash while keeping the production flow.
  final bool showSplash;

  /// Tests can jump straight to the shell; production always starts at login.
  final bool showLogin;

  @override
  State<ReadyAlertApp> createState() => _ReadyAlertAppState();
}

class _ReadyAlertAppState extends State<ReadyAlertApp> {
  final ThemeController _themeController = ThemeController();

  @override
  void dispose() {
    _themeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _themeController,
      builder: (context, _) {
        return AppThemeScope(
          controller: _themeController,
          child: MaterialApp(
            title: 'Ready Alert',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: _themeController.mode,
            home: AppLauncher(
              showSplash: widget.showSplash,
              showLogin: widget.showLogin,
            ),
          ),
        );
      },
    );
  }
}
