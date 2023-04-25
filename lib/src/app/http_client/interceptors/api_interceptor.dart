import '../../../../aether_core.dart';

class ApiInterceptor extends Interceptor {
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    if (!options.isGQL) {
      options.extra['__data__'] = options.data;
      options.data = await _encodeBody(options.data);
      options.queryParameters = _encodeQuery(options.queryParameters);
    }

    if (!options.isExternal) {
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

    if (options.isLoadingIndicator) {
      App.showProgressIndicator();
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    if (response.requestOptions.isGQL) {
      if (response.gqlErrors) {
        handler.reject(
            DioError(
              requestOptions: response.requestOptions,
              error: response.gqlErrorMessage,
              message: response.gqlErrorMessage,
              response: response,
            ),
            response.isUnauthorized);
        return;
      }
      final data = response.data['data'] as Map<String, dynamic>;
      response.data = data.keys.length == 1 ? data.values.first : data;
    }

    if (!response.requestOptions.isExternal) {
      final refreshToken = response.headers.value('x-refresh-token');
      if (refreshToken.isNotNullOrEmpty) {
        AppHttpClient.writeRefreshToken(refreshToken);
      }
    }

    if (response.requestOptions.isLoadingIndicator) {
      App.dismissProgressIndicator();
    }

    if (response.requestOptions.isSignOut) {
      App.credential.signOut();
    }

    handler.next(response);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    if (err.response != null && err.response!.isUnauthorized) {
      if (!err.requestOptions.isRetry) {
        if (await renewCredentialToken()) {
          // retry again
          final requestOptions = err.requestOptions;
          try {
            requestOptions.setRetryFlag();
            final response = await App.api.dio.request(requestOptions.path,
                data: requestOptions.extra['__data__'] ?? requestOptions.data,
                queryParameters: requestOptions.queryParameters,
                options: Options(
                  method: requestOptions.method,
                  extra: requestOptions.extra,
                  headers: requestOptions.headers,
                ));
            if (response.gqlErrors) {
              handler.reject(DioError(
                requestOptions: response.requestOptions,
                error: response.gqlErrorMessage,
                message: response.gqlErrorMessage,
                response: response,
              ));
            } else {
              handler.resolve(response);
            }
          } on DioError catch (retryErr) {
            handler.reject(retryErr);
          } on Exception catch (_) {}
        } else {
          App.credential.signOut();
        }
      }
    }

    if (err.requestOptions.isLoadingIndicator) {
      App.dismissProgressIndicator();
    }

    if (err.requestOptions.isSignOut) {
      App.credential.signOut();
    }

    if (!handler.isCompleted) handler.next(err);
  }

  Future<bool> renewCredentialToken() async {
    if (App.api.refreshToken.isNullOrEmpty) return false;
    final oldProgressIndicatorLocked = App.progressIndicatorLocked;
    App.progressIndicatorLocked = true;
    try {
      var response = await App.credentialService.refresh();
      if (response.gqlErrors) {
        return false;
      }
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
// Future<dynamic> _encodeJson(dynamic payload) async {
//   if (payload == null) return null;
//   if (payload is! Map<String, dynamic>) return payload;
//   final encoded = <String, dynamic>{};

//   for (final entry in payload.entries) {
//     final key = entry.key;
//     final value = entry.value;
//     if (value == null) {
//       // do nothing
//     } else if (value is List<DateTime>) {
//       encoded[key] = value.map((e) => e.toIso8601String()).toList();
//     } else if (value is DateTime) {
//       encoded[key] = value.toIso8601String();
//     } else if (value is MediaFile) {
//       encoded[key] = MultipartFile.fromFileSync(value.file!.path,
//           filename: value.file!.name);
//     } else if (value is List<MediaFile>) {
//       encoded[key] = await Future.wait(value
//           .map((mediaFile) async => MultipartFile.fromBytes(
//               await mediaFile.file!.readAsBytes(),
//               filename: mediaFile.file!.name))
//           .toList());
//     } else if (value is XFile) {
//       encoded[key] = MultipartFile.fromBytes(await value.readAsBytes(),
//           filename: value.name);
//     } else if (value is List<XFile>) {
//       encoded[key] = await Future.wait(value
//           .map((file) async => MultipartFile.fromBytes(await file.readAsBytes(),
//               filename: file.name))
//           .toList());
//     } else {
//       encoded[key] = value;
//     }
//   }
//   return encoded;
// }

// Map<String, dynamic> _encodeQuery(Map<String, dynamic> query) {
//   query.removeWhere((key, value) => value == null);
//   return query.map((key, value) {
//     if (value is String || value is List<String>) {
//       return MapEntry(key, value.toString());
//     }
//     if (value is List) {
//       return MapEntry(key, value.map((e) => e.toString()).toList());
//     }
//     return MapEntry(key, value.toString());
//   });
// }

// https://stackoverflow.com/questions/72634402/unhandled-exception-bad-state-cant-finalize-a-finalized-multipartfile-and-onl
Future<dynamic> _encodeJson(dynamic payload) async {
  if (payload == null) return null;
  if (payload is! Map<String, dynamic>) return payload;

  final encoded = Map<String, dynamic>.from(payload)
    ..removeWhere((_, v) => v == null);

  for (final key in encoded.keys.toList()) {
    final value = encoded[key];

    if (value is List<DateTime>) {
      encoded[key] = value.map((e) => e.toIso8601String()).toList();
    } else if (value is DateTime) {
      encoded[key] = value.toIso8601String();
    } else if (value is MediaFile) {
      encoded[key] = await MultipartFile.fromFile(
        value.file!.path,
        filename: value.file!.name,
      );
    } else if (value is List<MediaFile>) {
      encoded[key] = await Future.wait(value.map((mediaFile) async {
        final bytes = await mediaFile.file!.readAsBytes();
        return MultipartFile.fromBytes(
          bytes,
          filename: mediaFile.file!.name,
        );
      }));
    } else if (value is XFile) {
      encoded[key] = MultipartFile.fromBytes(
        await value.readAsBytes(),
        filename: value.name,
      );
    } else if (value is List<XFile>) {
      encoded[key] = await Future.wait(value.map((file) async {
        final bytes = await file.readAsBytes();
        return MultipartFile.fromBytes(
          bytes,
          filename: file.name,
        );
      }));
    }
  }

  return encoded;
}

Map<String, dynamic> _encodeQuery(Map<String, dynamic> query) {
  return query
    ..removeWhere((key, value) => value == null)
    ..map((key, value) {
      if (value is List) {
        return MapEntry(key, value.map((e) => e.toString()).toList());
      }
      return MapEntry(key, value.toString());
    });
}
