import 'dart:async';

import 'package:aether_core/src/services/dialog/platform_dialog.dart';
import 'package:aether_core/src/services/models/overlay_request.dart';
import 'package:aether_core/src/services/models/overlay_response.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

typedef DialogBuilder = Widget Function(
    BuildContext, DialogRequest, void Function(DialogResponse));

enum DialogPlatform {
  Cupertino,
  Material,
  Custom,
}

// https://github.com/FilledStacks/stacked/tree/master/packages/stacked_services
/// A DialogService that uses the Get package to show dialogs from the business logic
class DialogService {
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
        buttonTitle: buttonTitle,
        dialogPlatform: dialogPlatform,
        barrierDismissible: barrierDismissible,
      );
    } else {
      var _dialogType = GetPlatform.isAndroid
          ? DialogPlatform.Material
          : DialogPlatform.Cupertino;
      return _showDialog(
        title: title,
        description: description,
        cancelTitle: cancelTitle,
        cancelTitleColor: cancelTitleColor,
        buttonTitle: buttonTitle,
        buttonTitleColor: buttonTitleColor,
        dialogPlatform: _dialogType,
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
    buttonTitle ??= 'Ok'.tr;
    return Get.dialog<DialogResponse>(
      PlatformDialog(
        key: Key('dialog_view'),
        dialogPlatform: dialogPlatform,
        title: title,
        content: description,
        actions: <Widget>[
          if (isConfirmationDialog)
            PlatformButton(
              key: Key('dialog_touchable_cancel'),
              textChildKey: Key('dialog_text_cancelButtonText'),
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
            key: Key('dialog_touchable_confirm'),
            textChildKey: Key('dialog_text_confirmButtonText'),
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
        key: Key('dialog_view'),
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
      // TODO: Add configurable transition builders to set  from the outside as well
      // transitionBuilder: (context, animation, _, child) {
      //   return ScaleTransition(
      //     scale: CurvedAnimation(
      //       parent: animation,
      //       curve: Curves.decelerate,
      //     ),
      //     child: child,
      //   );
      // },
    );
  }

  /// Shows a confirmation dialog with title and description
  Future<bool> showConfirmationDialog({
    String? title,
    String? description,
    String? cancelTitle,
    String? confirmationTitle,
    bool barrierDismissible = false,

    /// Indicates which [DialogPlatform] to show.
    ///
    /// When not set a Platform specific dialog will be shown
    DialogPlatform? dialogPlatform,
  }) async {
    final response = await showDialog(
      title: title,
      description: description,
      buttonTitle: confirmationTitle ?? 'Ok'.tr,
      cancelTitle: cancelTitle ?? 'Cancel'.tr,
      dialogPlatform: dialogPlatform,
      barrierDismissible: barrierDismissible,
    );

    return response?.confirmed ?? false;
  }

  /// Completes the dialog and passes the [response] to the caller
  void completeDialog(DialogResponse response) {
    Get.back(result: response);
  }
}
