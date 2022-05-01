import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/interceptors/get_modifiers.dart';
import 'package:get_storage/get_storage.dart';

import '../entity/entity.dart';
import '../extensions/extensions.dart';
import '../services/models/overlay_response.dart';
import '../services/services.dart';
import '../utils/utils.dart';
import 'app_settings.dart';
import 'appbuilder.dart';
import 'http/getxhttp.dart';
import 'upgrader/upgrader.dart';

export 'package:flutter_easyloading/flutter_easyloading.dart'
    show EasyLoadingIndicatorType;
export 'package:get/get.dart';

export 'app_settings.dart';
export 'appbuilder.dart';

export 'http/getxhttp.dart';

part 'app_credential.dart';
part 'app_getxconnect.dart';

const String kSystemPath = 'assets/system';
const String kImagesPath = 'assets/images';

final kStagingMode = kBuildArguments.contains('staging');
final kHuaweiAppGallery = kBuildArguments.contains('huawei');
const _viqcoreBuild = String.fromEnvironment('VIQCORE_BUILD');
final kBuildArguments =
    _viqcoreBuild.split(';').where((e) => e.isNotEmpty).toList();

// ignore: non_constant_identifier_names
AppService get App => Get.find();

class AppService extends GetxService {
  final AppInfo appInfo;
  final CredentialActions? _credentialActions;
  final DialogSettings? _dialogSettings;
  final SnackbarSettings _snackbarSettings;
  final CredentialIdentity? _credentialIdentity;

  late final CredentialIdentity identity =
      _credentialIdentity ?? CredentialIdentity();

  final AppSettings settings;
  late final GetxConnect connect = GetxConnect._();
  late final GetxHttp http = GetxHttp();
  late final GetStorage storage = GetStorage();
  //late final AppTheme theme = AppTheme();
  //late final AppTranslations tr = AppTranslations();

  AppService({
    required this.appInfo,
    required this.settings,
    CredentialIdentity? credentialIdentity,
    CredentialActions? credentialActions,
    DialogSettings? dialogSettings,
    required SnackbarSettings notificationSettings,
  })  : _credentialIdentity = credentialIdentity,
        _credentialActions = credentialActions,
        _dialogSettings = dialogSettings,
        _snackbarSettings = notificationSettings;

  Future<void> initUpgrader({
    required String updateVersion,
    bool forceUpdate = false,
    int daysToAlertAgain = 3,
    bool debugDisplayAlways = false,
  }) async {
    if (kIsWeb) return;
    await Upgrader().initialize();
    Upgrader().updateVersion = updateVersion;
    Upgrader().forceUpdate = forceUpdate;
    Upgrader().daysToAlertAgain = daysToAlertAgain;
    Upgrader().debugDisplayAlways = debugDisplayAlways;
    Upgrader().debugLogging = kDebugMode;
  }

  Widget builder(BuildContext contxet, Widget? widget) => UpgradeAlert(
        child: FlutterEasyLoading(
          child: widget,
        ),
      );

  /// Error snackbar notification
  Future<void> error(dynamic error, {String? title}) async {
    if (error == null) return;
    Get.snackbar(
      title ?? _snackbarSettings.infoTitle ?? 'Error'.tr,
      error.toString().truncate(1000),
      snackPosition: _snackbarSettings.snackPosition,
      icon: _snackbarSettings.errorIcon,
    );
  }

  /// Information snackbar notification
  Future<void> info(String info, {String? title}) async => Get.snackbar(
        title ?? _snackbarSettings.infoTitle ?? 'Info'.tr,
        info,
        snackPosition: _snackbarSettings.snackPosition,
        icon: _snackbarSettings.infoIcon,
      );

  /// Confirmation dialog
  Future<bool> confirm(
    String question, {
    String? title,
    String? buttonTitle,
    String? cancelButtonTitle,
  }) async {
    final response = await Get.find<DialogService>().showDialog(
      title: title,
      description: question,
      buttonTitle: buttonTitle ?? _dialogSettings?.buttonTitle ?? 'OK'.tr,
      cancelTitle:
          cancelButtonTitle ?? _dialogSettings?.cancelTitle ?? 'CANCEL'.tr,
      buttonTitleColor: _dialogSettings?.buttonTitleColor,
      cancelTitleColor: _dialogSettings?.cancelTitleColor,
      dialogPlatform: _dialogSettings?.dialogPlatform,
      barrierDismissible: true,
    );
    return response?.confirmed ?? false;
  }

  /// General dialog
  Future<DialogResponse?> dialog({
    String? title,
    String? description,
    String? cancelTitle,
    Color? cancelTitleColor,
    String? buttonTitle,
    Color? buttonTitleColor,
    bool barrierDismissible = false,
    DialogPlatform? dialogPlatform,
  }) =>
      Get.find<DialogService>().showDialog(
          title: title,
          description: description,
          buttonTitle: buttonTitle ?? _dialogSettings?.buttonTitle ?? 'OK'.tr,
          cancelTitle: cancelTitle ?? _dialogSettings?.cancelTitle,
          buttonTitleColor:
              buttonTitleColor ?? _dialogSettings?.buttonTitleColor,
          cancelTitleColor:
              cancelTitleColor ?? _dialogSettings?.cancelTitleColor,
          barrierDismissible: barrierDismissible,
          dialogPlatform: dialogPlatform ?? _dialogSettings?.dialogPlatform);

  // Progress indicator actions
  void showProgressIndicator({String? status}) {
    if (EasyLoading.instance.overlayEntry != null) {
      EasyLoading.show(status: status);
    }
  }

  void dismissProgressIndicator() => EasyLoading.dismiss();

  Future signIn(dynamic request) async =>
      _credentialActions?.signIn?.call(request);

  Future signOut() async => _credentialActions?.signOut?.call();

  Future getCredential() async => _credentialActions?.getCredential?.call();

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  void changeThemeMode(ThemeMode themeMode) {
    _themeMode = themeMode;
    App.storage.write('App.Theme.Mode', _themeMode.toString().split('.')[1]);
    Get.changeThemeMode(_themeMode);
  }

  void restoreThemeMode({ThemeMode defaultMode = ThemeMode.system}) {
    _themeMode = defaultMode;
    final storedThemeMode = App.storage.read<String>('App.Theme.Mode');
    try {
      if (storedThemeMode != null && storedThemeMode.isNotEmpty) {
        _themeMode = ThemeMode.values
            .firstWhere((e) => describeEnum(e) == storedThemeMode);
      }
    } on Exception catch (_) {
      _themeMode = defaultMode;
      App.storage.remove('App.Theme.Mode');
    }
  }
}
