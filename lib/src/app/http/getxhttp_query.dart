part of 'getxhttp.dart';

class RestQuery {
  // final String action;
  final String url;
  final dynamic body;
  final Map<String, dynamic>? query;
  GetxHttp? _http;

  RestQuery(this.url, {this.body, this.query});

  // ignore: avoid_returning_this
  RestQuery use(GetxHttp http) {
    _http ??= http;
    return this;
  }

  RestQuery external() {
    return use(App.http);
  }

  Future<Response<T>> get<T>({
    Map<String, String>? headers,
    T Function(dynamic)? decoder,
    Duration? timeout,
    bool disableLoadingIndicator = false,
  }) {
    return _request(
      'get',
      headers: headers,
      decoder: decoder,
      timeout: timeout,
    );
  }

  Future<Response<T>> post<T>({
    Map<String, String>? headers,
    String? contentType,
    T Function(dynamic)? decoder,
    Duration? timeout,
    bool disableLoadingIndicator = false,
  }) {
    return _request(
      'post',
      headers: headers,
      contentType: contentType,
      decoder: decoder,
      timeout: timeout,
    );
  }

  Future<Response<T>> _request<T>(
    String method, {
    Map<String, String>? headers,
    String? contentType,
    T Function(dynamic)? decoder,
    Duration? timeout,
    bool disableLoadingIndicator = false,
  }) async {
    _http ??= App.connect;
    if (disableLoadingIndicator) _http!.disableLoadingIndicator();
    var result = await _http!.request(
      method,
      url,
      body: body is List<dynamic> ? RestBody.params(body) : body,
      query: query,
      headers: headers,
      contentType: contentType,
      timeout: timeout,
    );
    if (result.isOk) {
      return Response(
          body: decoder?.call(result.body) ?? result.body,
          statusCode: result.statusCode,
          statusText: result.statusText,
          bodyString: result.bodyString,
          bodyBytes: result.bodyBytes,
          headers: result.headers);
    }
    return Response(
        statusCode: result.statusCode,
        statusText: result.errorText,
        bodyString: result.bodyString,
        bodyBytes: result.bodyBytes,
        headers: result.headers);
  }
}

class GraphQLQuery {
  final String name;
  final List<dynamic> fields;
  final Map<String, dynamic>? params;
  GetxHttp? _http;

  GraphQLQuery(this.name, this.fields, {this.params});

  // ignore: avoid_returning_this
  GraphQLQuery use(GetxHttp http) {
    _http ??= http;
    return this;
  }

  GraphQLQuery external() {
    return use(App.http);
  }

  String _buildQuery() {
    // build fields
    final _fields = fields
        .map((x) {
          if (x is String) {
            return x;
          }
          if (x is FieldBase) {
            return x.name;
          }
          if (x is GraphQLQuery) {
            return x._buildQuery();
          }
          assert(false, 'Not supported field type');
          return null;
        })
        .where((x) => x != null)
        .join(', ');

    // build params
    final _params = _buildParams(params);

    final query = _params == null
        ? '$name { $_fields }'
        : '$name ( $_params ) { $_fields }';

    return query;
  }

  String? _buildParams(Map<String, dynamic>? params) {
    if (params == null || params.isEmpty) return null;
    final _params = <String>[];
    params.forEach((key, value) {
      _params.add('$key: ${_parseParamValue(value)}');
    });
    return _params.join(', ');
  }

  String _parseParamValue(dynamic value) {
    if (value is int || value is num || value is bool) {
      return value.toString();
    }
    if (value is Map) {
      return json.encode(value);
    }
    if (value is Field) {
      return _parseParamValue(value.value);
    }
    if (value is Entity) {
      return _parseParamValue(value.toMap());
    }
    return '"$value"';
  }

  Future<GraphQLResponse<T>> query<T>({
    Map<String, String>? headers,
    Duration? timeout,
    T Function(dynamic)? decoder,
    bool disableLoadingIndicator = false,
  }) {
    return _gql(
      'query',
      headers: headers,
      timeout: timeout,
      decoder: decoder,
      disableLoadingIndicator: disableLoadingIndicator,
    );
  }

  Future<GraphQLResponse<T>> mutation<T>({
    Map<String, String>? headers,
    Duration? timeout,
    T Function(dynamic)? decoder,
    bool disableLoadingIndicator = false,
  }) {
    return _gql(
      'mutation',
      headers: headers,
      timeout: timeout,
      decoder: decoder,
      disableLoadingIndicator: disableLoadingIndicator,
    );
  }

  Future<GraphQLResponse<T>> _gql<T>(
    String method, {
    Map<String, String>? headers,
    Duration? timeout,
    T Function(dynamic)? decoder,
    bool disableLoadingIndicator = false,
  }) async {
    _http ??= App.connect;
    if (disableLoadingIndicator) _http!.disableLoadingIndicator();
    final result = await _http!.gql(
      method,
      this,
      headers: headers,
      timeout: timeout,
    );
    if (result.isOk) {
      var response = Response(
          body: {'data': decoder?.call(result.body[name]) ?? result.body[name]},
          request: result.request,
          bodyString: result.bodyString,
          bodyBytes: result.bodyBytes,
          headers: result.headers,
          statusText: result.statusText,
          statusCode: result.statusCode);
      return GraphQLResponse.fromResponse(response);
    }
    return GraphQLResponse(graphQLErrors: result.graphQLErrors);
  }
}
