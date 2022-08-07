import 'package:flutter/foundation.dart';

import '../../../aether_core.dart';
import '../../utils/src/enum_util.dart';
import 'adapters/adapter.dart';
import 'app_http_client_interceptor.dart';

export 'package:dio/dio.dart';

part 'app_http_client_base.dart';
part 'app_http_client_exceptions.dart';
part 'app_http_client_query.dart';
part 'app_http_client_params.dart';
part 'app_http_client_extensions.dart';

class AppHttpClient extends AppHttpClientBase {
  AppHttpClient() : super(dio: Dio()) {
    dio
      ..options.baseUrl = App.settings.apiBaseUrl()
      ..options.sendTimeout = App.settings.apiConnectTimeoutInSec()
      ..allowSelfSignedCert()
      ..allowWithCredential()
      ..enableCookieManager()
      ..interceptors.add(AppHttpClientUnauthorizedInterceptor())
      ..interceptors.add(AppHttpClientInterceptor(this));
  }

  final String refreshTokenKey = 'x-refresh-token';
  String? get refreshToken => App.box.get('apphttpclient-$refreshTokenKey');
  void writeRefreshToken(String? token) {
    if (token == null) {
      App.box.delete('apphttpclient-$refreshTokenKey');
    } else {
      App.box.put('apphttpclient-$refreshTokenKey', token);
    }
  }

  Future<void> Function()? _refreshCredentialHandler;
  void addRefreshCredentialHandler(Future<void> Function() handler) =>
      _refreshCredentialHandler = handler;
  Future<void> refreshCredential() async {
    if (_refreshCredentialHandler != null) {
      await _refreshCredentialHandler!.call();
    }
  }

  void clearIdentityCache() {
    writeRefreshToken(null);
    dio.clearCookies();
  }
}
