part of 'app.dart';

class AppSettings extends Entity {
  late final Field<String> apiBaseUrl = this.field("ApiBaseUrl");
  late final Field<String> apiKey = this.field("ApiKey");
  late final Field<int> apiConnectTimeoutInSec =
      this.field("ApiConnectTimeoutInSec", defaultValue: 5);
  late final Field<String?> appStoreURL = this.field("AppStoreURL");

  EasyLoading get easyLoading => EasyLoading.instance;

  AppSettings._() {
    final _google = this.field<String>("GooglePlayURL");
    final _apple = this.field<String>("AppleAppStoreURL");
    final _huawei = this.field<String>("HuaweiAppGalleryURL");

    this.appStoreURL.computed(
        bindings: [_google, _apple, _huawei],
        compute: () {
          if (kIsWeb) return null;
          if (Platform.isIOS) return _apple();
          if (kHuaweiAppGallery) return _huawei();
          return _google();
        });
  }

  static Future<AppSettings> _init() async {
    var settings = AppSettings._();

    _configLoading();

    /// Loading a json configuration file from a custom [path] into the current app config./
    Future loadFromPath(String path) async {
      String content = await rootBundle.loadString(path);
      Map<String, dynamic> configAsMap = json.decode(content);
      settings.load(configAsMap);
    }

    try {
      await loadFromPath(kSettingsFilePath);
    } catch (_) {
      return settings;
    }

    if (kStagingMode) {
      try {
        await loadFromPath(kSettingsFilePathStaging);
      } catch (_) {}
    }
    if (kDebugMode) {
      try {
        await loadFromPath(kSettingsFilePathDebug);
      } catch (_) {}
    }
    if (kDebugMode) print(settings.toMap());

    return settings;
  }

  static void _configLoading() {
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
    // ..customAnimation = CustomAnimation();
  }

//   void customLoadingIndicator(
//       {EasyLoadingIndicatorType type = EasyLoadingIndicatorType.fadingCircle,
//       double size = 50.0,
//       Color color = Colors.green,
//       Color backgroundColor = Colors.transparent,
//       Color textColor = Colors.transparent,
//       Color maskColor = Colors.transparent}) {
//     EasyLoading.instance
//       ..indicatorType = type
//       ..indicatorSize = size
//       ..indicatorColor = color
//       ..backgroundColor = backgroundColor
//       ..textColor = textColor
//       ..maskColor = maskColor
//       ..loadingStyle = EasyLoadingStyle.custom;
//   }
}
