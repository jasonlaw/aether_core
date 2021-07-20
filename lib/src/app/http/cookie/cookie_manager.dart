import 'dart:io';

import 'package:aether_core/aether_core.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get_connect/http/src/request/request.dart';

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
    await _saveCookies(response);
  }

  Future<void> _saveCookies(Response response) async {
    if (response.headers == null ||
        !response.headers!.containsKey(HttpHeaders.setCookieHeader)) return;

    var setCookie = response.headers![HttpHeaders.setCookieHeader];

    if (setCookie != null) {
      var uri = response.request!.url;
      var cookies = setCookie
          .split(',')
          .map((str) => Cookie.fromSetCookieValue(str))
          .toList();
      await _cookieJar.saveFromResponse(uri, cookies);
    }
  }

  static String getCookies(List<Cookie> cookies) {
    return cookies.map((cookie) => '${cookie.name}=${cookie.value}').join('; ');
  }
}
