import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../../app/app.dart';

class Crypto {
  static String checkSum(String data, {String? signingKey}) {
    final key = utf8.encode(signingKey ?? App.settings.apiKey());
    final bytes = utf8.encode(data);

    final hmacSha256 = Hmac(sha256, key);
    final digest = hmacSha256.convert(bytes);
    return digest.toString().replaceAll('-', '').toLowerCase();
  }
}
