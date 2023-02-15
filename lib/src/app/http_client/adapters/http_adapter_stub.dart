import 'package:dio/dio.dart';

extension AppHttpDioAdapter on Dio {
  void allowSelfSignedCert() {}
  void allowWithCredential() {}
  void enableCookieManager() {}
  void clearCookies() {}
}
