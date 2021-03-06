import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/overlay_request.dart';
import '../models/overlay_response.dart';
import 'platform_dialog.dart';

typedef DialogBuilder = Widget Function(
    BuildContext, DialogRequest, void Function(DialogResponse));

enum DialogPlatform {
  // ignore: constant_identifier_names
  Cupertino,
  // ignore: constant_identifier_names
  Material,
  // ignore: constant_identifier_names
  Custom,
}

// https://github.com/FilledStacks/stacked/tree/master/packages/stacked_services
/// A DialogService that uses the Get package to show dialogs from the business logic
class DialogService extends GetxService {
  Map<dynamic, DialogBuilder>? _dialogBuilders;

  void registerCustomDialogBuilders(Map<dynamic, DialogBuilder> builders) {
    _dialogBuilders = builders;
  }

  // @Deprecated(
  //     'Prefer to use the StackedServices.navigatorKey instead of using this key. This will be removed in the next major version update for stacked.')
  // get navigatorKey {
  //   return Get.key;
  // }

  /// Check if dialog is open
  bool? get isDialogOpen => Get.isDialogOpen;

  /// Shows a dialog to the user
  ///
  /// It will show a platform specific dialog by default. This can be changed by setting [dialogPlatform]
  Future<DialogResponse?> showDialog({
    String? title,
    String? description,
    String? cancelTitle,
    Color? cancelTitleColor,
    String? buttonTitle,
    Color? buttonTitleColor,
    bool barrierDismissible = false,

    /// Indicates which [DialogPlatform] to show.
    ///
    /// When not set a Platform specific dialog will be shown
    DialogPlatform? dialogPlatform,
  }) {
    //buttonTitle ??= 'Ok'.tr;
    if (dialogPlatform != null) {
      return _showDialog(
        title: title,
        description: description,
        cancelTitle: cancelTitle,
        cancelTitleColor: cancelTitleColor,
        buttonTitle: buttonTitle,
        buttonTitleColor: buttonTitleColor,
        dialogPlatform: dialogPlatform,
        barrierDismissible: barrierDismissible,
      );
    } else {
      return _showDialog(
        title: title,
        description: description,
        cancelTitle: cancelTitle,
        cancelTitleColor: cancelTitleColor,
        buttonTitle: buttonTitle,
        buttonTitleColor: buttonTitleColor,
        dialogPlatform: GetPlatform.isIOS
            ? DialogPlatform.Cupertino
            : DialogPlatform.Material,
        barrierDismissible: barrierDismissible,
      );
    }
  }

  Future<DialogResponse?> _showDialog({
    String? title,
    String? description,
    String? cancelTitle,
    Color? cancelTitleColor,
    String? buttonTitle,
    Color? buttonTitleColor,
    DialogPlatform dialogPlatform = DialogPlatform.Material,
    bool barrierDismissible = false,
  }) {
    var isConfirmationDialog = cancelTitle != null;
    buttonTitle ??= 'OK'.tr;
    return Get.dialog<DialogResponse>(
      PlatformDialog(
        key: const Key('dialog_view'),
        dialogPlatform: dialogPlatform,
        title: title,
        content: description,
        actions: <Widget>[
          if (isConfirmationDialog)
            PlatformButton(
              key: const Key('dialog_touchable_cancel'),
              textChildKey: const Key('dialog_text_cancelButtonText'),
              dialogPlatform: dialogPlatform,
              text: cancelTitle!,
              cancelBtnColor: cancelTitleColor,
              isCancelButton: true,
              onPressed: () {
                completeDialog(
                  DialogResponse(
                    confirmed: false,
                  ),
                );
              },
            ),
          PlatformButton(
            key: const Key('dialog_touchable_confirm'),
            textChildKey: const Key('dialog_text_confirmButtonText'),
            dialogPlatform: dialogPlatform,
            text: buttonTitle,
            confirmationBtnColor: buttonTitleColor,
            onPressed: () {
              completeDialog(
                DialogResponse(
                  confirmed: true,
                ),
              );
            },
          ),
        ],
      ),
      barrierDismissible: barrierDismissible,
    );
  }

  /// Creates a popup with the given widget, a scale animation, and faded background.
  ///
  /// The first generic type argument will be the [DialogResponse]
  /// while the second generic type argument is the [DialogRequest]
  ///
  /// e.g.
  /// ```dart
  /// await _dialogService.showCustomDialog<GenericDialogResponse, GenericDialogRequest>();
  /// ```
  ///
  /// Where [GenericDialogResponse] is a defined model response,
  /// and [GenericDialogRequest] is the request model.
  Future<DialogResponse<T>?> showCustomDialog<T, R>({
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
    //dynamic customData,
    R? data,
  }) {
    assert(
      _dialogBuilders != null,
      'You have to call registerCustomDialogBuilder to use this function. Look at the custom dialog UI section in the stacked_services readme.',
    );

    final customDialogUI = _dialogBuilders![variant];

    assert(
      customDialogUI != null,
      'You have to call registerCustomDialogBuilder to use this function. Look at the custom dialog UI section in the stacked_services readme.',
    );

    return Get.generalDialog<DialogResponse<T>>(
      barrierColor: barrierColor,
      transitionDuration: const Duration(milliseconds: 200),
      barrierDismissible: barrierDismissible,
      barrierLabel: barrierLabel,
      pageBuilder: (BuildContext buildContext, _, __) => SafeArea(
        key: const Key('dialog_view'),
        child: Builder(
          builder: (BuildContext context) => customDialogUI!(
            context,
            DialogRequest<R>(
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
              data: data,
              variant: variant,
            ),
            completeDialog,
          ),
        ),
      ),
    );
  }

  /// Completes the dialog and passes the [response] to the caller
  void completeDialog(DialogResponse response) {
    Get.back(result: response);
  }
}
