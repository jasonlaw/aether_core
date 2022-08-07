// part of 'getxhttp.dart';

// class RestQuery {
//   // final String action;
//   final String url;
//   final dynamic body;
//   final Map<String, dynamic>? query;
//   GetxHttp? _http;

//   RestQuery(this.url, {this.body, this.query});

//   // ignore: avoid_returning_this
//   RestQuery use(GetxHttp http) {
//     _http ??= http;
//     return this;
//   }

//   RestQuery external() {
//     return use(App.http);
//   }

//   Future<Response<T>> get<T>({
//     Map<String, String>? headers,
//     T Function(dynamic)? decoder,
//     Duration? timeout,
//     bool disableLoadingIndicator = false,
//   }) {
//     return _request(
//       'get',
//       headers: headers,
//       decoder: decoder,
//       timeout: timeout,
//     );
//   }

//   Future<Response<T>> post<T>({
//     Map<String, String>? headers,
//     String? contentType,
//     T Function(dynamic)? decoder,
//     Duration? timeout,
//     bool disableLoadingIndicator = false,
//   }) {
//     return _request(
//       'post',
//       headers: headers,
//       contentType: contentType,
//       decoder: decoder,
//       timeout: timeout,
//     );
//   }

//   Future<Response<T>> _request<T>(
//     String method, {
//     Map<String, String>? headers,
//     String? contentType,
//     T Function(dynamic)? decoder,
//     Duration? timeout,
//     bool disableLoadingIndicator = false,
//   }) async {
//     _http ??= App.connect;
//     //if (disableLoadingIndicator) _http!.disableLoadingIndicator();
//     var result = await _http!.request(
//       method,
//       url,
//       body: body is List<dynamic> ? RestBody.params(body) : body,
//       query: query,
//       headers: headers,
//       contentType: contentType,
//       timeout: timeout,
//       disableLoadingIndicator: disableLoadingIndicator,
//     );
//     if (result.isOk) {
//       return Response(
//           body: decoder?.call(result.body) ?? result.body,
//           statusCode: result.statusCode,
//           statusText: result.statusText,
//           bodyString: result.bodyString,
//           bodyBytes: result.bodyBytes,
//           headers: result.headers);
//     }
//     return Response(
//         statusCode: result.statusCode,
//         statusText: result.errorText,
//         bodyString: result.bodyString,
//         bodyBytes: result.bodyBytes,
//         headers: result.headers);
//   }
// }

// class GraphQLQuery {
//   final String name;
//   final List<dynamic> fields;
//   final Map<String, dynamic>? params;
//   GetxHttp? _http;

//   final List<GraphQLQuery> _gqls = [];

//   GraphQLQuery(this.name, this.fields, {this.params});

//   // ignore: avoid_returning_this
//   GraphQLQuery use(GetxHttp http) {
//     _http ??= http;
//     return this;
//   }

//   // ignore: avoid_returning_this
//   GraphQLQuery and(GraphQLQuery gql) {
//     _gqls.add(gql);
//     return this;
//   }

//   GraphQLQuery external() {
//     return use(App.http);
//   }

//   String _build() {
//     // build fields
//     final retFields = fields
//         .map((x) {
//           if (x is String) {
//             return x;
//           }
//           if (x is Field<MediaFile>) {
//             return x.gql(MediaFile.fragment)._build();
//           }
//           if (x is FieldBase) {
//             return x.name;
//           }
//           if (x is GraphQLQuery) {
//             return x._build();
//           }
//           assert(false,
//               'GraphQLQuery::_buildQuery => Not supported field type "${x.runtimeType}"');
//           return null;
//         })
//         .where((x) => x != null)
//         .join(', ');

//     // build params
//     final retParams = _parseParamMap(params);

//     final retQueries = <String>[];
//     final query = retParams == null
//         ? '$name { $retFields }'
//         : '$name ( $retParams ) { $retFields }';

//     retQueries.add(query);

//     for (var subgql in _gqls) {
//       retQueries.add(subgql._build());
//     }

//     return retQueries.join(', ');
//   }

//   String? _parseParamMap(Map<String, dynamic>? params) {
//     if (params == null || params.isEmpty) return null;
//     final retParams = <String>[];
//     params.forEach((key, value) {
//       retParams.add('${paramCase(key)}: ${_parseParamValue(value)}');
//     });
//     return retParams.join(', ');
//   }

//   String paramCase(String param) =>
//       '${param[0].toLowerCase()}${param.substring(1)}';

//   String _parseParamValue(dynamic value) {
//     if (value is int || value is num || value is bool) {
//       return value.toString();
//     } else if (value is Field) {
//       return _parseParamValue(value.value);
//     } else if (value is Map<String, dynamic>) {
//       return '{ ${_parseParamMap(value)!} }';
//     } else if (value is Entity) {
//       return '{ ${_parseParamMap(value.toMap())!} }';
//     } else if (value is List) {
//       final items = <String>[];
//       for (var item in value) {
//         items.add(_parseParamValue(item));
//       }
//       return items.toString();
//     } else if (value is EnumSafeType) {
//       return value.gqlWords;
//     } else {
//       return '"$value"';
//     }
//   }

//   Future<GraphQLResponse<T>> query<T>({
//     Map<String, String>? headers,
//     Duration? timeout,
//     T Function(dynamic)? decoder,
//     bool disableLoadingIndicator = false,
//   }) {
//     return _gql(
//       'query',
//       headers: headers,
//       timeout: timeout,
//       decoder: decoder,
//       disableLoadingIndicator: disableLoadingIndicator,
//     );
//   }

//   Future<GraphQLResponse<T>> mutation<T>({
//     Map<String, String>? headers,
//     Duration? timeout,
//     T Function(dynamic)? decoder,
//     bool disableLoadingIndicator = false,
//   }) {
//     return _gql(
//       'mutation',
//       headers: headers,
//       timeout: timeout,
//       decoder: decoder,
//       disableLoadingIndicator: disableLoadingIndicator,
//     );
//   }

//   Future<GraphQLResponse<T>> _gql<T>(
//     String method, {
//     Map<String, String>? headers,
//     Duration? timeout,
//     T Function(dynamic)? decoder,
//     bool disableLoadingIndicator = false,
//   }) async {
//     _http ??= App.connect;
//     //if (disableLoadingIndicator) _http!.disableLoadingIndicator();
//     final result = await _http!.gql(
//       method,
//       this,
//       headers: headers,
//       timeout: timeout,
//       disableLoadingIndicator: disableLoadingIndicator,
//     );
//     if (result.isOk) {
//       var response = Response(
//           body: _gqls.isEmpty
//               ? {
//                   'data': decoder?.call(result.body[name]) ?? result.body[name],
//                 }
//               : {
//                   'data': result.body,
//                 },
//           request: result.request,
//           bodyString: result.bodyString,
//           bodyBytes: result.bodyBytes,
//           headers: result.headers,
//           statusText: result.statusText,
//           statusCode: result.statusCode);
//       return GraphQLResponse.fromResponse(response);
//     }
//     return GraphQLResponse(graphQLErrors: result.graphQLErrors);
//   }
// }
