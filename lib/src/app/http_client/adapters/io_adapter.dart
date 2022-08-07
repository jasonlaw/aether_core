import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/adapter.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

import '../../app.dart';

extension AppHttpDioAdapter on Dio {
  void allowSelfSignedCert() {
    (httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };
  }

  void allowWithCredential() {}

  void enableCookieManager() {
    final cookieManager = CookieManager(PersistCookieJar());
    interceptors.add(cookieManager);
    App.system['AppHttpCookieManager'] = cookieManager;
  }

  void clearCookies() {
    final cookieManager = App.system['AppHttpCookieManager'] as CookieManager?;
    cookieManager?.cookieJar.deleteAll();
  }
}
