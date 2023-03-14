import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/io.dart';
import 'package:path_provider/path_provider.dart';

import '../../app.dart';
import '../cookie_mgr.dart';

extension AppHttpDioAdapter on Dio {
  void allowSelfSignedCert() {
    (httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };
  }

  void allowWithCredential() {}

  Future<void> enableCookieManager() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final cj =
        PersistCookieJar(storage: FileStorage('${appDocDir.path}/.cookies/'));
    final cookieManager = CookieManager(cj);
    interceptors.add(cookieManager);
    App.system['AppHttpCookieManager'] = cookieManager;
  }

  void clearCookies() {
    final cookieManager = App.system['AppHttpCookieManager'] as CookieManager?;
    cookieManager?.cookieJar.deleteAll();
  }
}
