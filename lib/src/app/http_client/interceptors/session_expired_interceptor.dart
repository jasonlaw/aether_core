import '../../../../aether_core.dart';

/// [SessionExpiredInterceptor] is used to handle properly logout when a login
/// session is expired.
/// It's better to add [LogInterceptor] to the tail of the interceptor queue,
/// otherwise the changes made in the interceptor behind A will not be printed out.
/// This is because the execution of interceptors is in the order of addition.
class SessionExpiredInterceptor extends Interceptor {
  SessionExpiredInterceptor({
    required this.signoutHandler,
    this.condition,
  });

  final Future<void> Function() signoutHandler;

  final bool Function(DioError err)? condition;

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    if (err.response != null &&
        err.response!.isUnauthorized &&
        !err.response!.extra.hasFlag('SIGN_OUT')) {
      if (condition?.call(err) ?? false) {
        signoutHandler();
      }
    }

    handler.next(err);
  }
}
