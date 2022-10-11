import '../../../aether_core.dart';

class AppHttpClientInterceptor extends Interceptor {
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    if (!options.extra.hasFlag('GQL')) {
      options.extra['__data__'] = options.data;
      options.data = await _encodeBody(options.data);
      options.queryParameters = _encodeQuery(options.queryParameters);
    }

    if (!options.extra.hasFlag('EXTERNAL')) {
      options.headers.addAll({
        'timezoneoffset': '${DateTime.now().timeZoneOffset.inHours}',
        if (Get.locale != null)
          'languagecode':
              '${Get.locale!.languageCode}_${Get.locale!.countryCode}',
        if (App.settings.apiKey.valueIsNotNullOrEmpty)
          'appkey': App.settings.apiKey(),
        if (options.method == 'POST') 'post-token': Uuid.newUuid()
      });
    }

    if (options.extra.hasFlag('LOADING_INDICATOR')) {
      App.showProgressIndicator();
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.requestOptions.extra.hasFlag('GQL')) {
      final data = response.data['data'] as Map<String, dynamic>;
      response.data = data.keys.length == 1 ? data.values.first : data;
    }

    if (!response.requestOptions.extra.hasFlag('EXTERNAL')) {
      final refreshToken = response.headers.value('x-refresh-token');
      if (refreshToken.isNotNullOrEmpty) {
        AppHttpClient.writeRefreshToken(refreshToken);
      }
    }

    if (response.requestOptions.extra.hasFlag('LOADING_INDICATOR')) {
      App.dismissProgressIndicator();
    }

    handler.next(response);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    if (err.type == DioErrorType.response &&
        err.response?.data != null &&
        err.requestOptions.extra.hasFlag('GQL')) {
      final data = err.response?.data!;
      final listError = data['errors'];
      if ((listError is List) && listError.isNotEmpty) {
        data['errors'] = listError
            .map((e) => {
                  'code': e['extensions']['code']?.toString(),
                  'message': e['message']?.toString()
                })
            .toList();
      }
    }

    if (!err.requestOptions.extra.hasFlag('RETRY') &&
        err.response != null &&
        err.response!.isUnauthorized) {
      if (await renewCredentialToken()) {
        // retry again
        final requestOptions = err.requestOptions;
        try {
          requestOptions.extra['RETRY'] = true;
          final response = await App.httpClient.dio.request(requestOptions.path,
              data: requestOptions.extra['__data__'] ?? requestOptions.data,
              queryParameters: requestOptions.queryParameters,
              options: Options(
                method: requestOptions.method,
                extra: requestOptions.extra,
                headers: requestOptions.headers,
              ));
          handler.resolve(response);
        } on DioError catch (retryErr) {
          handler.reject(retryErr);
        } on Exception catch (_) {}
      }
    }

    if (err.requestOptions.extra.hasFlag('LOADING_INDICATOR')) {
      App.dismissProgressIndicator();
    }

    if (!handler.isCompleted) handler.next(err);
  }

  Future<bool> renewCredentialToken() async {
    if (App.httpClient.refreshToken.isNullOrEmpty) return false;
    final oldProgressIndicatorLocked = App.progressIndicatorLocked;
    App.progressIndicatorLocked = true;
    try {
      await App.renewCredential();
    } on Exception catch (_) {
      return false;
    } finally {
      App.progressIndicatorLocked = oldProgressIndicatorLocked;
    }
    return true;
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

// https://stackoverflow.com/questions/72634402/unhandled-exception-bad-state-cant-finalize-a-finalized-multipartfile-and-onl
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
      // encoded[key] = MultipartFile.fromBytes(await value.file!.readAsBytes(),
      //     filename: value.file!.name);
      encoded[key] = MultipartFile.fromFileSync(value.file!.path,
          filename: value.file!.name);
    } else if (value is List<MediaFile>) {
      // encoded[key] = await Future.wait(value
      //     .map((mediaFile) async => MultipartFile.fromBytes(
      //         await mediaFile.file!.readAsBytes(),
      //         filename: mediaFile.file!.name))
      //     .toList());
      encoded[key] = value
          .map((mediaFile) => MultipartFile.fromFileSync(mediaFile.file!.path,
              filename: mediaFile.file!.name))
          .toList();
    } else if (value is XFile) {
      // encoded[key] = MultipartFile.fromBytes(await value.readAsBytes(),
      //     filename: value.name);
      encoded[key] =
          MultipartFile.fromFileSync(value.path, filename: value.name);
    } else if (value is List<XFile>) {
      // encoded[key] = await Future.wait(value
      //     .map((file) async => MultipartFile.fromBytes(await file.readAsBytes(),
      //         filename: file.name))
      //     .toList());
      encoded[key] = value
          .map((file) =>
              MultipartFile.fromFileSync(file.path, filename: file.name))
          .toList();
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
