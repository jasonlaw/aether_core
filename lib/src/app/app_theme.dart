import 'package:aether_core/aether_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class AppTheme {
  AppTheme() {
    var lastThemeMode = App.storage.read<String>('AppTheme.mode');
    try {
      if (!lastThemeMode.isNullOrEmpty) {
        _themeMode = ThemeMode.values
            .firstWhere((e) => describeEnum(e) == lastThemeMode);
      }
    } catch (e) {}
  }

  ThemeMode defaultMode = ThemeMode.system;
  ThemeMode? _themeMode;
  ThemeMode get mode => _themeMode ?? defaultMode;
  bool get isDarkMode => Get.isDarkMode;

  void changeThemeMode(ThemeMode themeMode) {
    if (themeMode == defaultMode) {
      App.storage.remove('AppTheme.mode');
      _themeMode = null;
    } else {
      App.storage.write('AppTheme.mode', themeMode.toString().split('.')[1]);
      _themeMode = themeMode;
    }
    Get.changeThemeMode(themeMode);
  }
}
