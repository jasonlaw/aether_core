import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

//import 'package:aether/src/app/app.dart';
import 'package:aether_core/src/services/snackbar/snackbar_service.dart';
import 'package:get/get.dart';

extension AetherSnackbarExtensions on SnackbarService {
  void showError(dynamic error, {String? title}) {
    if (error == null) return;
    var errorText = error.toString();
    if (errorText.length > 500) errorText = errorText.substring(0, 500) + "...";
    this.showSnackbar(
        title: title ?? "Error".tr,
        message: errorText,
        icon: Icon(Icons.report_problem_outlined, color: Colors.red));
  }

  void showInfo(String message, {String? title}) => this.showSnackbar(
      title: title ?? "Info".tr,
      message: message,
      icon: Icon(Icons.info_outline, color: Colors.blue));

  void showWarning(String message, {String? title}) => this.showSnackbar(
      title: title ?? "Warning".tr,
      message: message,
      icon: Icon(Icons.report_outlined, color: Colors.amber));
}
