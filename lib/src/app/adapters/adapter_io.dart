import 'package:flutter/foundation.dart';

import '../app_settings.dart';

void postConfigAppSettings(AppSettings settings) {
  if (kDebugMode) {
    settings
        .apiBaseUrl(settings.apiBaseUrl().replaceAll('localhost', '10.0.2.2'));
  }
}
