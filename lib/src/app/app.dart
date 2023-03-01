import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../entity/entity.dart';
import '../extensions/extensions.dart';
import '../services/services.dart';
import '../utils/utils.dart';
import 'app_connectivity.dart';
import 'app_settings.dart';
import 'appbuilder.dart';
import 'http_client/app_http_client.dart';
import 'upgrader/upgrader.dart';

export 'package:flutter_easyloading/flutter_easyloading.dart'
    show EasyLoadingIndicatorType;
export 'package:get/get.dart'
    hide
        Response,
        MultipartFile,
        GetConnect,
        FormData,
        GetConnectInterface,
        GetHttpClient,
        GraphQLResponse;

export 'app_connectivity.dart' show ConnectivityResult;
export 'app_settings.dart';
export 'appbuilder.dart';
export 'http_client/app_http_client.dart';

part 'app_credential.dart';
part 'app_credential_service.dart';
part 'app_dialog.dart';
//part 'app_getxconnect.dart';

const String kSystemPath = 'assets/system';
const String kImagesPath = 'assets/images';

final kStagingMode = kBuildArguments.contains('staging');
final kHuaweiAppGallery = kBuildArguments.contains('huawei');
const _viqcoreBuild = String.fromEnvironment('VIQCORE_BUILD');
final kBuildArguments =
    _viqcoreBuild.split(';').where((e) => e.isNotEmpty).toList();

// ignore: non_constant_identifier_names
AppService get App => Get.find();

class AppService extends GetxService {
  final AppInfo appInfo;
  final AbstractCredentialService credential;
  final CredentialIdentity? _credentialIdentity;
  final AppDialog dialog;

  late final CredentialIdentity identity =
      _credentialIdentity ?? CredentialIdentity();

  final AppSettings settings;
  //late final GetxConnect connect = GetxConnect._();
  //late final GetxHttp http = GetxHttp();
  //late final GetStorage storage = GetStorage();
  late final Box<String> box = Hive.box<String>('defaultBox');

  late final AppHttpClient httpClient = AppHttpClient(BaseOptions(
    baseUrl: App.settings.apiBaseUrl(),
    sendTimeout: Duration(seconds: App.settings.apiConnectTimeoutInSec()),
  ));

  late final AppHttpClient extHttpClient = AppHttpClient(BaseOptions(
    extra: {'EXTERNAL': true},
  ));

  late final AppConnectivity connectivity = AppConnectivity();

  /// Use with care, not govern by any management.
  final system = <String, dynamic>{};

  AppService({
    required this.appInfo,
    required this.settings,
    required this.credential,
    CredentialIdentity? credentialIdentity,
    required this.dialog,
    // DialogSettings? dialogSettings,
    // required SnackbarSettings notificationSettings,
  }) : _credentialIdentity = credentialIdentity;
  //   _dialogSettings = dialogSettings,
  //  _snackbarSettings = notificationSettings;

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

  Widget builder(BuildContext contxet, Widget? widget) {
    if (kIsWeb) {
      return FlutterEasyLoading(child: widget);
    }
    return UpgradeAlert(
      child: FlutterEasyLoading(
        child: widget,
      ),
    );
  }

  @Deprecated('Use App.dialog.showError')
  void error(dynamic error, {String? title}) {
    if (error == null) return;
    dialog.showError(error, title: title);
  }

  @Deprecated('Use App.dialog.showInfo')
  void info(String info, {String? title}) => dialog.showInfo(
        info,
        title: title,
      );

  @Deprecated('Use App.dialog.showConfirm')
  Future<bool> confirm(
    String question, {
    String? title,
    String? buttonTitle,
    String? cancelButtonTitle,
  }) async {
    return dialog.showConfirm(
      question,
      title: title,
      buttonTitle: buttonTitle,
      cancelButtonTitle: cancelButtonTitle,
    );
  }

  // @Deprecated('Use App.dialog.show')
  // Future<DialogResponse?> dialog({
  //   String? title,
  //   String? description,
  //   String? cancelTitle,
  //   Color? cancelTitleColor,
  //   String? buttonTitle,
  //   Color? buttonTitleColor,
  //   bool barrierDismissible = false,
  //   DialogPlatform? dialogPlatform,
  // }) =>
  //     _appDialog.show(
  //       title: title,
  //       description: description,
  //       buttonTitle: buttonTitle,
  //       cancelTitle: cancelTitle,
  //       buttonTitleColor: buttonTitleColor,
  //       cancelTitleColor: cancelTitleColor,
  //       barrierDismissible: barrierDismissible,
  //       dialogPlatform: dialogPlatform,
  //     );

  bool get isLoading => EasyLoading.isShow;

  // Progress indicator actions
  void showProgressIndicator({String? status}) {
    if (progressIndicatorLocked) return;
    if (EasyLoading.instance.overlayEntry != null) {
      //isLoading(true);
      EasyLoading.show(status: status);
    }
  }

  void dismissProgressIndicator() {
    //if (progressIndicatorLocked) return;
    EasyLoading.dismiss();
  }

  bool progressIndicatorLocked = false;

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  void changeThemeMode(ThemeMode themeMode) {
    _themeMode = themeMode;
    App.box.put('App.Theme.Mode', _themeMode.toString().split('.')[1]);
    Get.changeThemeMode(_themeMode);
  }

  void restoreThemeMode({ThemeMode defaultMode = ThemeMode.system}) {
    _themeMode = defaultMode;
    final storedThemeMode = App.box.get('App.Theme.Mode');
    try {
      if (storedThemeMode != null && storedThemeMode.isNotEmpty) {
        _themeMode = ThemeMode.values
            .firstWhere((e) => describeEnum(e) == storedThemeMode);
      }
    } on Exception catch (_) {
      _themeMode = defaultMode;
      App.box.delete('App.Theme.Mode');
    }
  }

  @Deprecated('Use App.dialog.registerCustoms')
  void registerCustomDialogBuilders(Map<dynamic, DialogBuilder> builders) {
    dialog.registerCustoms(builders);
  }

  @Deprecated('Use App.dialog.showCustom')
  Future<DialogResponse<T>?> customDialog<T, R>({
    dynamic variant,
    String? title,
    String? description,
    bool hasImage = false,
    String? imageUrl,
    bool showIconInMainButton = false,
    String? mainButtonTitle,
    bool showIconInSecondaryButton = false,
    String? secondaryButtonTitle,
    bool showIconInAdditionalButton = false,
    String? additionalButtonTitle,
    bool takesInput = false,
    Color barrierColor = Colors.black54,
    bool barrierDismissible = false,
    String barrierLabel = '',
    R? data,
  }) =>
      dialog.showCustom<T, R>(
        variant: variant,
        title: title,
        description: description,
        hasImage: hasImage,
        imageUrl: imageUrl,
        showIconInMainButton: showIconInMainButton,
        mainButtonTitle: mainButtonTitle,
        showIconInSecondaryButton: showIconInSecondaryButton,
        secondaryButtonTitle: secondaryButtonTitle,
        showIconInAdditionalButton: showIconInAdditionalButton,
        additionalButtonTitle: additionalButtonTitle,
        takesInput: takesInput,
        barrierColor: barrierColor,
        barrierDismissible: barrierDismissible,
        barrierLabel: barrierLabel,
        data: data,
      );

  @override
  void onClose() {
    AppConnectivity.dispose();
    Hive.close();
  }
}
