part of 'app.dart';

class AppSettings extends Entity {
  late final Field<String> apiBaseUrl = field("ApiBaseUrl");
  late final Field<String> apiKey = field("ApiKey");
  late final Field<int> apiConnectTimeoutInSec =
      field("ApiConnectTimeoutInSec", defaultValue: 5);
  late final Field<String?> appStoreURL = field("AppStoreURL");

  // EasyLoading get easyLoading => EasyLoading.instance;

  AppSettings._() {
    final _google = field<String>("GooglePlayURL");
    final _apple = field<String>("AppleAppStoreURL");
    final _huawei = field<String>("HuaweiAppGalleryURL");

    appStoreURL.computed(
        bindings: [_google, _apple, _huawei],
        compute: () {
          if (kIsWeb) return null;
          if (GetPlatform.isIOS) return _apple();
          if (kHuaweiAppGallery) return _huawei();
          return _google();
        });
  }

  static Future<AppSettings> _init() async {
    var settings = AppSettings._();

    AppActions.resetDefaultLoading();

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

    if (kDebugMode) print(settings.toMap());

    return settings;
  }
}
