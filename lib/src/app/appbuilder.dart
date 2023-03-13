import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../aether_core.dart';

class AppBuilder {
  final String? appName;
  AppBuilder({this.appName}) {
    WidgetsFlutterBinding.ensureInitialized();
    Get.isLogEnable = kDebugMode;
    _setDefaultLoading();
  }

  AppCredentialIdentity? _appCredentialIdentity;
  void useAppCredentialIdentity(AppCredentialIdentity identity) {
    _appCredentialIdentity = identity;
  }

  AppCredential? _appCredential;
  void useAppCredential(AppCredential credential) {
    _appCredential = credential;
  }

  AppDialog? _appDialog;
  void useAppDialog(AppDialog dialog) {
    _appDialog = dialog;
  }

  AppSettings? _appSettings;
  void useAppSettings(AppSettings settings) {
    _appSettings = settings;
  }

  void useProgressIndicatorSettings(
    void Function(EasyLoading easyLoading) configure,
  ) =>
      configure(EasyLoading.instance);

  Future<AppService> build() async {
    Get.isLogEnable = kDebugMode;

    await Hive.initFlutter();
    await Hive.openBox<String>('defaultBox');

    var appSettings = _appSettings ?? await AppSettings.loadDefault();

    final packageInfo = await PackageInfo.fromPlatform();

    final name = (appName ?? packageInfo.appName) + (kDebugMode ? '*' : '');

    final appInfo = AppInfo(
      name,
      packageInfo.version,
      packageInfo.buildNumber,
      packageInfo.packageName.isEmpty
          ? packageInfo.appName
          : packageInfo.packageName,
    );

    appInfo.printLog();
    Debug.print(appSettings.toMap());

    final app = AppService(
      appInfo: appInfo,
      settings: appSettings,
      credential: _appCredential ?? AppCredential(),
      identity: _appCredentialIdentity ?? AppCredentialIdentity(),
      dialog: _appDialog ?? AppDialog(),
    );

    Get.put(app);
    Get.lazyPut(() => DialogService());
    Get.lazyPut(() => SnackbarService());

    return app;
  }

  void _setDefaultLoading() {
    EasyLoading.instance
      ..displayDuration = const Duration(milliseconds: 2000)
      ..indicatorType = EasyLoadingIndicatorType.fadingCircle
      ..loadingStyle = EasyLoadingStyle.dark
      ..indicatorSize = 50.0
      ..radius = 10.0
      ..progressColor = Colors.green
      ..backgroundColor = Colors.transparent
      ..indicatorColor = Colors.green
      ..textColor = Colors.transparent
      ..maskColor = Colors.blue.withOpacity(0.5)
      ..userInteractions = false;
  }
}

class AppInfo {
  final String name;
  final String version;
  final String buildNumber;
  final String packageName;

  const AppInfo(this.name, this.version, this.buildNumber, this.packageName);

  void printLog() {
    Debug.print('              App Name : $name');
    Debug.print('           App Version : $version');
    Debug.print('          Build Number : $buildNumber');
    Debug.print('          Package Name : $packageName');
  }
}
