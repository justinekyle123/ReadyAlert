import 'package:flutter/material.dart';

/// Owns the app-wide light/dark preference.
class ThemeController extends ChangeNotifier {
  ThemeController({ThemeMode initialMode = ThemeMode.light})
    : _mode = initialMode;

  ThemeMode _mode;

  ThemeMode get mode => _mode;

  bool get isDark => _mode == ThemeMode.dark;

  void setMode(ThemeMode mode) {
    if (_mode == mode) {
      return;
    }
    _mode = mode;
    notifyListeners();
  }

  void toggle() => setMode(isDark ? ThemeMode.light : ThemeMode.dark);
}

/// Makes the [ThemeController] available to widgets deep in the tree.
class AppThemeScope extends InheritedNotifier<ThemeController> {
  const AppThemeScope({
    super.key,
    required ThemeController controller,
    required super.child,
  }) : super(notifier: controller);

  static ThemeController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<AppThemeScope>()
        ?.notifier;
  }

  static ThemeController of(BuildContext context) {
    final controller = maybeOf(context);
    assert(controller != null, 'No AppThemeScope found in context.');
    return controller!;
  }
}
