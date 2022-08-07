import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../aether_core.dart';

class AppBuilder {
  AppBuilder() {
    WidgetsFlutterBinding.ensureInitialized();
    Get.isLogEnable = kDebugMode;
    _setDefaultLoading();
  }

  CredentialIdentity? _credentialIdentity;
  void useCredentialIdentity(CredentialIdentity identity) {
    _credentialIdentity = identity;
  }

  CredentialActions? _credentialActions;
  void useCredentialActions(CredentialActions actions) {
    _credentialActions = actions;
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

  // Map<dynamic, DialogBuilder>? _dialogBuilders;
  // void useDialogBuilders(Map<dynamic, DialogBuilder> builders) {
  //   _dialogBuilders = builders;
  // }

  Future<AppService> build({String? appName}) async {
    Get.isLogEnable = kDebugMode;

    await Hive.initFlutter();
    await Hive.openBox<String>('defaultBox');

    var appSettings = _appSettings;

    if (appSettings == null) {
      appSettings = AppSettings();
      await AppSettings.loadFiles(appSettings);
    }

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
      credentialIdentity: _credentialIdentity,
      credentialActions: _credentialActions,
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
    this.snackPosition = SnackPosition.BOTTOM,
  });
}

class CredentialActions {
  final Future Function(dynamic)? signIn;
  final Future Function()? signOut;

  final Future Function()? renewCredential;
  final Future Function()? getCredential;
  final void Function(Response response)? unauthorizedHandler;

  //final Future<String?> Function() getRefreshToken;
  //static Future<String?> Function()? _getRefreshToken;

  const CredentialActions({
    this.signIn,
    this.signOut,
    this.renewCredential,
    //Future<String?> Function()? getRefreshToken,
    this.getCredential,
    this.unauthorizedHandler,
  });

  static CredentialActions aether({
    Future Function(dynamic)? signIn,
    Future Function()? signOut,
    //Future<String?> Function()? getRefreshToken,
    Future Function()? renewCredential,
    Future Function()? getCredential,
    void Function(Response response)? unauthorizedHandler,
  }) =>
      CredentialActions(
        signIn: signIn ?? _signIn,
        signOut: signOut ?? _signOut,
        //   getRefreshToken: getRefreshToken ?? _getRefreshToken,
        renewCredential: renewCredential ?? _renewCredential,
        getCredential: getCredential ?? _getCredential,
        unauthorizedHandler: unauthorizedHandler,
      );

  static Future<void> _signIn(dynamic request) async {
    final response = await '/api/credential/signin'.api(body: request).post();
    App.identity.load(response.data);
  }

  static Future<void> _signOut() async {
    try {
      await '/api/credential/signout'.api().post();
    } on Exception catch (_) {
    } finally {
      App.identity.signOut();
    }
  }

  static Future<void> _renewCredential() async {
    try {
      final response = await '/api/credential/refresh'
          .api(body: {'refreshToken': App.httpClient.refreshToken}).post(
        extra: {
          'RENEW_CREDENTIAL': true,
        },
      );
      App.identity.load(response.data);
    } on AppNetworkResponseException catch (_) {
      App.httpClient.clearIdentityCache();
      rethrow;
    }
  }

  static Future<void> _getCredential() async {
    try {
      final response = await '/api/credential'.api().get(
            timeout: const Duration(seconds: 10),
          );
      App.identity.load(response.data);
    } on AppNetworkResponseException catch (_) {
      App.httpClient.clearIdentityCache();
    } on Exception catch (err) {
      return Future.error(err.toString());
    }
  }

  // static void _finalize(CredentialActions? actions) {
  //   _getRefreshToken =
  //       actions?.getRefreshToken ?? () async => App.httpClient.refreshToken;

  //   if (actions?.refreshCredential != null) {
  //     //App.connect.addAuthenticator(actions!.refreshCredential!);
  //   }

  //   if (actions?.unauthorizedHandler != null) {
  //     //  App.connect.addUnauthorizedResponseHandler(actions!.unauthorizedHandler!);
  //   }
  // }

  static Map<String, String> userPass(
    String username,
    String password,
  ) {
    return {
      'username': username,
      'password': password,
    };
  }

  static Map<String, String> idToken(
    String idToken,
  ) {
    return {
      'idToken': idToken,
    };
  }
}
