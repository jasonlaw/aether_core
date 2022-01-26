import 'package:aether_core/aether_core.dart';
import 'package:flutter/material.dart';

class AppThemeSheet extends StatelessWidget {
  final darkMode = Get.isDarkMode.obs;
  final systemEnabled = (App.theme.defaultMode == ThemeMode.system).obs;
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Material(
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (systemEnabled.isTrue)
                ListTile(
                  title: Text('System'.tr),
                  leading: Icon(Icons.settings_brightness),
                  trailing: getThemeIcon(ThemeMode.system),
                  onTap: () => changeThemeMode(ThemeMode.system),
                ),
              ListTile(
                title: Text('Light'.tr),
                leading: Icon(Icons.light_mode),
                trailing: getThemeIcon(ThemeMode.light),
                onTap: () => changeThemeMode(ThemeMode.light),
              ),
              ListTile(
                title: Text('Dark'.tr),
                leading: Icon(Icons.dark_mode),
                trailing: getThemeIcon(ThemeMode.dark),
                onTap: () => changeThemeMode(ThemeMode.dark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Icon getThemeIcon(ThemeMode themeMode) {
    var checked = false;
    if (systemEnabled.isTrue) {
      if (themeMode == ThemeMode.light) {
        checked = App.theme.mode == ThemeMode.light;
      } else if (themeMode == ThemeMode.dark) {
        checked = App.theme.mode == ThemeMode.dark;
      } else {
        checked = App.theme.mode == ThemeMode.system;
      }
    } else {
      if (themeMode == ThemeMode.light) {
        checked = darkMode.isFalse;
      } else if (themeMode == ThemeMode.dark) {
        checked = darkMode.isTrue;
      }
    }
    return checked
        ? Icon(Icons.check_circle_outline)
        : Icon(Icons.circle_outlined);
  }

  void changeThemeMode(ThemeMode themeMode) {
    if (themeMode == App.theme.mode) return;
    App.theme.changeThemeMode(themeMode);
    if (systemEnabled.isTrue) {
      darkMode(Get.isPlatformDarkMode);
      //WidgetsBinding.instance.window.platformBrightness
      systemEnabled.refresh();
    } else {
      darkMode(themeMode == ThemeMode.dark);
    }
  }
}
