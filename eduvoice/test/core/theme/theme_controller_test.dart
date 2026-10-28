import 'package:eduvoice/core/theme/app_palette.dart';
import 'package:eduvoice/core/theme/app_theme.dart';
import 'package:eduvoice/core/theme/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('theme controller toggles between light and dark', () {
    final controller = ThemeController();
    addTearDown(controller.dispose);

    var notifications = 0;
    controller.addListener(() => notifications++);

    expect(controller.mode, ThemeMode.light);
    expect(controller.isDark, isFalse);

    controller.toggle();
    expect(controller.mode, ThemeMode.dark);
    expect(controller.isDark, isTrue);

    controller.toggle();
    expect(controller.mode, ThemeMode.light);

    // Setting the current mode again is a no-op.
    controller.setMode(ThemeMode.light);
    expect(notifications, 2);
  });

  test('light and dark themes expose their own palette', () {
    expect(AppTheme.light.extension<AppPalette>(), same(AppPalette.light));
    expect(AppTheme.dark.extension<AppPalette>(), same(AppPalette.dark));

    expect(AppTheme.dark.brightness, Brightness.dark);
    expect(AppTheme.dark.scaffoldBackgroundColor, AppPalette.dark.background);
    expect(AppTheme.dark.colorScheme.onSurface, AppPalette.dark.textPrimary);
  });
}
