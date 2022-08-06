import 'package:cross_file/cross_file.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../entity/entity.dart';
import '../../models/src/media_file.dart';
import '../../utils/src/enum_util.dart';
import 'adapters/adapter.dart';
import 'app_http_client_base.dart';
import 'app_http_client_interceptor.dart';

part 'app_http_client_query.dart';
part 'app_http_client_params.dart';

class AppHttpClient extends AppHttpClientBase {
  AppHttpClient() : super(dio: Dio()) {
    dio
      ..interceptors.add(AppHttpClientInterceptor())
      ..allowSelfSignedCert()
      ..enableCookieManager();
  }
}
