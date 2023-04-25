// ignore_for_file: avoid_returning_this

part of 'app_http_client.dart';

class RestQuery {
  // final String action;
  final String url;
  final dynamic body;
  final Map<String, dynamic>? queryParameters;
  AppHttpClientBase? _client;

  Map<String, String>? _headers;
  Map<String, dynamic>? _extra;
  Duration? _timeout;
  ResponseType? _responseType;

  RestQuery(this.url, {this.body, this.queryParameters});

  RestQuery external({AppHttpClientBase? client}) {
    _client = client ?? App.http;
    return this;
  }

  RestQuery timeout(Duration value) {
    _timeout = value;
    return this;
  }

  RestQuery headers(Map<String, String> value) {
    _headers = value;
    return this;
  }

  RestQuery responseType(ResponseType responseType) {
    _responseType = responseType;
    return this;
  }

  RestQuery extra(Map<String, String> value) {
    _extra = value;
    return this;
  }

  Future<Response<T>> get<T>({
    Map<String, String>? headers,
    Map<String, dynamic>? extra,
    Duration? timeout,
    bool showLoadingIndicator = true,
  }) {
    return _request(
      'GET',
      headers: headers,
      extra: extra,
      timeout: timeout,
      showLoadingIndicator: showLoadingIndicator,
    );
  }

  Future<Response<T>> post<T>({
    Map<String, String>? headers,
    Map<String, dynamic>? extra,
    Duration? timeout,
    bool showLoadingIndicator = true,
  }) {
    return _request(
      'POST',
      headers: headers,
      extra: extra,
      timeout: timeout,
      showLoadingIndicator: showLoadingIndicator,
    );
  }

  Future<Response<T>> _request<T>(
    String method, {
    Map<String, String>? headers,
    Map<String, dynamic>? extra,
    Duration? timeout,
    Options? options,
    bool showLoadingIndicator = true,
  }) async {
    _headers ??= headers;
    _extra ??= extra;
    _timeout ??= timeout;
    _client ??= App.api;

    return await _client!.request(
      method,
      url,
      data: body is List<dynamic> ? RestBody.params(body) : body,
      queryParameters: queryParameters,
      options: Options(
        headers: _headers,
        responseType: _responseType,
        sendTimeout: _timeout,
        extra: _extra.union({'LOADING_INDICATOR': showLoadingIndicator}),
      ),
    );
  }
}

class GraphQLQuery {
  final String name;
  final List<dynamic> fields;
  Map<String, dynamic>? get params => _params;
  AppHttpClientBase? _client;

  Map<String, String>? _headers;
  Map<String, dynamic>? _extra;
  Duration? _timeout;
  Map<String, dynamic>? _params;

  final List<GraphQLQuery> _gqls = [];

  GraphQLQuery(this.name, this.fields, {Map<String, dynamic>? input})
      : _params = input;

  GraphQLQuery external({AppHttpClientBase? client}) {
    _client = client ?? App.http;
    return this;
  }

  GraphQLQuery input(Map<String, dynamic> params) {
    _params = params;
    return this;
  }

  GraphQLQuery timeout(Duration value) {
    _timeout = value;
    return this;
  }

  GraphQLQuery headers(Map<String, String> value) {
    _headers = value;
    return this;
  }

  GraphQLQuery extra(Map<String, String> value) {
    _extra = value;
    return this;
  }

  GraphQLQuery and(GraphQLQuery gql) {
    _gqls.add(gql);
    return this;
  }

  String _parseFields(List fieldList) {
    return fieldList.isEmpty
        ? 'void'
        : fieldList
            .map((x) {
              if (x is String) {
                return x;
              }
              if (x is Field<MediaFile>) {
                return x.gql(MediaFile.fragment).build();
              }
              if (x is FieldBase) {
                return x.name;
              }
              if (x is GraphQLQuery) {
                return x.build();
              }
              if (x is List) {
                return _parseFields(x);
              }
              assert(false,
                  'GraphQLQueryX::buildQuery => Not supported field type "${x.runtimeType}"');
              return null;
            })
            .where((x) => x != null)
            .join(', ');
  }

  String build() {
    // build fields
    final retFields = _parseFields(fields);

    // build params
    final retParams = _parseParamMap(params);

    final retQueries = <String>[];
    final query = retParams == null
        ? '$name { $retFields }'
        : '$name ( $retParams ) { $retFields }';

    retQueries.add(query);

    for (var subgql in _gqls) {
      retQueries.add(subgql.build());
    }

    return retQueries.join(', ');
  }

  String? _parseParamMap(Map<String, dynamic>? params) {
    if (params == null || params.isEmpty) return null;
    final retParams = params.entries
        .where((entry) => entry.value != null)
        .map((entry) =>
            '${paramCase(entry.key)}: ${_parseParamValue(entry.value)}')
        .toList();
    return retParams.join(', ');
  }

  String paramCase(String param) =>
      '${param[0].toLowerCase()}${param.substring(1)}';

  // String _parseParamValue(dynamic value) {
  //   if (value is int || value is num || value is bool) {
  //     return value.toString();
  //   } else if (value is Field) {
  //     return _parseParamValue(value.value);
  //   } else if (value is Map<String, dynamic>) {
  //     return '{ ${_parseParamMap(value)!} }';
  //   } else if (value is Entity) {
  //     return '{ ${_parseParamMap(value.toMap())!} }';
  //   } else if (value is List) {
  //     final items = <String>[];
  //     for (var item in value) {
  //       items.add(_parseParamValue(item));
  //     }
  //     return items.toString();
  //   } else if (value is EnumSafeType) {
  //     return value.gqlWords;
  //   } else {
  //     return '"$value"';
  //   }
  // }

  String _parseParamValue(dynamic value) {
    if (value is Field) {
      return _parseParamValue(value.value);
    } else if (value is Map<String, dynamic>) {
      return '{ ${_parseParamMap(value)!} }';
    } else if (value is Entity) {
      return '{ ${_parseParamMap(value.toMap())!} }';
    } else if (value is List) {
      return value.map(_parseParamValue).join(',');
    } else if (value is EnumSafeType) {
      return value.gqlWords;
    } else if (value is int || value is num || value is bool) {
      return value.toString();
    } else {
      return '"$value"';
    }
  }

  Future<Response<T>> query<T>({
    Map<String, String>? headers,
    Map<String, dynamic>? extra,
    Duration? timeout,
    bool showLoadingIndicator = true,
  }) {
    return _gql(
      'query',
      headers: headers,
      extra: extra,
      timeout: timeout,
      showLoadingIndicator: showLoadingIndicator,
    );
  }

  Future<Response<T>> mutation<T>({
    Map<String, String>? headers,
    Map<String, dynamic>? extra,
    Duration? timeout,
    bool showLoadingIndicator = true,
  }) {
    return _gql(
      'mutation',
      headers: headers,
      extra: extra,
      timeout: timeout,
      showLoadingIndicator: showLoadingIndicator,
    );
  }

  Future<Response<T>> _gql<T>(
    String method, {
    Map<String, String>? headers,
    Map<String, dynamic>? extra,
    Duration? timeout,
    bool showLoadingIndicator = true,
  }) async {
    _headers ??= headers;
    _extra ??= extra;
    _timeout ??= timeout;
    _client ??= App.api;

    return await _client!.gql(
      method,
      this,
      options: Options(
        headers: _headers,
        sendTimeout: _timeout,
        extra: _extra.union({'LOADING_INDICATOR': showLoadingIndicator}),
      ),
    );
  }
}
