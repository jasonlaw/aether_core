import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get_storage/get_storage.dart';
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

    await GetStorage.init();

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

    // if (_dialogBuilders != null) {
    //   Get.find<DialogService>().registerCustomDialogBuilders(_dialogBuilders!);
    // }

    CredentialActions._finalize(_credentialActions);

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

  final Future Function()? refreshCredential;
  final Future Function()? getCredential;
  final void Function(Response response)? unauthorizedHandler;

  final Future<String?> Function()? getRefreshToken;
  static Future<String?> Function()? _getRefreshToken;

  const CredentialActions({
    this.signIn,
    this.signOut,
    this.refreshCredential,
    this.getRefreshToken,
    this.getCredential,
    this.unauthorizedHandler,
  });

  static CredentialActions aether({
    Future Function(dynamic)? signIn,
    Future Function()? signOut,
    Future<String?> Function()? getRefreshToken,
    Future Function()? refreshCredential,
    Future Function()? getCredential,
    void Function(Response response)? unauthorizedHandler,
  }) =>
      CredentialActions(
        signIn: signIn ?? _signIn,
        signOut: signOut ?? _signOut,
        getRefreshToken: getRefreshToken ?? _getRefreshToken,
        refreshCredential: refreshCredential ?? _refreshCredential,
        getCredential: getCredential ?? _getCredential,
        unauthorizedHandler: unauthorizedHandler,
      );

  static Future<void> _signIn(dynamic request) {
    return '/api/credential/signin'.api(body: request).post().then((response) {
      if (response.hasError) return Future.error(response.errorText);
      App.identity.load(response.body);
    });
  }

  static Future<void> _signOut() {
    return '/api/credential/signout'
        .api()
        .post()
        .catchError((_) {})
        .whenComplete(() {
      App.identity.signOut();
    });
  }

  static Future<void> _refreshCredential() async {
    final refreshToken = await _getRefreshToken!.call();

    if (refreshToken.isNullOrEmpty) return;

    return '/api/credential/refresh'
        .api(body: {'refreshToken': refreshToken})
        .post()
        .then((response) {
          if (response.hasError) {
            if (response.statusCode != null) {
              App.connect.clearIdentityCache();
              return;
            }
          }
          App.identity.load(response.body);
        })
        .catchError((_) {});
  }

  static Future<void> _getCredential() {
    return '/api/credential'
        .api()
        .get(timeout: const Duration(seconds: 10))
        .then((response) {
      if (response.hasError) {
        if (response.statusCode != null) {
          App.connect.clearIdentityCache();
        }
        return Future.error(response.errorText);
      }
      App.identity.load(response.body);
    });
  }

  static void _finalize(CredentialActions? actions) {
    _getRefreshToken =
        actions?.getRefreshToken ?? () async => App.connect.refreshToken;

    if (actions?.refreshCredential != null) {
      App.connect.addAuthenticator(actions!.refreshCredential!);
    }

    if (actions?.unauthorizedHandler != null) {
      App.connect.addUnauthorizedResponseHandler(actions!.unauthorizedHandler!);
    }
  }

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
