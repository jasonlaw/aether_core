import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'dialog_service.dart';

const TextStyle _defaultTextStyle = TextStyle(color: Colors.black);
const TextStyle _cancelTextStyle = TextStyle(color: Colors.red);

class PlatformButton extends StatelessWidget {
  final DialogPlatform? dialogPlatform;
  final String text;
  final void Function() onPressed;
  final bool isCancelButton;
  final Color? confirmationBtnColor;
  final Color? cancelBtnColor;
  final Key? textChildKey;

  const PlatformButton({
    Key? key,
    this.textChildKey,
    this.dialogPlatform,
    this.isCancelButton = false,
    required this.text,
    required this.onPressed,
    this.confirmationBtnColor,
    this.cancelBtnColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    switch (dialogPlatform) {
      case DialogPlatform.Cupertino:
        return CupertinoDialogAction(
          child: Text(text,
              key: textChildKey,
              style: isCancelButton
                  ? cancelBtnColor != null
                      ? TextStyle(color: cancelBtnColor)
                      : _cancelTextStyle
                  : confirmationBtnColor != null
                      ? TextStyle(color: confirmationBtnColor)
                      : null),
          onPressed: onPressed,
        );

      case DialogPlatform.Material:
      default:
        return TextButton(
          child: Text(text,
              key: textChildKey,
              style: isCancelButton
                  ? cancelBtnColor != null
                      ? TextStyle(color: cancelBtnColor)
                      : _cancelTextStyle
                  : confirmationBtnColor != null
                      ? TextStyle(color: confirmationBtnColor)
                      : null),
          onPressed: onPressed,
        );
    }
  }
}

class PlatformDialog extends StatelessWidget {
  /// The title of the dialog is displayed in a large font at the top
  final String? title;

  /// Padding around the title.
  ///
  /// If there is no title, no padding will be provided. Otherwise, this padding
  /// is used.
  ///
  /// This property defaults to providing 24 pixels on the top, left, and right
  /// of the title. If the [content] is not null, then no bottom padding is
  /// provided (but see [contentPadding]). If it _is_ null, then an extra 20
  /// pixels of bottom padding is added to separate the [title] from the
  /// [actions].
  final EdgeInsetsGeometry? titlePadding;

  /// Style for the text in the [title] of this [AlertDialog].
  final TextStyle titleTextStyle;

  /// The content of the dialog is displayed in the center of the dialog
  final String? content;

  /// Padding around the content.

  final EdgeInsetsGeometry contentPadding;

  /// Style for the text in the [content] of this [AlertDialog].
  final TextStyle contentTextStyle;

  /// The set of actions that are displayed at the bottom of the
  /// dialog.
  final List<Widget>? actions;

  final DialogPlatform dialogPlatform;

  final String? cancelText;

  const PlatformDialog({
    Key? key,
    this.title,
    this.titlePadding,
    this.titleTextStyle = _defaultTextStyle,
    this.content,
    this.contentPadding = const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 24.0),
    this.contentTextStyle = _defaultTextStyle,
    this.actions,
    this.dialogPlatform = DialogPlatform.Material,
    this.cancelText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    switch (dialogPlatform) {
      case DialogPlatform.Cupertino:
        return CupertinoAlertDialog(
          title: title != null
              ? Text(
                  title!,
                  key: const Key('dialog_text_title'),
                )
              : null,
          content: content != null
              ? Text(
                  content!,
                  key: const Key('dialog_text_content'),
                )
              : null,
          actions: actions ?? [],
        );
      case DialogPlatform.Material:
      default:
        return AlertDialog(
          titleTextStyle: Theme.of(context).dialogTheme.titleTextStyle,
          contentTextStyle: Theme.of(context).dialogTheme.contentTextStyle,
          title: title != null
              ? Text(
                  title!,
                  key: const Key('dialog_text_title'),
                )
              : null,
          content: content != null
              ? Text(
                  content!,
                  key: const Key('dialog_text_content'),
                )
              : null,
          actions: actions,
        );
    }
  }
}
