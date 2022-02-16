import 'dart:io';

import 'package:aether_core/src/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get_connect/http/src/exceptions/exceptions.dart';

import '../../extensions.dart';
import '../../entity.dart';
import '../../models.dart';
import '../../app.dart';

export 'cookie/cookie_manager.dart';

part 'getxhttp_params.dart';
part 'getxhttp_query.dart';
part 'getxhttp_extensions.dart';

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
  }) {
    return gql(
      'query',
      query,
      variables: variables,
      headers: headers,
      timeout: timeout,
    );
  }

  Future<GraphQLResponse> mutation(
    dynamic mutation, {
    Map<String, dynamic>? variables,
    Map<String, String>? headers,
    Duration? timeout,
  }) {
    return gql(
      'mutation',
      mutation,
      variables: variables,
      headers: headers,
      timeout: timeout,
    );
  }

  Future<GraphQLResponse<T>> gql<T>(
    String method,
    dynamic query, {
    Map<String, dynamic>? variables,
    Map<String, String>? headers,
    Duration? timeout,
  }) {
    String _queryBody;
    Map<String, dynamic>? _variables = variables;

    if (query is GraphQLQuery) {
      final _gql = query.buildQuery();

      _variables ??= _gql['vars'];

      if (_variables!.isNotEmpty) {
        final Map<String, String> _gqlVarTypes = _gql['varTypes'];
        final _vars = _variables.entries.map((x) {
          final _varType = _gqlVarTypes[x.key] ?? _gqlDataType(x.value);
          return '\$${x.key}: $_varType';
        }).join(', ');
        _queryBody = '$method ( $_vars ) { ${_gql['body']} }';
      } else {
        _queryBody = '$method { ${_gql['body']} }';
      }
    } else {
      _queryBody = '$method $query';
    }

    _showProgressIndicator();
    final encodedVariables = _encodeJson(_variables);
    client.httpClient.timeout = timeout ?? client.timeout;
    return client
        .query<T>(_queryBody,
            url: '/graphql', variables: encodedVariables, headers: headers)
        .onError((error, stackTrace) {
      return GraphQLResponse<T>(graphQLErrors: [
        GraphQLError(
          code: null,
          message: error?.toString(),
        )
      ]);
    }).whenComplete(() => _dismissProgressIndicator());
  }

  String _gqlDataType(dynamic value) {
    if (value is String || value is String?) return GraphQLDataType.string;
    if (value is bool || value is bool?) return GraphQLDataType.boolean;
    if (value is int || value is int?) return GraphQLDataType.integer;
    if (value is double || value is double?) return GraphQLDataType.double;
    if (value is DateTime || value is DateTime?)
      return GraphQLDataType.dateTime;
    if (value is Parameter) return value.paramType;
    return value.runtimeType.toString();
  }

  Future<Response<T>> get<T>(
    String api, {
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    String? contentType,
    T Function(dynamic)? decoder,
    Duration? timeout,
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

  Future<Response<T>> request<T>(String method, String api,
      {dynamic body,
      Map<String, dynamic>? query,
      Map<String, String>? headers,
      String? contentType,
      T Function(dynamic)? decoder,
      Duration? timeout}) async {
    final encodedBody = _encodeBody(body);
    final encodedQuery = _encodeQuery(query);

    _showProgressIndicator();
    client.httpClient.timeout = timeout ?? client.timeout;

    if (kDebugMode) print('${method.toUpperCase()} request: $api');

    var result = await client
        .request(api, method,
            body: encodedBody,
            query: encodedQuery,
            headers: headers,
            contentType: contentType,
            decoder: decoder)
        .whenComplete(() => _dismissProgressIndicator());

    if (result.unauthorized && _unauthorizedResponseHandler != null) {
      GetMicrotask().exec(() => _unauthorizedResponseHandler!.call(result));
      //_unauthorizedResponseHandler!.call(result);
    }

    return result;
  }

  dynamic _encodeBody(dynamic body) {
    if (body is RestBody) {
      final encoded = _encodeJson(body.data);
      if (body._formDataMode) {
        return FormData(encoded);
      }
      return encoded;
    }
    return _encodeJson(body);
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
        statusCode: HttpStatus.ok, statusText: "ok", request: null, body: body);
  }

  Response error([String errorText = '']) {
    return Response(
        statusCode: null, statusText: errorText, request: null, body: null);
  }
}

dynamic _encodeJson(dynamic payload) {
  if (payload == null) return null;
  if (payload is Parameter) {
    return _encodeJson(payload.paramValue);
  }
  if (payload is! Map<String, dynamic>) return payload;
  final Map<String, dynamic> encoded = {};
  payload.forEach((key, value) {
    if (value is List<DateTime>)
      encoded[key] = value.map((e) => e.toIso8601String()).toList();
    else if (value is DateTime)
      encoded[key] = value.toIso8601String();
    else if (value is File) {
      encoded[key] = MultipartFile(value.readAsBytesSync(),
          filename: value.name, contentType: value.mimeType);
    } else if (value is List<File>) {
      encoded[key] = value
          .map((file) => MultipartFile(file.readAsBytesSync(),
              filename: file.name, contentType: file.mimeType))
          .toList();
    } else if (value is Parameter) {
      encoded[key] = _encodeJson(value.paramValue);
    } else
      encoded[key] = value;
  });
  return encoded;
}

Map<String, dynamic>? _encodeQuery(Map<String, dynamic>? query) {
  if (query == null) return null;
  query.removeWhere((key, value) => value == null);
  return query.map((key, value) {
    if (value is String || value is List<String>)
      return MapEntry(key, value.toString());
    if (value is List)
      return MapEntry(key, value.map((e) => e.toString()).toList());
    return MapEntry(key, value.toString());
  });
}
