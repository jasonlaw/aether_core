import 'dart:async';
import 'dart:convert';
import 'dart:io';

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
import 'package:url_launcher/url_launcher.dart';

import '../entity/entity.dart';
import '../extensions/extensions.dart';

import '../services/dialog/dialog_service.dart';
import '../services/snackbar/snackbar_service.dart';
export '../services/snackbar/snackbar_config.dart';

import 'upgrader/upgrader.dart';
import 'http/getxhttp.dart';
export 'http/getxhttp.dart';

//part 'app_service.dart';
part 'app_settings.dart';
part 'app_getxconnect.dart';
part 'app_credential.dart';

const String kSystemPath = 'assets/system';
const String kImagesPath = 'assets/images';
const String kSettingsFilePath = '$kSystemPath/settings.json';
const String kSettingsFilePathDebug = '$kSystemPath/settings.debug.json';
const String kSettingsFilePathStaging = '$kSystemPath/settings.staging.json';

final kStagingMode = _envVIQCoreBuild.split(';').contains('staging');
final kHuaweiAppGallery = _envVIQCoreBuild.split(';').contains('huawei');
const _envVIQCoreBuild = String.fromEnvironment("VIQCORE_BUILD");

// ignore: non_constant_identifier_names
AppService get App => Get.find();

class AppService extends GetxService {
  // App information
  final String name;
  final String version;
  final String buildNumber;
  final String packageName;
  final bool useLocalTimezoneInHttp;

  final SnackbarService snackbar = SnackbarService();
  final DialogService dialog = DialogService();
  late final CredentialIdentity identity =
      Get.isRegistered() ? Get.find() : CredentialIdentity();
  late final AppSettings settings;
  late final GetxConnect connect = GetxConnect._();
  late final GetxHttp http = GetxHttp();

  static Future startup({bool useLocalTimezoneInHttp = true}) async {
    if (kDebugMode) print('Startup AppService...');

    WidgetsFlutterBinding.ensureInitialized();

    Get.isLogEnable = kDebugMode;

    final packageInfo = await PackageInfo.fromPlatform();

    final appService = AppService._(
      name: packageInfo.appName,
      version: packageInfo.version,
      buildNumber: packageInfo.buildNumber,
      packageName: packageInfo.packageName,
      useLocalTimezoneInHttp: useLocalTimezoneInHttp,
    );

    Get.put(appService);

    await GetStorage.init(packageInfo.appName);

    appService.settings = await AppSettings._init();

    if (kDebugMode) print('Startup AppService Done.');
  }

  AppService._(
      {required String name,
      required this.version,
      required this.buildNumber,
      required this.packageName,
      required this.useLocalTimezoneInHttp})
      : this.name = name + (kDebugMode ? "*" : "") {
    if (kDebugMode) print("              App Name : ${this.name}");
    if (kDebugMode) print("           App Version : $version");
    if (kDebugMode) print("          Build Number : $buildNumber");
    if (kDebugMode) print("          Package Name : $packageName");
    if (kDebugMode) print("Local Timezone in Http : $useLocalTimezoneInHttp");
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

  Future<void> launchUrl(String url,
      {bool showError: false, String? defaultErrorText}) async {
    try {
      if (await canLaunch(url)) {
        await launch(url);
      } else if (showError && defaultErrorText != null) {
        App.snackbar.showError(defaultErrorText);
      }
    } catch (error) {
      if (showError) {
        App.snackbar.showError(error);
      }
    }
  }

  Future<void> launchPhoneCall(String phoneNumber,
      {bool showError: false}) async {
    return launchUrl('tel:$phoneNumber', showError: showError);
  }

  Future<void> launchEmail(String recipients,
      {String bcc = "",
      String subject = "",
      String body = "",
      bool showError: false}) async {
    return launchUrl(
        'mailto:$recipients?bcc=$bcc&body=${Uri.encodeComponent(body)}&subject=${Uri.encodeComponent(subject)}',
        showError: showError,
        defaultErrorText: "No email client found");
  }

  final isProgressIndicatorShowing = false.obs;

  void showProgressIndicator({String? status}) {
    if (EasyLoading.instance.overlayEntry != null) {
      EasyLoading.addStatusCallback((value) =>
          isProgressIndicatorShowing(value == EasyLoadingStatus.show));
      EasyLoading.show(status: status);
    }
  }

  void dismissProgressIndicator() {
    EasyLoading.dismiss();
  }

  Widget builder(BuildContext contxet, Widget? widget) {
    return UpgradeAlert(
      child: FlutterEasyLoading(
        child: widget,
      ),
    );
  }
}
