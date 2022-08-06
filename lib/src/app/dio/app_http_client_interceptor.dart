import 'package:cross_file/cross_file.dart';
import 'package:dio/dio.dart';

import '../../models/src/media_file.dart';
import 'app_http_client.dart';

class AppHttpClientInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.data = _encodeBody(options.data);
    options.queryParameters = _encodeQuery(options.queryParameters);
    if (options.extra['LOADING_INDICATOR'] ?? false) {
      print('SHOW PROGRESS INDICATOR');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.requestOptions.extra['LOADING_INDICATOR'] ?? false) {
      print('DISMISS PROGRESS INDICATOR');
    }
  }
}

class UnauthorizedInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.requestOptions.extra['NO_LOADING_INDICATOR'] ?? false) {}
  }
}

Future<dynamic> _encodeBody(dynamic body) async {
  if (body == null) return null;
  if (body is RestBody) {
    final encoded = await _encodeJson(body.data);
    if (body.formDataMode) {
      return FormData.fromMap(encoded);
    }
    return encoded;
  }
  final encodedBody = await _encodeJson(body);
  if (encodedBody == null) return null;
  if (encodedBody is Map<String, dynamic> &&
      encodedBody.values.any((element) =>
          element is MultipartFile || element is List<MultipartFile>)) {
    return FormData.fromMap(encodedBody);
  }
  return encodedBody;
}

Future<dynamic> _encodeJson(dynamic payload) async {
  if (payload == null) return null;
  if (payload is! Map<String, dynamic>) return payload;
  final encoded = <String, dynamic>{};

  for (final entry in payload.entries) {
    final key = entry.key;
    final value = entry.value;
    if (value == null) {
      // do nothing
    } else if (value is List<DateTime>) {
      encoded[key] = value.map((e) => e.toIso8601String()).toList();
    } else if (value is DateTime) {
      encoded[key] = value.toIso8601String();
    } else if (value is MediaFile) {
      encoded[key] = MultipartFile.fromBytes(await value.file!.readAsBytes(),
          filename: value.file!.name);
    } else if (value is List<MediaFile>) {
      encoded[key] = await Future.wait(value
          .map((mediaFile) async => MultipartFile.fromBytes(
              await mediaFile.file!.readAsBytes(),
              filename: mediaFile.file!.name))
          .toList());
    } else if (value is XFile) {
      encoded[key] = MultipartFile.fromBytes(await value.readAsBytes(),
          filename: value.name);
    } else if (value is List<XFile>) {
      encoded[key] = await Future.wait(value
          .map((file) async => MultipartFile.fromBytes(await file.readAsBytes(),
              filename: file.name))
          .toList());
    } else {
      encoded[key] = value;
    }
  }
  return encoded;
}

Map<String, dynamic> _encodeQuery(Map<String, dynamic> query) {
  query.removeWhere((key, value) => value == null);
  return query.map((key, value) {
    if (value is String || value is List<String>) {
      return MapEntry(key, value.toString());
    }
    if (value is List) {
      return MapEntry(key, value.map((e) => e.toString()).toList());
    }
    return MapEntry(key, value.toString());
  });
}
