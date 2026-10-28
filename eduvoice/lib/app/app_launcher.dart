import 'package:flutter/material.dart';

import '../features/auth/presentation/screens/login_screen.dart';
import '../features/splash/presentation/screens/splash_screen.dart';
import 'main_shell.dart';

enum _AppStage { splash, login, shell }

class AppLauncher extends StatefulWidget {
  const AppLauncher({super.key, this.showSplash = true, this.showLogin = true});

  final bool showSplash;
  final bool showLogin;

  @override
  State<AppLauncher> createState() => _AppLauncherState();
}

class _AppLauncherState extends State<AppLauncher> {
  late _AppStage _stage;

  @override
  void initState() {
    super.initState();
    _stage = widget.showSplash
        ? _AppStage.splash
        : widget.showLogin
        ? _AppStage.login
        : _AppStage.shell;
  }

  void _finishSplash() {
    setState(() {
      _stage = widget.showLogin ? _AppStage.login : _AppStage.shell;
    });
  }

  void _finishLogin() {
    setState(() => _stage = _AppStage.shell);
  }

  Widget _buildStage() {
    return switch (_stage) {
      _AppStage.splash => SplashScreen(
        key: const ValueKey('splash'),
        onFinished: _finishSplash,
      ),
      _AppStage.login => LoginScreen(
        key: const ValueKey('login'),
        onSignedIn: _finishLogin,
      ),
      _AppStage.shell => const MainShell(key: ValueKey('main-shell')),
    };
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 650),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      layoutBuilder: (currentChild, previousChildren) {
        return Stack(
          fit: StackFit.expand,
          alignment: Alignment.center,
          children: [...previousChildren, ?currentChild],
        );
      },
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.985, end: 1).animate(animation),
            child: child,
          ),
        );
      },
      child: _buildStage(),
    );
  }
}
