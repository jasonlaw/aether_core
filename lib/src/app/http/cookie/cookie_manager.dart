import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/request/request.dart';
import 'package:get/get_connect/http/src/response/response.dart';

import 'cookie_jar.dart';
import 'persist_cookie_jar.dart';

/// Don't use this class in Browser environment
class CookieManager {
  /// Cookie manager for http requests。Learn more details about
  /// CookieJar please refer to [cookie_jar](https://github.com/flutterchina/cookie_jar)
  final CookieJar _cookieJar = PersistCookieJar();

  Future loadForRequest(Request request) async {
    if (kIsWeb) return;
    await _cookieJar.loadForRequest(request.url).then((cookies) {
      var cookie = getCookies(cookies);
      if (cookie.isNotEmpty) {
        request.headers[HttpHeaders.cookieHeader] = cookie;
      }
    });
  }

  Future saveFromResponse(Response response) async {
    if (kIsWeb) return;
    await _saveCookies(response).catchError((err) {
      Get.log(err.toString(), isError: true);
    });
  }

  Future<void> _saveCookies(Response response) async {
    if (response.headers == null ||
        !response.headers!.containsKey(HttpHeaders.setCookieHeader)) return;

    var setCookie = response.headers![HttpHeaders.setCookieHeader];

    if (setCookie != null) {
      var uri = response.request!.url;
      var cookies = setCookie
          .replaceAll(', ', '`COMMA_SPACE`')
          .split(',')
          .map((str) =>
              Cookie.fromSetCookieValue(str.replaceAll('`COMMA_SPACE`', ', ')))
          .toList();
      await _cookieJar.saveFromResponse(uri, cookies);
    }
  }

  void deleteAll() {
    _cookieJar.deleteAll();
  }

  static String getCookies(List<Cookie> cookies) {
    return cookies.map((cookie) => '${cookie.name}=${cookie.value}').join('; ');
  }
}
