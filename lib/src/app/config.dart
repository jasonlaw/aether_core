import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../services/dialog/dialog_service.dart';
import 'app.dart';

class AppConfig {
  // Progress indicator config
  void progressIndicator(
    void Function(EasyLoading easyLoading) configure,
  ) =>
      configure(EasyLoading.instance);

  void dialog(
    void Function(DialogDefaultSettings settings) configure,
  ) =>
      configure(AppActions.dialogSettings);

  void notification(
    void Function(NotificationDefaultSettings settings) configure,
  ) =>
      configure(AppActions.notifySettings);

  // Credential setup
  void silentLogin(Future Function() action) => AppActions.silentLogin = action;

  void login(Future Function(dynamic request) action) =>
      AppActions.login = action;

  void logout(Future Function() action) => AppActions.logout = action;
}

class DialogDefaultSettings {
  String? buttonTitle;
  String? cancelTitle;
  Color? buttonTitleColor;
  Color? cancelTitleColor;
  DialogPlatform? dialogPlatform;
}

class NotificationDefaultSettings {
  String? errorTitle;
  String? infoTitle;
  Icon errorIcon = const Icon(Icons.error, color: Colors.red);
  Icon infoIcon = const Icon(Icons.info, color: Colors.blue);
  SnackPosition snackPosition = SnackPosition.BOTTOM;
}

class AppActions {
  static Future Function()? silentLogin;
  static Future Function(dynamic)? login;
  static Future Function()? logout;
  static DialogDefaultSettings dialogSettings = DialogDefaultSettings();
  static NotificationDefaultSettings notifySettings =
      NotificationDefaultSettings();

  static void resetDefaultLoading() {
    EasyLoading.instance
      ..displayDuration = const Duration(milliseconds: 2000)
      ..indicatorType = EasyLoadingIndicatorType.fadingCircle
      ..loadingStyle = EasyLoadingStyle.dark
      ..indicatorSize = 50.0
      ..radius = 10.0
      ..progressColor = Colors.green
      ..backgroundColor = Colors.transparent
      ..indicatorColor = Colors.green
      ..textColor = Colors.transparent
      ..maskColor = Colors.blue.withOpacity(0.5)
      ..userInteractions = false;
    // ..customAnimation = CustomAnimation();
  }
}
