import 'dart:async';

import 'package:aether_core/src/services/models/overlay_request.dart';
import 'package:aether_core/src/services/models/overlay_response.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'bottom_sheet_ui.dart';

typedef SheetBuilder = Widget Function(
    BuildContext, SheetRequest, void Function(SheetResponse));

/// A service that allows you to show a bottom sheet
class BottomSheetService {
  Map<dynamic, SheetBuilder>? _sheetBuilders;

  void setCustomSheetBuilders(Map<dynamic, SheetBuilder> builders) {
    _sheetBuilders = builders;
  }

  Future<SheetResponse?> showBottomSheet({
    required String title,
    String? description,
    String confirmButtonTitle = 'Ok',
    String? cancelButtonTitle,
    bool enableDrag = true,
    bool barrierDismissible = true,
    bool isScrollControlled = false,
    Duration? exitBottomSheetDuration,
    Duration? enterBottomSheetDuration,
  }) {
    return Get.bottomSheet<SheetResponse?>(
      Material(
        type: MaterialType.transparency,
        child: GeneralBottomSheet(
          title: title,
          description: description ?? '',
          confirmButtonTitle: confirmButtonTitle,
          cancelButtonTitle: cancelButtonTitle,
          onConfirmTapped: () => completeSheet(SheetResponse(confirmed: true)),
          onCancelTapped: () => completeSheet(SheetResponse(confirmed: false)),
        ),
      ),
      backgroundColor: Theme.of(Get.context!).brightness == Brightness.light
          ? Colors.white
          : Colors.grey[800],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      isDismissible: barrierDismissible,
      isScrollControlled: isScrollControlled,
      enableDrag: barrierDismissible && enableDrag,
      exitBottomSheetDuration: exitBottomSheetDuration,
      enterBottomSheetDuration: enterBottomSheetDuration,
    );
  }

  /// Creates a popup with the given widget, a scale animation, and faded background.
  ///
  /// The first generic type argument will be the [BottomSheetResponse]
  /// while the second generic type argument is the [BottomSheetRequest]
  ///
  /// e.g.
  /// ```dart
  /// await _bottomSheetService.showCustomSheet<GenericBottomSheetResponse, GenericBottomSheetRequest>();
  /// ```
  ///
  /// Where [GenericBottomSheetResponse] is a defined model response,
  /// and [GenericBottomSheetRequest] is the request model.
  Future<SheetResponse<T>?> showCustomSheet<T, R>({
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
    bool barrierDismissible = true,
    bool isScrollControlled = false,
    String barrierLabel = '',
    R? data,
    bool enableDrag = true,
    Duration? exitBottomSheetDuration,
    Duration? enterBottomSheetDuration,
  }) {
    assert(
      _sheetBuilders != null,
      '''
      There's no sheet builder supplied for the variant:$variant. If you haven't yet setup your
      custom builder. Please call the setCustomSheetBuilders function on the service and supply
      the UI that you'd like to build for each variant.

      If you have already done that. Make sure that the variant:$variant has a builder associated
      with it.
      ''',
    );

    final sheetBuilder = _sheetBuilders![variant];

    return Get.bottomSheet<SheetResponse<T>>(
      Material(
        type: MaterialType.transparency,
        child: sheetBuilder!(
          Get.context!,
          SheetRequest<R>(
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
          completeSheet,
        ),
      ),
      isDismissible: barrierDismissible,
      isScrollControlled: isScrollControlled,
      enableDrag: barrierDismissible && enableDrag,
      exitBottomSheetDuration: exitBottomSheetDuration,
      enterBottomSheetDuration: enterBottomSheetDuration,
    );
  }

  /// Check if bottomsheet is open
  bool? get isBottomSheetOpen => Get.isBottomSheetOpen;

  /// Completes the dialog and passes the [response] to the caller
  void completeSheet(SheetResponse response) {
    Get.back(result: response);
  }
}
