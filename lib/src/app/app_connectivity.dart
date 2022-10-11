import 'dart:async';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import '../../aether_core.dart';
export 'package:connectivity_plus/connectivity_plus.dart'
    show ConnectivityResult;

class AppConnectivity {
  final networkType = ConnectivityResult.none.obs;
  final hasServerConnection = false.obs;
  late final StreamSubscription<ConnectivityResult> _subscription;
  Timer? _timer;

  late final Duration _pingDuration;
  late final Duration _timeoutDuration;

  static AppConnectivity? _instance;
  AppConnectivity() {
    _instance = this;
    _subscription =
        Connectivity().onConnectivityChanged.listen(_updateNetworkConnectivity);

    final pingSec = App.settings.apiOfflinePingInSec();
    final timeoutMilliSec =
        min(pingSec * 500, App.settings.apiConnectTimeoutInSec() * 800);
    _pingDuration = Duration(seconds: pingSec);
    _timeoutDuration = Duration(milliseconds: timeoutMilliSec);
  }

  Future<void> check() async {
    final result = await Connectivity().checkConnectivity();
    _updateNetworkConnectivity(result);
  }

  Future<bool> _checkServerConnection() async {
    _timer?.cancel();
    if (networkType() == ConnectivityResult.none) {
      hasServerConnection(false);
    } else {
      final response = await '/ping'
          .api()
          .get(
            timeout: _pingDuration,
            disableLoadingIndicator: true,
          )
          .catchError((error) => App.connect.error(error.toString()));
      if (!response.isOk) {
        _timer?.cancel();
        _timer = Timer(_timeoutDuration, _checkServerConnection);
      }
      hasServerConnection(response.isOk);
    }
    return hasServerConnection();
  }

  Future<void> _updateNetworkConnectivity(ConnectivityResult result) async {
    networkType(result);
    _checkServerConnection();
  }

  void cancel() {
    _timer?.cancel();
    _subscription.cancel();
  }

  static void dispose() {
    _instance?.cancel();
  }
}
