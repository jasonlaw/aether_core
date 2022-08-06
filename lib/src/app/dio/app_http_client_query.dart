part of 'app_http_client.dart';

class RestQuery {
  // final String action;
  final String url;
  final dynamic body;
  final Map<String, dynamic>? query;
  AppHttpClientBase? _client;

  RestQuery(this.url, {this.body, this.query});

  // ignore: avoid_returning_this
  RestQuery use(AppHttpClientBase client) {
    _client ??= client;
    return this;
  }

  // RestQuery external() {
  //   return use(App.http);
  // }

  Future<Response<T>> get<T>({
    Map<String, String>? headers,
    Duration? timeout,
    bool disableLoadingIndicator = false,
    bool showLoadingIndicator = true,
  }) {
    return _request(
      'GET',
      headers: headers,
      timeout: timeout,
      showLoadingIndicator: showLoadingIndicator && !disableLoadingIndicator,
    );
  }

  Future<Response<T>> post<T>({
    Map<String, String>? headers,
    Duration? timeout,
    bool disableLoadingIndicator = false,
    bool showLoadingIndicator = true,
  }) {
    return _request(
      'POST',
      headers: headers,
      timeout: timeout,
      showLoadingIndicator: showLoadingIndicator && !disableLoadingIndicator,
    );
  }

  Future<Response<T>> _request<T>(
    String method, {
    Map<String, String>? headers,
    String? contentType,
    T Function(dynamic)? decoder,
    Duration? timeout,
    bool showLoadingIndicator = true,
  }) async {
    //_client ??= App.connect;
    //if (disableLoadingIndicator) _http!.disableLoadingIndicator();
    return await _client!.request(
      method,
      url,
      data: body is List<dynamic> ? RestBody.params(body) : body,
      queryParameters: query,
      options: Options(
          headers: headers,
          sendTimeout: timeout?.inSeconds,
          extra: {'LOADING_INDICATOR': showLoadingIndicator}),
    );
  }
}
