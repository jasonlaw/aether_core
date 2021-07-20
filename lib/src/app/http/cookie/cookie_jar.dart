import 'dart:io';
import 'default_cookie_jar.dart';

/// CookieJar is a cookie manager for http requests。
abstract class CookieJar {
  factory CookieJar({bool ignoreExpires = false}) {
    return DefaultCookieJar(ignoreExpires: ignoreExpires);
  }

  /// Save the cookies for specified uri.
  Future<void> saveFromResponse(Uri uri, List<Cookie> cookies);

  /// Load the cookies for specified uri.
  Future<List<Cookie>> loadForRequest(Uri uri);

  Future<void> deleteAll();

  Future<void> delete(Uri uri, [bool withDomainSharedCookie = false]);

  final bool ignoreExpires = false;
}
