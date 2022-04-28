import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get_connect/http/src/interceptors/get_modifiers.dart';
import 'package:get_storage/get_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../aether_core.dart';

class AppBuilder {
  AppBuilder() {
    Get.isLogEnable = kDebugMode;
    _setDefaultLoading();
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

  void useProgressIndicatorSettings(
    void Function(EasyLoading easyLoading) configure,
  ) =>
      configure(EasyLoading.instance);

  Future<AppService> build({String? appName}) async {
    Get.isLogEnable = kDebugMode;

    await GetStorage.init();

    final settings = await AppSettings.init();

    final packageInfo = await PackageInfo.fromPlatform();

    final _name = (appName ?? packageInfo.appName) + (kDebugMode ? '*' : '');
    final appInfo = AppInfo(
      _name,
      packageInfo.version,
      packageInfo.buildNumber,
      packageInfo.packageName.isEmpty
          ? packageInfo.appName
          : packageInfo.packageName,
    );

    if (kDebugMode) appInfo.printLog();

    final app = AppService(
      appInfo: appInfo,
      settings: settings,
      credentialActions: _credentialActions,
      notificationSettings: _snackbarSettings ?? const SnackbarSettings(),
      dialogSettings: _dialogSettings,
    );

    Get.put(app);
    Get.lazyPut(() => DialogService());
    Get.lazyPut(() => SnackbarService());

    if (_credentialActions?.authenticator != null) {
      app.connect.addAuthenticator(_credentialActions!.authenticator!);
    }
    if (_credentialActions?.unauthorizedHandler != null) {
      app.connect.addUnauthorizedResponseHandler(
          _credentialActions!.unauthorizedHandler!);
    }

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
    Get.log('              App Name : $name');
    Get.log('           App Version : $version');
    Get.log('          Build Number : $buildNumber');
    Get.log('          Package Name : $packageName');
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
  final Future Function()? signInRefresh;
  final RequestModifier? authenticator;
  final void Function(Response response)? unauthorizedHandler;

  const CredentialActions({
    this.signIn,
    this.signOut,
    this.signInRefresh,
    this.authenticator,
    this.unauthorizedHandler,
  });

  static CredentialActions aether({
    Future Function(dynamic)? signIn,
    Future Function()? signOut,
    Future Function()? signInRefresh,
    RequestModifier? authenticator,
    void Function(Response response)? unauthorizedHandler,
  }) =>
      CredentialActions(
        signIn: signIn ?? _signIn,
        signOut: signOut ?? _signOut,
        signInRefresh: signInRefresh ?? _signInRefresh,
        authenticator: authenticator ?? _authenticator,
      );

  static Future _signIn(dynamic request) async {
    final result = await '/api/credential/signin'.api(body: request).post();
    if (result.hasError) return Future.error(result.errorText);
    App.identity.load(result.body);
  }

  static Future _signOut() async {
    final result = await '/api/credential/signout'.api().post();
    if (result.hasError) {
      // if failed to logout, we manually clear the cookies.
      App.connect.clearCookies();
    }
    App.identity.signOut();
  }

  static Future _signInRefresh() async {
    if (App.identity.refreshToken.isNullOrEmpty) return;
    final result = await '/api/credential/refresh'
        .api(body: {'refreshToken': App.identity.refreshToken}).post();
    if (result.hasError) {
      App.connect.clearCookies();
    } else if (result.isOk) {
      App.identity.load(result.body);
    }
  }

  // ignore: prefer_function_declarations_over_variables
  static final RequestModifier _authenticator = (request) async {
    if (App.identity.refreshToken.isNotNullOrEmpty) {
      final result = await '/api/credential/refresh'
          .api(body: {'refreshToken': App.identity.refreshToken}).post();
      if (result.hasError) {
        App.connect.clearCookies();
      }
    }
    return request;
  };

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
