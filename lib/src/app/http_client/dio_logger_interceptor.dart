// ignore_for_file: avoid_print
part of 'app_http_client.dart';

final dioLoggerInterceptor =
    InterceptorsWrapper(onRequest: (RequestOptions options, handler) {
  if (!kDebugMode) handler.next(options);
  print(
      "┌------------------------------------------------------------------------------");
  print('| [DIO] Request: ${options.method} ${options.uri}');
  print('| ${options.data.toString()}');
  print('| Headers:');
  options.headers.forEach((key, value) {
    print('|\t$key: $value');
  });
  print(
      "├------------------------------------------------------------------------------");
  handler.next(options); //continue
}, onResponse: (Response response, handler) async {
  print(
      "| [DIO] Response [code ${response.statusCode}]: ${response.data.toString()}");
  print(
      "└------------------------------------------------------------------------------");
  handler.next(response);
  // return response; // continue
}, onError: (DioError error, handler) async {
  print("| [DIO] Error: ${error.error}: ${error.response.toString()}");
  print(
      "└------------------------------------------------------------------------------");
  handler.next(error); //continue
});
