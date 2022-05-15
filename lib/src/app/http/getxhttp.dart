import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get_connect/http/src/exceptions/exceptions.dart';

import '../../entity/entity.dart';
import '../../models/models.dart';
import '../app.dart';

export 'cookie/cookie_manager.dart';

part 'getxhttp_extensions.dart';
part 'getxhttp_params.dart';
part 'getxhttp_query.dart';

class GetxHttp {
  late final GetConnect client;

  GetxHttp({bool allowAutoSignedCert = false, bool withCredentials = false}) {
    client = GetConnect(
      allowAutoSignedCert: allowAutoSignedCert,
      withCredentials: withCredentials,
    );
  }

  void Function(Response response)? _unauthorizedResponseHandler;

  void addUnauthorizedResponseHandler(
          void Function(Response response) handler) =>
      _unauthorizedResponseHandler = handler;

  bool _disableLoadingIndicator = false;
  bool _disableLoadingIndicatorPermanent = false;

  Duration? onlyOnceTimeout;

  void disableLoadingIndicator({bool oneTimeOnly = true}) {
    _disableLoadingIndicator = true;
    _disableLoadingIndicatorPermanent = !oneTimeOnly;
  }

  void enableLoadingIndicator() {
    _disableLoadingIndicator = false;
    _disableLoadingIndicatorPermanent = false;
  }

  Future<GraphQLResponse<T>> query<T>(
    dynamic query, {
    Map<String, dynamic>? variables,
    Map<String, String>? headers,
    Duration? timeout,
    bool disableLoadingIndicator = false,
  }) {
    return gql(
      'query',
      query,
      variables: variables,
      headers: headers,
      timeout: timeout,
      disableLoadingIndicator: disableLoadingIndicator,
    );
  }

  Future<GraphQLResponse> mutation(
    dynamic mutation, {
    Map<String, dynamic>? variables,
    Map<String, String>? headers,
    Duration? timeout,
    bool disableLoadingIndicator = false,
  }) {
    return gql(
      'mutation',
      mutation,
      variables: variables,
      headers: headers,
      timeout: timeout,
      disableLoadingIndicator: disableLoadingIndicator,
    );
  }

  Future<GraphQLResponse<T>> gql<T>(
    String method,
    dynamic query, {
    Map<String, dynamic>? variables,
    Map<String, String>? headers,
    Duration? timeout,
    bool disableLoadingIndicator = false,
  }) async {
    String _query;

    if (query is GraphQLQuery) {
      _query = query._buildQuery();
    } else {
      _query = '$query';
    }

    final body = '$method { $_query }';
    if (kDebugMode) {
      print(body);
    }

    return gqlRequest(
      body,
      variables: variables,
      headers: headers,
      timeout: timeout,
      disableLoadingIndicator: disableLoadingIndicator,
    );
  }

  Future<GraphQLResponse<T>> gqlRequest<T>(
    String query, {
    Map<String, dynamic>? variables,
    Map<String, String>? headers,
    Duration? timeout,
    bool disableLoadingIndicator = false,
  }) async {
    if (!disableLoadingIndicator) _showProgressIndicator();
    final encodedVariables = await _encodeJson(variables);
    client.httpClient.timeout = timeout ?? onlyOnceTimeout ?? client.timeout;

    return client
        .query<T>(query,
            url: '/graphql', variables: encodedVariables, headers: headers)
        .onError((error, stackTrace) {
      return GraphQLResponse<T>(graphQLErrors: [
        GraphQLError(
          code: null,
          message: error?.toString(),
        )
      ]);
    }).whenComplete(() async {
      onlyOnceTimeout = null;
      if (!disableLoadingIndicator) _dismissProgressIndicator();
    });
  }

  Future<Response<T>> get<T>(
    String api, {
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    String? contentType,
    T Function(dynamic)? decoder,
    Duration? timeout,
    bool disableLoadingIndicator = false,
  }) async {
    return request<T>(
      'get',
      api,
      query: query,
      headers: headers,
      contentType: contentType,
      decoder: decoder,
      timeout: timeout,
    );
  }

  Future<Response<T>> post<T>(
    String api, {
    dynamic body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    String? contentType,
    T Function(dynamic)? decoder,
    Duration? timeout,
    bool disableLoadingIndicator = false,
  }) {
    return request<T>(
      'post',
      api,
      body: body,
      query: query,
      headers: headers,
      contentType: contentType,
      decoder: decoder,
      timeout: timeout,
    );
  }

  Future<Response<T>> request<T>(
    String method,
    String api, {
    dynamic body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    String? contentType,
    T Function(dynamic)? decoder,
    Duration? timeout,
    bool disableLoadingIndicator = false,
  }) async {
    final encodedBody = await _encodeBody(body);
    final encodedQuery = _encodeQuery(query);

    if (!disableLoadingIndicator) _showProgressIndicator();
    client.httpClient.timeout = timeout ?? client.timeout;

    if (kDebugMode) print('${method.toUpperCase()} request: $api');

    var result = await client
        .request(api, method,
            body: encodedBody,
            query: encodedQuery,
            headers: headers,
            contentType: contentType,
            decoder: decoder)
        .whenComplete(() async {
      onlyOnceTimeout = null;
      if (!disableLoadingIndicator) _dismissProgressIndicator();
    });

    if (result.unauthorized && _unauthorizedResponseHandler != null) {
      GetMicrotask().exec(() => _unauthorizedResponseHandler!.call(result));
      //_unauthorizedResponseHandler!.call(result);
    }

    return result;
  }

  Future<dynamic> _encodeBody(dynamic body) async {
    if (body == null) return null;
    if (body is RestBody) {
      final encoded = await _encodeJson(body.data);
      if (body._formDataMode) {
        return FormData(encoded);
      }
      return encoded;
    }
    final encodedBody = await _encodeJson(body);
    if (encodedBody == null) return null;
    if (encodedBody is Map<String, dynamic> &&
        encodedBody.values.any((element) =>
            element is MultipartFile || element is List<MultipartFile>)) {
      return FormData(encodedBody);
    }
    return encodedBody;
  }

  void _showProgressIndicator() {
    if (!_disableLoadingIndicator && !_disableLoadingIndicatorPermanent) {
      App.showProgressIndicator(status: 'loading...'.tr);
    }
  }

  void _dismissProgressIndicator() {
    _disableLoadingIndicator = false;
    App.dismissProgressIndicator();
  }

  Response ok({dynamic body}) {
    return Response(
        statusCode: 200, statusText: 'ok', request: null, body: body);
  }

  Response error([String errorText = '']) {
    return Response(
        statusCode: null, statusText: errorText, request: null, body: null);
  }
}

Future<dynamic> _encodeJson(dynamic payload) async {
  if (payload == null) return null;
  if (payload is Parameter) {
    return await _encodeJson(payload.value);
  }
  if (payload is! Map<String, dynamic>) return payload;
  final encoded = <String, dynamic>{};

  for (final entry in payload.entries) {
    final key = entry.key;
    final value = entry.value;
    if (value is List<DateTime>) {
      encoded[key] = value.map((e) => e.toIso8601String()).toList();
    } else if (value is DateTime) {
      encoded[key] = value.toIso8601String();
    } else if (value is MediaFile) {
      encoded[key] = MultipartFile(await value.file!.readAsBytes(),
          filename: value.file!.name,
          contentType: value.file!.mimeType ?? 'application/octet-stream');
    } else if (value is List<MediaFile>) {
      encoded[key] = await Future.wait(value
          .map((mediaFile) async => MultipartFile(
              await mediaFile.file!.readAsBytes(),
              filename: mediaFile.file!.name,
              contentType:
                  mediaFile.file!.mimeType ?? 'application/octet-stream'))
          .toList());
    } else if (value is XFile) {
      encoded[key] = MultipartFile(await value.readAsBytes(),
          filename: value.name,
          contentType: value.mimeType ?? 'application/octet-stream');
    } else if (value is List<XFile>) {
      encoded[key] = await Future.wait(value
          .map((file) async => MultipartFile(await file.readAsBytes(),
              filename: file.name,
              contentType: file.mimeType ?? 'application/octet-stream'))
          .toList());
    } else if (value is Parameter) {
      encoded[key] = await _encodeJson(value.value);
    } else {
      encoded[key] = value;
    }
  }
  return encoded;
}

Map<String, dynamic>? _encodeQuery(Map<String, dynamic>? query) {
  if (query == null) return null;
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
