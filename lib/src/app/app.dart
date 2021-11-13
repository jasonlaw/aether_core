import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:aether_core/src/app/app_theme.dart';
import 'package:aether_core/src/utils/custom.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/interceptors/get_modifiers.dart';
import 'package:get_storage/get_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'http/getxhttp.dart';
import 'upgrader/upgrader.dart';
import '../services/services.dart';
import '../entity.dart';
import '../extensions.dart';

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
  // App information
  final String name;
  final String version;
  final String buildNumber;
  final String packageName;
  //final String platform;
  //final bool isPhysicalDevice;
  final bool useLocalTimezoneInHttp;

  final SnackbarService snackbar = SnackbarService();
  final DialogService dialog = DialogService();
  late final CredentialIdentity identity =
      Get.isRegistered() ? Get.find() : CredentialIdentity();
  late final AppSettings settings;
  late final GetxConnect connect = GetxConnect._();
  late final GetxHttp http = GetxHttp();
  late final GetStorage storage = GetStorage();
  late final AppTheme theme = AppTheme();
  final Custom custom = Custom();

  static Future startup({bool useLocalTimezoneInHttp = true}) async {
    Get.log('Startup AppService...');

    WidgetsFlutterBinding.ensureInitialized();

    Get.isLogEnable = kDebugMode;

    final packageInfo = await PackageInfo.fromPlatform();

    // String? deviceName;
    // bool isPhysicalDevice = true;
    // final deviceInfo = DeviceInfoPlugin();
    // if (kIsWeb) {
    //   final webBrowserInfo = await deviceInfo.webBrowserInfo;
    //   deviceName = webBrowserInfo.userAgent;
    // } else if (GetPlatform.isAndroid) {
    //   final androidInfo = await deviceInfo.androidInfo;
    //   deviceName = androidInfo.model;
    //   isPhysicalDevice = androidInfo.isPhysicalDevice ?? !kDebugMode;
    // } else if (GetPlatform.isIOS) {
    //   final iosInfo = await deviceInfo.iosInfo;
    //   deviceName = iosInfo.utsname.machine;
    //   isPhysicalDevice = iosInfo.isPhysicalDevice;
    // }

    final appService = AppService._(
      name: packageInfo.appName,
      version: packageInfo.version,
      buildNumber: packageInfo.buildNumber,
      packageName: packageInfo.packageName,
      //platform: deviceName ?? 'Unknown',
      //isPhysicalDevice: isPhysicalDevice,
      useLocalTimezoneInHttp: useLocalTimezoneInHttp,
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
    //required this.platform,
    //required this.isPhysicalDevice,
    required this.useLocalTimezoneInHttp,
  }) : this.name = name + (kDebugMode ? '*' : '') {
    Get.log('              App Name : ${this.name}');
    Get.log('           App Version : $version');
    Get.log('          Build Number : $buildNumber');
    Get.log('          Package Name : $packageName');
    //Get.log('              Platform : $platform');
    //Get.log('       Physical Device : $isPhysicalDevice');
    Get.log('Local Timezone in Http : $useLocalTimezoneInHttp');
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
  }

  Widget builder(BuildContext contxet, Widget? widget) => UpgradeAlert(
        child: FlutterEasyLoading(
          child: widget,
        ),
      );
}
