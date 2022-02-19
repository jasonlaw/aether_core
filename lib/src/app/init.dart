import 'package:aether_core/src/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../services/dialog/dialog_service.dart';

class AppInit {
  // Progress indicator config
  void progressIndicator(void Function(EasyLoading easyLoading) configure) {
    configure(EasyLoading.instance);
  }

  // Dialog notification customization
  void error(
      Future<void> Function(dynamic error, {String? title}) notifyError) {
    AppActions.notifyError = notifyError;
  }

  void info(Future<void> Function(String info, {String? title}) notifyInfo) {
    AppActions.notifyInfo = notifyInfo;
  }

  void confirm(
      Future<bool> Function(
    String question, {
    String? title,
    String? okButtonTitle,
    String? cancelButtonTitle,
  })
          confirm) {
    AppActions.askConfirm = confirm;
  }

  // Credential setup
  void silentLogin(Future Function() action) => AppActions.silentLogin = action;

  void login(Future Function(dynamic request) action) =>
      AppActions.login = action;

  void logout(Future Function() action) => AppActions.logout = action;
}

class AppActions {
  static Future Function()? silentLogin;
  static Future Function(dynamic)? login;
  static Future Function()? logout;

  static Future<void> Function(dynamic error, {String? title}) notifyError =
      (dynamic error, {String? title}) async {
    if (error == null) return;
    var errorText = error.toString();
    if (errorText.length > 1000)
      errorText = errorText.substring(0, 1000) + "...";
    Get.snackbar(
      title ?? "Error".tr,
      errorText,
      icon: Icon(Icons.error, color: Colors.red),
    );
  };

  static Future<void> Function(String info, {String? title}) notifyInfo =
      (String info, {String? title}) async {
    Get.snackbar(
      title ?? "Info".tr,
      info,
      icon: Icon(Icons.info, color: Colors.blue),
    );
  };

  static Future<bool> Function(
    String question, {
    String? title,
    String? okButtonTitle,
    String? cancelButtonTitle,
  }) askConfirm = (
    String question, {
    String? title,
    String? okButtonTitle,
    String? cancelButtonTitle,
  }) async {
    var response = await App.dialog.showDialog(
      title: title,
      description: question,
      buttonTitle: okButtonTitle ?? 'Ok'.tr,
      cancelTitle: cancelButtonTitle ?? 'Cancel'.tr,
      cancelTitleColor: Colors.red,
      dialogPlatform: DialogPlatform.Cupertino,
      barrierDismissible: true,
    );
    return response?.confirmed ?? false;
  };
}
