import 'package:dio/adapter_browser.dart';
import 'package:dio/dio.dart';

extension AppHttpDioAdapter on Dio {
  void allowSelfSignedCert() {}
  void allowWithCredential() {
    print('xxxxxxgfsdfhds');
    print(options.extra);
    (httpClientAdapter as BrowserHttpClientAdapter).withCredentials = true;
  }

  void enableCookieManager() {}
  void clearCookies() {}
}
