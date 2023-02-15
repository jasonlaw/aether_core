import 'package:dio/browser.dart';
import 'package:dio/dio.dart';

extension AppHttpDioAdapter on Dio {
  void allowSelfSignedCert() {}
  void allowWithCredential() {
    (httpClientAdapter as BrowserHttpClientAdapter).withCredentials = true;
  }

  void enableCookieManager() {}
  void clearCookies() {}
}
