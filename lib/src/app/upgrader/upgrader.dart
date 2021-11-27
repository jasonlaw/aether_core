import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:version/version.dart';

import '../../services.dart';
import '../../app.dart';

/// Signature of callbacks that have no arguments and return bool.
typedef BoolCallback = bool Function();

/// A singleton class to configure the upgrade dialog.
class Upgrader {
  static final Upgrader _singleton = new Upgrader._internal();

  /// The later button title, which defaults to ```Later```
  String? buttonTitleLater; // = 'Later'.toUpperCase();

  /// The update button title, which defaults to ```Update Now```
  String? buttonTitleUpdate; // = 'Update Now'.toUpperCase();

  /// Days until alerting user again
  int daysToAlertAgain = 0;

  /// For debugging, always force the upgrade to be available.
  bool debugDisplayAlways = false;

  /// For debugging, display the upgrade at least once once.
  bool debugDisplayOnce = false;

  /// Enable print statements for debugging.
  bool debugLogging = false;

  /// = 'Would you like to update it now?';
  String? prompt;

  /// The alert dialog title
  String? title; // = 'Update App?';

  /// Called when the ignore button is tapped or otherwise activated.
  /// Return false when the default behavior should not execute.
  BoolCallback? onIgnore;

  /// Called when the ignore button is tapped or otherwise activated.
  /// Return false when the default behavior should not execute.
  BoolCallback? onLater;

  /// Called when the ignore button is tapped or otherwise activated.
  /// Return false when the default behavior should not execute.
  BoolCallback? onUpdate;

  /// To upgrade version, need to be provided in [updateVersionInfo] callback.
  String? updateVersion;

  /// To not show the Later button if force upgrade
  bool forceUpdate = false;

  bool _displayed = false;
  bool _initCalled = false;

  //String _installedVersion;
  //String _appStoreVersion;
  String? _appStoreListingURL;
  String? _updateAvailable;
  DateTime? _lastTimeAlerted;
  String? _lastVersionAlerted;
  bool _hasAlerted = false;
  //UpdateVersionInfoCallback _updateVersionInfo;

  factory Upgrader() {
    return _singleton;
  }

  Upgrader._internal();

  Future<bool> initialize() async {
    if (_initCalled) {
      return true;
    }

    _initCalled = true;

    _appStoreListingURL = App.settings.appStoreURL();

    await _getSavedPrefs();

    return true;
  }

  String getMessage() {
    return '%s %s - A new version is available now! Please update to enjoy the latest features.'
        .trArgs([App.name, this.updateVersion!]);
    //return 'A new version of ${App.name} is available! Version ${this.updateVersion} is now available-you have ${App.version}.';
  }

  String getTitle() {
    return this.title ?? 'Update App?'.tr;
  }

  String getPrompt() {
    return this.prompt ?? 'Would you like to update it now?'.tr;
  }

  String getButtonTitleLater() {
    return this.buttonTitleLater ?? "LATER".tr;
  }

  String getButtonTitleUpdate() {
    return this.buttonTitleUpdate ?? "UPDATE NOW".tr;
  }

  void checkVersion() {
    if (!_initCalled || _displayed) return;
    if (shouldDisplayUpgrade()) {
      _displayed = true;
      Future.delayed(Duration(milliseconds: 0), () {
        _showDialog(title: getTitle(), message: getMessage());
      });
    }
  }

  bool shouldDisplayUpgrade() {
    if (debugDisplayAlways || (debugDisplayOnce && !_hasAlerted)) return true;

    if (!isUpdateAvailable()) return false;
    if (!forceUpdate && isTooSoon()) return false;

    return true;
  }

  bool isTooSoon() {
    if (_lastTimeAlerted == null) {
      return false;
    }

    final lastAlertedDuration = DateTime.now().difference(_lastTimeAlerted!);
    return lastAlertedDuration.inDays < daysToAlertAgain;
  }

  bool isUpdateAvailable() {
    if (_updateAvailable == null) {
      final appStoreVersion = Version.parse(this.updateVersion);
      final installedVersion = Version.parse(App.version);

      final available = appStoreVersion > installedVersion;
      _updateAvailable = available ? this.updateVersion : null;

      if (debugLogging) {
        print('upgrader: appStoreVersion: ${this.updateVersion}');
        print('upgrader: installedVersion: ${App.version.toString()}');
        print('upgrader: isUpdateAvailable: $available');
      }
    }
    return _updateAvailable != null;
  }

  void _showDialog({required String title, required String message}) {
    if (debugLogging) {
      print('upgrader: showDialog title: $title');
      print('upgrader: showDialog message: $message');
    }

    // Save the date/time as the last time alerted.
    saveLastAlerted();

    showDialog(
      barrierDismissible: false,
      context: Get.context!,
      builder: (BuildContext context) {
        return WillPopScope(
            onWillPop: () => Future.value(!this.forceUpdate),
            child: AlertDialog(
              title: Text(getTitle()),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(message),
                  Padding(
                      padding: EdgeInsets.only(top: 15.0),
                      child: Text(getPrompt())),
                ],
              ),
              actions: <Widget>[
                Visibility(
                    visible: kDebugMode || !this.forceUpdate,
                    child: TextButton(
                        child: Text(getButtonTitleLater()),
                        onPressed: () => onUserLater(true))),
                TextButton(
                    child: Text(getButtonTitleUpdate()),
                    onPressed: () => onUserUpdated(false)),
              ],
            ));
      },
    );
  }

  void onUserLater(bool shouldPop) {
    if (debugLogging) {
      print('upgrader: button tapped: $buttonTitleLater');
    }

    // If this callback has been provided, call it.
    var doProcess = true;
    if (this.onLater != null) {
      doProcess = onLater!();
    }

    if (doProcess) {}

    if (shouldPop) {
      Get.back();
    }
  }

  void onUserUpdated(bool shouldPop) {
    if (debugLogging) {
      print('upgrader: button tapped: $buttonTitleUpdate');
    }

    // If this callback has been provided, call it.
    var doProcess = true;
    if (this.onUpdate != null) {
      doProcess = onUpdate!();
    }

    if (doProcess) {
      _sendUserToAppStore();
    }

    if (shouldPop) {
      Get.back();
    }
  }

  Future<bool> clearSavedSettings() async {
    App.storage.remove('lastTimeAlerted');
    App.storage.remove('lastVersionAlerted');

    _lastTimeAlerted = null;
    _lastVersionAlerted = null;

    return true;
  }

  Future<bool> saveLastAlerted() async {
    _lastTimeAlerted = DateTime.now();
    App.storage.write('lastTimeAlerted', _lastTimeAlerted.toString());

    _lastVersionAlerted = this.updateVersion;
    App.storage.write('lastVersionAlerted', _lastVersionAlerted);

    _hasAlerted = true;
    return true;
  }

  Future<bool> _getSavedPrefs() async {
    final lastTimeAlerted = App.storage.read<String>('lastTimeAlerted');
    if (lastTimeAlerted != null && lastTimeAlerted.isNotEmpty) {
      _lastTimeAlerted = DateTime.parse(lastTimeAlerted);
    }

    _lastVersionAlerted = App.storage.read<String>('lastVersionAlerted');

    return true;
  }

  void _sendUserToAppStore() async {
    if (_appStoreListingURL == null || _appStoreListingURL!.length == 0) {
      if (debugLogging) {
        print('upgrader: empty _appStoreListingURL');
      }
      return;
    }

    if (debugLogging) {
      print('upgrader: launching: $_appStoreListingURL');
    }

    launchUrl(_appStoreListingURL!);
  }
}

class UpgradeAlert extends StatelessWidget {
  /// The later button title, which defaults to ```Later```
  final String? buttonTitleLater;

  /// The update button title, which defaults to ```Update Now```
  final String? buttonTitleUpdate;

  /// Days until alerting user again after later.
  ///final int daysToAlertAgain;

  /// For debugging, always force the upgrade to be available.
  //final bool debugDisplayAlways;

  /// For debugging, display the upgrade at least once once.
  final bool debugDisplayOnce;

  /// For debugging, display logging statements.
  final bool debugLogging;

  /// Called when the ignore button is tapped or otherwise activated.
  /// Return false when the default behavior should not execute.
  final BoolCallback? onIgnore;

  /// Called when the ignore button is tapped or otherwise activated.
  /// Return false when the default behavior should not execute.
  final BoolCallback? onLater;

  /// Called when the ignore button is tapped or otherwise activated.
  /// Return false when the default behavior should not execute.
  final BoolCallback? onUpdate;

  /// The call to action message, which defaults to: Would you like to update it now?
  final String? prompt;

  /// The title of the alert dialog. Defaults to: Update App?
  final String? title;

  /// The [child] contained by the widget.
  final Widget child;

  UpgradeAlert({
    Key? key,
    required this.child,
    this.buttonTitleLater,
    this.buttonTitleUpdate,
    //this.daysToAlertAgain = 3,
    //this.debugDisplayAlways = false,
    this.debugDisplayOnce = false,
    this.debugLogging = false,
    this.onIgnore,
    this.onLater,
    this.onUpdate,
    this.prompt,
    this.title,
  }) : super(key: key) {
    // if (this.updateVersionInfo != null) {
    //   ViqUpgrader()._updateVersionInfo = this.updateVersionInfo;
    // }
    if (this.buttonTitleLater != null) {
      Upgrader().buttonTitleLater = this.buttonTitleLater;
    }
    if (this.buttonTitleUpdate != null) {
      Upgrader().buttonTitleUpdate = this.buttonTitleUpdate;
    }
    //if (this.daysToAlertAgain != null) {
    //  VIQCoreUpgrader().daysUntilAlertAgain = this.daysToAlertAgain;
    //}
    // if (this.debugDisplayAlways != null) {
    //   VIQCoreUpgrader().debugDisplayAlways = this.debugDisplayAlways;
    // }
    if (this.debugDisplayOnce) {
      Upgrader().debugDisplayOnce = this.debugDisplayOnce;
    }
    if (this.debugLogging) {
      Upgrader().debugLogging = this.debugLogging;
    }
    if (this.onIgnore != null) {
      Upgrader().onIgnore = this.onIgnore;
    }
    if (this.onLater != null) {
      Upgrader().onLater = this.onLater;
    }
    if (this.onUpdate != null) {
      Upgrader().onUpdate = this.onUpdate;
    }
    if (this.prompt != null) {
      Upgrader().prompt = this.prompt;
    }
    if (this.title != null) {
      Upgrader().title = this.title;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      Upgrader().checkVersion();
    }
    return child;
  }
}
