import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_controller.dart';
import '../../features/auth/application/session_controller.dart';
import '../../features/auth/domain/models/app_user.dart';
import '../../features/volunteers/application/roster_controller.dart';
import 'app_launcher.dart';

class ReadyAlertApp extends StatefulWidget {
  const ReadyAlertApp({
    super.key,
    this.showSplash = true,
    this.showLogin = true,
    this.initialUser,
    this.rosterController,
  });

  /// Tests can disable the timed splash while keeping the production flow.
  final bool showSplash;

  /// Tests can jump straight to the shell; production always starts at login.
  final bool showLogin;

  /// Pre-seeded account for tests that start inside the shell.
  final AppUser? initialUser;

  /// Lets a test observe roster writes through the same controller the UI uses.
  final RosterController? rosterController;

  @override
  State<ReadyAlertApp> createState() => _ReadyAlertAppState();
}

class _ReadyAlertAppState extends State<ReadyAlertApp> {
  final ThemeController _themeController = ThemeController();
  late final RosterController _roster =
      widget.rosterController ?? RosterController();
  late final SessionController _session = SessionController(
    initialUser: widget.initialUser,
  );

  @override
  void dispose() {
    _session.dispose();
    if (widget.rosterController == null) {
      _roster.dispose();
    }
    _themeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _themeController,
      builder: (context, _) {
        // Above MaterialApp so pushed routes such as Settings can read the
        // signed-in account too.
        return SessionScope(
          controller: _session,
          child: RosterScope(
            controller: _roster,
            child: AppThemeScope(
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
            ),
          ),
        );
      },
    );
  }
}
