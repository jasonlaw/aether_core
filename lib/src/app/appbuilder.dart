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

  CredentialIdentity? _credentialIdentity;
  void useCredentialIdentity(CredentialIdentity identity) {
    _credentialIdentity = identity;
  }

  AbstractCredentialService? _credentialService;
  void useCredentialService(AbstractCredentialService service) {
    _credentialService = service;
  }

  DialogSettings? _dialogSettings;
  void useDialogSettings(DialogSettings settings) {
    _dialogSettings = settings;
  }

  SnackbarSettings? _snackbarSettings;
  void useSnackbarSettings(SnackbarSettings settings) {
    _snackbarSettings = settings;
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
      credential: _credentialService ?? CredentialService(),
      credentialIdentity: _credentialIdentity,
      notificationSettings: _snackbarSettings ?? const SnackbarSettings(),
      dialogSettings: _dialogSettings,
    );

    Get.put(app);
    Get.lazyPut(() => DialogService());
    Get.lazyPut(() => SnackbarService());

    // CredentialActions._finalize(_credentialActions);

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

class DialogSettings {
  final String? buttonTitle;
  final String? cancelTitle;
  final Color? buttonTitleColor;
  final Color? cancelTitleColor;
  final DialogPlatform? dialogPlatform;

  const DialogSettings({
    this.buttonTitle,
    this.cancelTitle,
    this.buttonTitleColor,
    this.cancelTitleColor,
    this.dialogPlatform,
  });
}

class SnackbarSettings {
  final String? errorTitle;
  final String? infoTitle;
  final Icon errorIcon; // = const Icon(Icons.error, color: Colors.red);
  final Icon infoIcon; // = const Icon(Icons.info, color: Colors.blue);
  final SnackPosition snackPosition; // = SnackPosition.BOTTOM;

  const SnackbarSettings({
    this.errorTitle,
    this.infoTitle,
    this.errorIcon = const Icon(Icons.error, color: Colors.red),
    this.infoIcon = const Icon(Icons.info, color: Colors.blue),
    this.snackPosition = SnackPosition.bottom,
  });
}
