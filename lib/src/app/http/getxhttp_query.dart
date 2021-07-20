part of 'getxhttp.dart';

class RestQuery {
  // final String action;
  final String api;
  final dynamic body;
  final Map<String, dynamic>? query;
  GetxHttp? _http;

  RestQuery(this.api, {this.body, this.query});

  RestQuery use(GetxHttp http) {
    _http ??= http;
    return this;
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
    T Function(dynamic)? decoder,
    Duration? timeout,
    bool disableLoadingIndicator = false,
  }) {
    return _request(
      'post',
      headers: headers,
      decoder: decoder,
      timeout: timeout,
    );
  }

  Future<Response<T>> _request<T>(
    String method, {
    Map<String, String>? headers,
    T Function(dynamic)? decoder,
    Duration? timeout,
    bool disableLoadingIndicator = false,
  }) async {
    _http ??= App.api;
    if (disableLoadingIndicator) _http!.disableLoadingIndicator();
    var result = await _http!.request(
      method,
      api,
      body: body is List<dynamic> ? RestBody.params(body) : body,
      query: query,
      headers: headers,
      //decoder: decoder,
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
  final Map<String, String>? paramTypes;
  GetxHttp? _http;

  GraphQLQuery(this.name, this.fields, {this.params, this.paramTypes});

  GraphQLQuery use(GetxHttp http) {
    _http ??= http;
    return this;
  }

  Map<String, dynamic> buildQuery() {
    final Map<String, dynamic> result = {};
    final Map<String, dynamic> vars = {};
    final Map<String, String> varTypes = {};

    if (params != null && params!.isNotEmpty) {
      vars.addAll(params!);
      if (paramTypes != null) {
        varTypes.addAll(paramTypes!);
      }
    }

    final _fields = fields
        .map((x) {
          if (x is EntityField) {
            return x.name;
          }
          if (x is GraphQLQuery) {
            final subquery = x.buildQuery();
            vars.addAll(subquery['params']);
            varTypes.addAll(subquery['paramTypes']);
            return subquery['payload'];
          }
          if (x is String) {
            return x;
          }
          return null;
        })
        .where((x) => x != null)
        .join(", ");

    final _variables = params?.entries.map((x) {
      if (x.value is Parameter) {
        varTypes[x.key] ??= x.value.paramType;
      }
      return '${x.key}: \$${x.key}';
    }).join(', ');

    final payload = _variables == null
        ? '$name { $_fields }'
        : '$name ( $_variables ) { $_fields }';

    result['body'] = payload;
    result['vars'] = vars;
    result['varTypes'] = varTypes;

    return result;
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
    _http ??= App.api;
    if (disableLoadingIndicator) _http!.disableLoadingIndicator();
    var result = await _http!.gql(
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

class GraphQLDataType {
  static const boolean = "Boolean";
  static const string = "String";
  static const dateTime = "DateTime";
  static const guid = "Uuid";
  static const double = "Double";
  static const integer = "Int";
}
