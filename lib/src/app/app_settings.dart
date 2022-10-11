import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../aether_core.dart';

const String kSettingsFilePath = '$kSystemPath/settings.json';
const String kSettingsFilePathDebug = '$kSystemPath/settings.debug.json';
const String kSettingsFilePathStaging = '$kSystemPath/settings.staging.json';

class AppSettings extends Entity {
  late final Field<String> apiBaseUrl = field('ApiBaseUrl');
  late final Field<String> apiKey = field('ApiKey');
  late final Field<int> apiConnectTimeoutInSec =
      field('ApiConnectTimeoutInSec', defaultValue: 10);
  late final Field<int> apiOfflinePingInSec =
      field('ApiOfflinePingInSec', defaultValue: 5);

  late final Field<String?> appStoreURL = field('AppStoreURL');

  // EasyLoading get easyLoading => EasyLoading.instance;

  AppSettings() {
    final google = field<String>('GooglePlayURL');
    final apple = field<String>('AppleAppStoreURL');
    final huawei = field<String>('HuaweiAppGalleryURL');

    appStoreURL.computed(
        bindings: [google, apple, huawei],
        compute: () {
          if (kIsWeb) return null;
          if (GetPlatform.isIOS) return apple();
          if (kHuaweiAppGallery) return huawei();
          return google();
        });
  }

  static Future loadFiles(AppSettings settings) async {
    /// Loading a json configuration file from a custom [path] into the current app config./
    Future loadFromPath(String path) async {
      final content = await rootBundle.loadString(path);
      final configAsMap = json.decode(content) as Map<String, dynamic>;
      settings.load(configAsMap);
    }

    try {
      await loadFromPath(kSettingsFilePath);
    } on Exception catch (_) {
      return settings;
    }

    if (kStagingMode) {
      try {
        await loadFromPath(kSettingsFilePathStaging);
      } on Exception catch (_) {}
    }

    if (kDebugMode) {
      try {
        await loadFromPath(kSettingsFilePathDebug);
      } on Exception catch (_) {}
    }

    // if (kDebugMode) print(settings.toMap());
  }
}
