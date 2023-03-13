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
part 'app_credential_identity.dart';
part 'app_dialog.dart';

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
  final AppCredential credential;
  final AppDialog dialog;

  final AppCredentialIdentity identity;

  final AppSettings settings;
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
    required this.identity,
    required this.dialog,
  });

  @override
  void onClose() {
    AppConnectivity.dispose();
    Hive.close();
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
}
