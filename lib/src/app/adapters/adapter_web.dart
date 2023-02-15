// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:flutter/foundation.dart';

import '../app_settings.dart';

void postConfigAppSettings(AppSettings settings) {
  if (!kDebugMode) {
    final host = html.window.location.host;
    final protocol = html.window.location.protocol;
    final baseUrl = '$protocol//$host';
    settings.apiBaseUrl(baseUrl);
  }
}
