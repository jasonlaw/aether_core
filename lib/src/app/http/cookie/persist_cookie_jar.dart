import 'dart:convert';
import 'dart:io';

import '../../../extensions/extensions.dart';

import '../../app.dart';
import 'default_cookie_jar.dart';
import 'serializable_cookie.dart';

/// [PersistCookieJar] is a cookie manager which implements the standard
/// cookie policy declared in RFC. [PersistCookieJar]  persists the cookies
/// in files, so if the application exit, the cookies always exist unless
/// call [delete] explicitly.
class PersistCookieJar extends DefaultCookieJar {
  ///
  /// [persistSession]: Whether persisting the cookies that without
  /// "expires" or "max-age" attribute;
  /// If false, the session cookies will be discarded;
  /// otherwise, the session cookies will be persisted.
  ///
  /// [ignoreExpires]: save/load even cookies that have expired.
  ///
  /// [storage]: Defaults to FileStorage
  PersistCookieJar({this.persistSession = true, bool ignoreExpires = false})
      : super(ignoreExpires: ignoreExpires);

  /// Whether persisting the cookies that without "expires" or "max-age"
  /// attribute;
  final bool persistSession;

  static const _indexKey = '.index';
  static const _domainsKey = '.domains';

  late Set<String> _hostSet;

  bool _initialized = false;

  //late final GetStorage _storage = GetStorage();

  Future<void> forceInit() => _checkInitialized(force: true);

  Future<void> _checkInitialized({bool force = false}) async {
    if (force || !_initialized) {
      // Load domain cookies
      var str = App.storage.read<String>(_domainsKey);
      if (str != null && str.isNotEmpty) {
        try {
          final Map<String, dynamic> jsonData = json.decode(str);

          final cookies = jsonData.map((String domain, dynamic cookies) {
            final domainCookies =
                cookies.cast<String, dynamic>().map((String path, dynamic map) {
              final cookieForPath = map.cast<String, String>();
              final realCookies =
                  cookieForPath.map<String, SerializableCookie>((
                String cookieName,
                String cookie,
              ) {
                return MapEntry(
                  cookieName,
                  SerializableCookie.fromJson(cookie),
                );
              });

              return MapEntry(path, realCookies);
            });

            return MapEntry<String,
                Map<String, Map<String, SerializableCookie>>>(
              domain,
              domainCookies,
            );
          });
          domainCookies
            ..clear()
            ..addAll(cookies);
        } on Exception catch (_) {
          await App.storage.remove(_domainsKey);
        }
      }

      str = App.storage.read(_indexKey);
      if ((str != null && str.isNotEmpty)) {
        try {
          final list = json.decode(str);
          _hostSet = Set<String>.from(list);
        } on Exception catch (_) {
          await App.storage.remove(_indexKey);
        }
      } else {
        _hostSet = <String>{};
      }
      _initialized = true;
    }
  }

  @override
  Future<List<Cookie>> loadForRequest(Uri uri) async {
    await _checkInitialized();
    await _load(uri);
    return super.loadForRequest(uri);
  }

  @override
  Future<void> saveFromResponse(Uri uri, List<Cookie> cookies) async {
    await _checkInitialized();
    if (cookies.isNotEmpty) {
      await super.saveFromResponse(uri, cookies);
      if (cookies.every((Cookie e) => e.domain == null)) {
        await _save(uri);
      } else {
        await _save(uri, true);
      }
    }
  }

  Map<String, Map<String, SerializableCookie>> _filter(
    Map<String, Map<String, SerializableCookie>> domain,
  ) {
    return domain
        .cast<String, Map<String, dynamic>>()
        .map((String path, Map<String, dynamic> cookies) {
      final cleanCookies = cookies.map((String cookieName, dynamic cookie) {
        final isSession =
            cookie.cookie.expires == null && cookie.cookie.maxAge == null;
        if ((isSession && persistSession) ||
            (persistSession && !cookie.isExpired())) {
          return MapEntry<String, SerializableCookie>(cookieName, cookie);
        } else {
          // key = null, and remove after
          return MapEntry<String?, SerializableCookie>(null, cookie);
        }
      })
        ..removeWhere((String? k, SerializableCookie v) => k == null);

      return MapEntry<String, Map<String, SerializableCookie>>(
        path,
        cleanCookies.cast<String, SerializableCookie>(),
      );
    });
  }

  /// Delete cookies for specified [uri].
  /// This API will delete all cookies for the `uri.host`, it will ignored
  /// the `uri.path`.
  ///
  /// [withDomainSharedCookie] `true` will delete the domain-shared cookies.
  @override
  Future<void> delete(Uri uri, [bool withDomainSharedCookie = false]) async {
    await _checkInitialized();
    await super.delete(uri, withDomainSharedCookie);
    final host = uri.host;
    if (_hostSet.remove(host)) {
      await App.storage.write(_indexKey, json.encode(_hostSet.toList()));
    }

    await App.storage.remove(host);

    if (withDomainSharedCookie) {
      await App.storage.write(_domainsKey, json.encode(domainCookies));
    }
  }

  /// Delete all cookies files under [dir] directory and clear them out from RAM
  @override
  Future<void> deleteAll() async {
    await _checkInitialized();
    await super.deleteAll();
    final keys = _hostSet.toList(growable: true)
      ..addAll([_indexKey, _domainsKey]);

    await App.storage.removeAll(keys);
    _hostSet.clear();
  }

  Future<void> _save(Uri uri, [bool withDomainSharedCookie = false]) async {
    final host = uri.host;

    if (!_hostSet.contains(host)) {
      _hostSet.add(host);
      App.storage.write(_indexKey, json.encode(_hostSet.toList()));
    }
    final cookies = hostCookies[host];

    if (cookies != null) {
      App.storage.write(host, json.encode(_filter(cookies)));
    }

    if (withDomainSharedCookie) {
      final filterDomainCookies =
          domainCookies.map((key, value) => MapEntry(key, _filter(value)));
      App.storage.write(_domainsKey, json.encode(filterDomainCookies));
    }
  }

  Future<void> _load(Uri uri) async {
    final host = uri.host;
    if (_hostSet.contains(host) && hostCookies[host] == null) {
      final str = App.storage.read(host);

      if (str != null && str.isNotEmpty) {
        Map<String, Map<String, dynamic>> cookies;
        try {
          cookies = json.decode(str).cast<String, Map<String, dynamic>>();

          cookies.forEach((String path, Map<String, dynamic> map) {
            map.forEach((String k, dynamic v) {
              map[k] = SerializableCookie.fromJson(v);
            });
          });

          hostCookies[host] =
              cookies.cast<String, Map<String, SerializableCookie>>();
        } on Exception catch (_) {
          await App.storage.remove(host);
        }
      }
    }
  }
}
