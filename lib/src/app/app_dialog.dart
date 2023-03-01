part of 'app.dart';

class AppDialog {
  void showError(dynamic error, {String? title}) {
    if (error == null) return;
    Get.snackbar(
      title ?? 'Error'.tr,
      error.toString().truncate(1000),
      snackPosition: SnackPosition.bottom,
      icon: const Icon(Icons.error, color: Colors.red),
    );
  }

  void showInfo(String info, {String? title}) {
    Get.snackbar(
      title ?? 'Info'.tr,
      info,
      snackPosition: SnackPosition.bottom,
      icon: const Icon(Icons.info, color: Colors.blue),
    );
  }

  Future<bool> showConfirm(
    String question, {
    String? title,
    String? buttonTitle,
    String? cancelButtonTitle,
  }) async {
    final response = await Get.find<DialogService>().showDialog(
      title: title,
      description: question,
      buttonTitle: buttonTitle ?? 'OK'.tr,
      cancelTitle: cancelButtonTitle ?? 'CANCEL'.tr,
      barrierDismissible: true,
    );
    return response?.confirmed ?? false;
  }

  Future<DialogResponse?> show({
    String? title,
    String? description,
    String? cancelTitle,
    Color? cancelTitleColor,
    String? buttonTitle,
    Color? buttonTitleColor,
    bool barrierDismissible = false,
    DialogPlatform? dialogPlatform,
  }) {
    return Get.find<DialogService>().showDialog(
      title: title,
      description: description,
      buttonTitle: buttonTitle ?? 'OK'.tr,
      cancelTitle: cancelTitle,
      buttonTitleColor: buttonTitleColor,
      cancelTitleColor: cancelTitleColor,
      barrierDismissible: barrierDismissible,
      dialogPlatform: dialogPlatform,
    );
  }

  /// Creates a popup with the given widget, a scale animation, and faded background.
  ///
  /// The first generic type argument will be the [DialogResponse]
  /// while the second generic type argument is the [DialogRequest]
  ///
  /// e.g.
  /// ```dart
  /// await App.customDialog<GenericDialogResponse, GenericDialogRequest>();
  /// ```
  ///
  /// Where [GenericDialogResponse] is a defined model response,
  /// and [GenericDialogRequest] is the request model.
  Future<DialogResponse<T>?> showCustom<T, R>({
    dynamic variant,
    String? title,
    String? description,
    bool hasImage = false,
    String? imageUrl,
    bool showIconInMainButton = false,
    String? mainButtonTitle,
    bool showIconInSecondaryButton = false,
    String? secondaryButtonTitle,
    bool showIconInAdditionalButton = false,
    String? additionalButtonTitle,
    bool takesInput = false,
    Color barrierColor = Colors.black54,
    bool barrierDismissible = false,
    String barrierLabel = '',
    R? data,
  }) {
    return Get.find<DialogService>().showCustomDialog<T, R>(
      variant: variant,
      title: title,
      description: description,
      hasImage: hasImage,
      imageUrl: imageUrl,
      showIconInMainButton: showIconInMainButton,
      mainButtonTitle: mainButtonTitle,
      showIconInSecondaryButton: showIconInSecondaryButton,
      secondaryButtonTitle: secondaryButtonTitle,
      showIconInAdditionalButton: showIconInAdditionalButton,
      additionalButtonTitle: additionalButtonTitle,
      takesInput: takesInput,
      barrierColor: barrierColor,
      barrierDismissible: barrierDismissible,
      barrierLabel: barrierLabel,
      data: data,
    );
  }

  void registerCustoms(Map<dynamic, DialogBuilder> builders) {
    Get.find<DialogService>().registerCustomDialogBuilders(builders);
  }

  void registerCustom(dynamic key, DialogBuilder builder) {
    Get.find<DialogService>().registerCustomDialogBuilder(key, builder);
  }
}
