part of 'app_http_client.dart';

/// A callback that returns a Dio response, presumably from a Dio method
/// it has called which performs an HTTP request, such as `dio.get()`,
/// `dio.post()`, etc.
typedef HttpLibraryMethod<T> = Future<Response<T>> Function();

/// Function which takes a Dio response object and an exception and returns
/// an optional [AppHttpClientException], optionally mapping the response
/// to a custom exception.
typedef ResponseExceptionMapper = AppNetworkResponseException? Function<T>(
  Response<T>,
  Exception,
);

/// Dio HTTP Wrapper with convenient, predictable exception handling.
class AppHttpClientBase {
  /// Create a new App HTTP Client with the specified Dio instance [dio]
  /// and an optional [exceptionMapper].
  AppHttpClientBase({required this.dio, this.exceptionMapper});

  final Dio dio;

  /// If provided, this function which will be invoked when a response exception
  /// occurs, allowing the response exception to be mapped to a custom
  /// exception class which extends [AppHttpClientException].
  final ResponseExceptionMapper? exceptionMapper;

  /// HTTP GET request.
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) {
    return request(
      'GET',
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// HTTP POST request.
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return request(
      'POST',
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  // /// HTTP PUT request.
  // Future<Response<T>> put<T>(
  //   String path, {
  //   dynamic data,
  //   Map<String, dynamic>? queryParameters,
  //   Options? options,
  //   CancelToken? cancelToken,
  //   ProgressCallback? onSendProgress,
  //   ProgressCallback? onReceiveProgress,
  // }) {
  //   return _request(
  //     'PUT',
  //     path,
  //     data: data,
  //     queryParameters: queryParameters,
  //     options: options,
  //     cancelToken: cancelToken,
  //     onSendProgress: onSendProgress,
  //     onReceiveProgress: onReceiveProgress,
  //   );
  // }

  // /// HTTP HEAD request.
  // Future<Response<T>> head<T>(
  //   String path, {
  //   dynamic data,
  //   Map<String, dynamic>? queryParameters,
  //   Options? options,
  //   CancelToken? cancelToken,
  // }) {
  //   return _request(
  //     'HEAD',
  //     path,
  //     data: data,
  //     queryParameters: queryParameters,
  //     options: options,
  //     cancelToken: cancelToken,
  //   );
  // }

  // /// HTTP DELETE request.
  // Future<Response<T>> delete<T>(
  //   String path, {
  //   dynamic data,
  //   Map<String, dynamic>? queryParameters,
  //   Options? options,
  //   CancelToken? cancelToken,
  // }) {
  //   return _request(
  //     'DELETE',
  //     path,
  //     data: data,
  //     queryParameters: queryParameters,
  //     options: options,
  //     cancelToken: cancelToken,
  //   );
  // }

  // /// HTTP PATCH request.
  // Future<Response<T>> patch<T>(
  //   String path, {
  //   dynamic data,
  //   Map<String, dynamic>? queryParameters,
  //   Options? options,
  //   CancelToken? cancelToken,
  //   ProgressCallback? onSendProgress,
  //   ProgressCallback? onReceiveProgress,
  // }) {
  //   return _request(
  //     'PATCH',
  //     path,
  //     data: data,
  //     queryParameters: queryParameters,
  //     options: options,
  //     cancelToken: cancelToken,
  //     onSendProgress: onSendProgress,
  //     onReceiveProgress: onReceiveProgress,
  //   );
  // }

  Future<Response<T>> request<T>(
    String method,
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    Debug.print(method);
    Debug.print(path);
    return _mapException(
      () => dio.request(
        path,
        data: data,
        queryParameters: queryParameters,
        options: DioMixin.checkOptions(method, options),
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      ),
    );
  }

  Future<Response<T>> gql<T>(
    String method,
    dynamic query, {
    String? path,
    Map<String, dynamic>? variables,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    String bodyQuery;

    if (query is GraphQLQuery) {
      bodyQuery = query.build();
    } else {
      bodyQuery = '$query';
    }

    final body = '$method { $bodyQuery }';

    options ??= Options();
    options.extra ??= {};
    options.extra!.addAll({'GQL': true});

    return _mapException(
      () => dio.post(
        path ?? '/graphql',
        data: {'query': body, 'variables': variables},
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      ),
    );
  }

  // Map Dio exceptions (and any other exceptions) to an exception type
  // supported by our application.
  Future<Response<T>> _mapException<T>(HttpLibraryMethod<T> method) async {
    try {
      return await method();
    } on DioError catch (exception) {
      switch (exception.type) {
        case DioErrorType.cancel:
          throw AppNetworkException(
            reason: AppNetworkExceptionReason.canceled,
            exception: exception,
          );
        case DioErrorType.connectTimeout:
        case DioErrorType.receiveTimeout:
        case DioErrorType.sendTimeout:
          throw AppNetworkException(
            reason: AppNetworkExceptionReason.timedOut,
            exception: exception,
          );
        case DioErrorType.response:
          // For DioErrorType.response, we are guaranteed to have a
          // response object present on the exception.
          final response = exception.response;
          if (response == null || response is! Response<T>) {
            // This should never happen, judging by the current source code
            // for Dio.
            throw AppNetworkResponseException(exception: exception);
          }
          throw exceptionMapper?.call(response, exception) ??
              AppNetworkResponseException(
                exception: exception,
                statusCode: response.statusCode,
                data: response.data,
              );
        case DioErrorType.other:
        default:
          throw AppHttpClientException(exception: exception);
      }
    } on Exception catch (e) {
      throw AppHttpClientException(
        exception:
            e, // is Exception ? e : Exception('Unknown exception ocurred'),
      );
    }
  }
}
