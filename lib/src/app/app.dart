import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/interceptors/get_modifiers.dart';
import 'package:get_storage/get_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../entity/entity.dart';
import '../extensions/extensions.dart';
import '../services/models/overlay_response.dart';
import '../services/services.dart';
import '../utils/utils.dart';
import 'app_theme.dart';
import 'http/getxhttp.dart';
import 'init.dart';
import 'upgrader/upgrader.dart';

export 'package:flutter_easyloading/flutter_easyloading.dart'
    show EasyLoadingIndicatorType;
export 'package:get/get.dart';

export 'app_theme_sheet.dart';

///import '../entity.dart';
export 'http/getxhttp.dart';

part 'app_credential.dart';
part 'app_getxconnect.dart';
part 'app_settings.dart';

const String kSystemPath = 'assets/system';
const String kImagesPath = 'assets/images';
const String kSettingsFilePath = '$kSystemPath/settings.json';
const String kSettingsFilePathDebug = '$kSystemPath/settings.debug.json';
const String kSettingsFilePathStaging = '$kSystemPath/settings.staging.json';

final kStagingMode = kBuildArguments.contains('staging');
final kHuaweiAppGallery = kBuildArguments.contains('huawei');
const _viqcoreBuild = String.fromEnvironment("VIQCORE_BUILD");
final kBuildArguments =
    _viqcoreBuild.split(';').where((e) => e.isNotEmpty).toList();

// ignore: non_constant_identifier_names
AppService get App => Get.find();

class AppService extends GetxService {
  final String name;
  final String version;
  final String buildNumber;
  final String packageName;

  //final SnackbarService snackbar = SnackbarService();
  //final DialogService dialog = DialogService();
  late final CredentialIdentity identity =
      Get.isRegistered() ? Get.find() : CredentialIdentity();
  late final AppSettings settings;
  late final GetxConnect connect = GetxConnect._();
  late final GetxHttp http = GetxHttp();
  late final GetStorage storage = GetStorage();
  late final AppTheme theme = AppTheme();
  late final Crypto crypto = Crypto();
  late final AppInit init = AppInit();

  static Future startup([String? appName]) async {
    Get.log('Startup AppService...');

    //WidgetsFlutterBinding.ensureInitialized();

    Get.isLogEnable = kDebugMode;

    final packageInfo = await PackageInfo.fromPlatform();

    if (kStagingMode && appName != null) appName = '$appName (Staging)';

    final appService = AppService._(
      name: appName ?? packageInfo.appName,
      version: packageInfo.version,
      buildNumber: packageInfo.buildNumber,
      packageName: packageInfo.packageName.isEmpty
          ? packageInfo.appName
          : packageInfo.packageName,
    );

    Get.put(appService);

    await GetStorage.init();

    appService.settings = await AppSettings._init();

    Get.lazyPut(() => DialogService());
    Get.lazyPut(() => SnackbarService());

    Get.log('Startup AppService Done.');
  }

  AppService._({
    required String name,
    required this.version,
    required this.buildNumber,
    required this.packageName,
  }) : name = name + (kDebugMode ? '*' : '') {
    Get.log('              App Name : ${this.name}');
    Get.log('           App Version : $version');
    Get.log('          Build Number : $buildNumber');
    Get.log('          Package Name : $packageName');
  }

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

  // Unique ID generators
  /// Generate a v1 unique identifier
  String newUuid() => Uuid().v1();

  String newDigits(int size, {int seed = -1}) =>
      Uuid().digits(size, seed: seed);

  /// Error snackbar notification
  Future<void> error(dynamic error, {String? title}) async {
    if (error == null) return;
    Get.snackbar(
      title ?? AppActions.notifySettings.infoTitle ?? 'Error'.tr,
      error.toString().truncate(1000),
      snackPosition: AppActions.notifySettings.snackPosition,
      icon: AppActions.notifySettings.errorIcon,
    );
  }

  /// Information snackbar notification
  Future<void> info(String info, {String? title}) async => Get.snackbar(
        title ?? AppActions.notifySettings.infoTitle ?? 'Info'.tr,
        info,
        snackPosition: AppActions.notifySettings.snackPosition,
        icon: AppActions.notifySettings.infoIcon,
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
      buttonTitle:
          buttonTitle ?? AppActions.dialogSettings.buttonTitle ?? 'OK'.tr,
      cancelTitle: cancelButtonTitle ??
          AppActions.dialogSettings.cancelTitle ??
          'CANCEL'.tr,
      buttonTitleColor: AppActions.dialogSettings.buttonTitleColor,
      cancelTitleColor: AppActions.dialogSettings.cancelTitleColor,
      dialogPlatform: AppActions.dialogSettings.dialogPlatform,
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
          buttonTitle:
              buttonTitle ?? AppActions.dialogSettings.buttonTitle ?? 'OK'.tr,
          cancelTitle: cancelTitle ?? AppActions.dialogSettings.cancelTitle,
          buttonTitleColor:
              buttonTitleColor ?? AppActions.dialogSettings.buttonTitleColor,
          cancelTitleColor:
              cancelTitleColor ?? AppActions.dialogSettings.cancelTitleColor,
          barrierDismissible: barrierDismissible,
          dialogPlatform:
              dialogPlatform ?? AppActions.dialogSettings.dialogPlatform);

  // Progress indicator actions
  void showProgressIndicator({String? status}) {
    if (EasyLoading.instance.overlayEntry != null) {
      EasyLoading.show(status: status);
    }
  }

  void dismissProgressIndicator() => EasyLoading.dismiss();

  // Credential actions
  /// Silent login credential, implementation required in App.init.silentLogin
  Future silentLogin() async => AppActions.silentLogin?.call();

  /// Login credential, implementation required in App.init.login
  Future login(dynamic request) async => AppActions.login?.call(request);

  /// Logout credential, implementation required in App.init.logout
  Future logout() async => AppActions.logout?.call();
}
