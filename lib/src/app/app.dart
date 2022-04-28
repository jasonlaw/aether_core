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
import 'app_theme.dart';
import 'app_translations.dart';
import 'appbuilder.dart';
import 'http/getxhttp.dart';
import 'upgrader/upgrader.dart';

export 'package:flutter_easyloading/flutter_easyloading.dart'
    show EasyLoadingIndicatorType;
export 'package:get/get.dart';

export 'app_settings.dart';
export 'app_theme_sheet.dart';
export 'appbuilder.dart';

///import '../entity.dart';
export 'http/getxhttp.dart';

part 'app_credential.dart';
part 'app_getxconnect.dart';
//part 'app_settings.dart';

const String kSystemPath = 'assets/system';
const String kImagesPath = 'assets/images';
const String kSettingsFilePath = '$kSystemPath/settings.json';
const String kSettingsFilePathDebug = '$kSystemPath/settings.debug.json';
const String kSettingsFilePathStaging = '$kSystemPath/settings.staging.json';

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

  late final CredentialIdentity identity =
      Get.isRegistered() ? Get.find() : CredentialIdentity();
  final AppSettings settings;
  late final GetxConnect connect = GetxConnect._();
  late final GetxHttp http = GetxHttp();
  late final GetStorage storage = GetStorage();
  late final AppTheme theme = AppTheme();
  late final AppTranslations tr = AppTranslations();

  // static Future init([String? appName]) async {
  //   Get.log('Startup AppService...');

  //   //WidgetsFlutterBinding.ensureInitialized();

  //   Get.isLogEnable = kDebugMode;

  //   final packageInfo = await PackageInfo.fromPlatform();

  //   if (kStagingMode && appName != null) appName = '$appName (Staging)';

  //   final appInfo = AppInfo(
  //     appName ?? packageInfo.appName,
  //     packageInfo.version,
  //     packageInfo.buildNumber,
  //     packageInfo.packageName.isEmpty
  //         ? packageInfo.appName
  //         : packageInfo.packageName,
  //   );

  //   final settings = await AppSettings.init();

  //   final _name = (appName ?? packageInfo.appName) + (kDebugMode ? '*' : '');
  //   final appService = AppService(
  //     appInfo: appInfo,
  //     settings: settings,
  //     notificationSettings: const NotificationSettings(),
  //     name: _name,
  //     version: packageInfo.version,
  //     buildNumber: packageInfo.buildNumber,
  //     packageName: packageInfo.packageName.isEmpty
  //         ? packageInfo.appName
  //         : packageInfo.packageName,
  //   );

  //   // Get.put(appService);

  //   await GetStorage.init();

  //   AppActions.resetDefaultLoading();

  //   //Get.lazyPut(() => DialogService());
  //   //Get.lazyPut(() => SnackbarService());

  //   Get.log('Startup AppService Done.');
  // }

  AppService({
    required this.appInfo,
    required this.settings,
    CredentialActions? credentialActions,
    DialogSettings? dialogSettings,
    required SnackbarSettings notificationSettings,
  })  : _credentialActions = credentialActions,
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

  // // Credential actions
  // /// Silent login credential, implementation required in App.init.silentLogin
  // Future silentLogin() async => AppActions.silentLogin?.call();

  // /// Login credential, implementation required in App.init.login
  // Future login(dynamic request) async => AppActions.login?.call(request);

  // /// Logout credential, implementation required in App.init.logout
  // Future logout() async => AppActions.logout?.call();

  Future signIn(dynamic request) async =>
      _credentialActions?.signIn?.call(request);

  Future signOut() async => _credentialActions?.signOut?.call();

  Future signInRefresh() async => _credentialActions?.signInRefresh?.call();
}
