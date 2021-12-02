import 'package:aether_core/aether_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class Custom {
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

  void progressIndicator(void Function(EasyLoading easyLoading) configure) {
    configure(EasyLoading.instance);
  }

  void error(
      Future<void> Function(dynamic error, {String? title}) notifyError) {
    notifyError = notifyError;
  }

  void info(Future<void> Function(String info, {String? title}) notifyInfo) {
    notifyInfo = notifyInfo;
  }

  void confirm(
      Future<bool> Function(
    String question, {
    String? title,
    String? okButtonTitle,
    String? cancelButtonTitle,
  })
          confirm) {
    askConfirm = confirm;
  }
}
