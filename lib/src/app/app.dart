import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/interceptors/get_modifiers.dart';
import 'package:get_storage/get_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:aether_core/src/entity/entity.dart';
import 'package:aether_core/src/services/services.dart';
import 'package:aether_core/src/utils/utils.dart';

import 'init.dart';
import 'http/getxhttp.dart';
import 'upgrader/upgrader.dart';
import 'app_theme.dart';

///import '../entity.dart';
//import '../extensions.dart';

export 'http/getxhttp.dart';
export 'package:get/get.dart';
export 'package:flutter_easyloading/flutter_easyloading.dart'
    show EasyLoadingIndicatorType;
export 'app_theme_sheet.dart';

part 'app_settings.dart';
part 'app_getxconnect.dart';
part 'app_credential.dart';

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

  final SnackbarService snackbar = SnackbarService();
  final DialogService dialog = DialogService();
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

    if (kStagingMode && appName != null) appName = appName + ' (Staging)';

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

    Get.log('Startup AppService Done.');
  }

  AppService._({
    required String name,
    required this.version,
    required this.buildNumber,
    required this.packageName,
  }) : this.name = name + (kDebugMode ? '*' : '') {
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
  String newUuid() => Uuid().v1();

  String newDigits(int size, {int seed = -1}) =>
      Uuid().digits(size, seed: seed);

  // Dialog actions
  Future<void> error(dynamic error, {String? title}) =>
      AppActions.notifyError(error, title: title);

  Future<void> info(String info, {String? title}) =>
      AppActions.notifyInfo(info, title: title);

  Future<bool> confirm(
    String question, {
    String? title,
    String? okButtonTitle,
    String? cancelButtonTitle,
  }) =>
      AppActions.askConfirm(question,
          title: title,
          okButtonTitle: okButtonTitle,
          cancelButtonTitle: cancelButtonTitle);

  // Progress indicator actions
  void showProgressIndicator({String? status}) {
    if (EasyLoading.instance.overlayEntry != null) {
      EasyLoading.show(status: status);
    }
  }

  void dismissProgressIndicator() => EasyLoading.dismiss();

  // Credential actions
  Future silentLogin() async => AppActions.silentLogin?.call();

  Future login(request) async => AppActions.login?.call(request);

  Future logout() async => AppActions.logout?.call();
}
