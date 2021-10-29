part of 'app.dart';

class AppCustom {
  Future<void> Function(dynamic error, {String? title}) _notifyError =
      (dynamic error, {String? title}) async {
    if (error == null) return;
    var errorText = error.toString();
    if (errorText.length > 1000)
      errorText = errorText.substring(0, 1000) + "...";
    return Get.snackbar(
      title ?? "Error".tr,
      errorText,
      icon: Icon(Icons.error, color: Colors.red),
    );
  };

  Future<void> Function(String info, {String? title}) _notifyInfo =
      (String info, {String? title}) async {
    return Get.snackbar(
      title ?? "Info".tr,
      info,
      icon: Icon(Icons.info, color: Colors.blue),
    );
  };

  Future<bool> Function(
    String question, {
    String? title,
    String? okButtonTitle,
    String? cancelButtonTitle,
  }) _confirm = (
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
    _notifyError = notifyError;
  }

  void info(Future<void> Function(String info, {String? title}) notifyInfo) {
    _notifyInfo = notifyInfo;
  }

  void confirm(
      Future<bool> Function(
    String question, {
    String? title,
    String? okButtonTitle,
    String? cancelButtonTitle,
  })
          confirm) {
    _confirm = confirm;
  }
}
