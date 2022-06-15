part of 'app.dart';

class GetxConnect extends GetxHttp {
  final CookieManager _cookie = CookieManager();

  GetxConnect._() : super(allowAutoSignedCert: true, withCredentials: true) {
    client.timeout = Duration(seconds: App.settings.apiConnectTimeoutInSec());

    client.baseUrl = App.settings.apiBaseUrl();

    client.httpClient.addRequestModifier<void>((request) async {
      request.headers.addAll({
        'timezoneoffset': '${DateTime.now().timeZoneOffset.inHours}',
        if (Get.locale != null)
          'languagecode':
              '${Get.locale!.languageCode}_${Get.locale!.countryCode}',
        if (App.settings.apiKey.valueIsNotNullOrEmpty)
          'appkey': App.settings.apiKey(),
        if (request.method == 'post') 'post-token': Uuid.newUuid()
      });

      await _cookie.loadForRequest(request);
      return request;
    });

    client.httpClient.addResponseModifier<void>((request, response) async {
      await _cookie.saveFromResponse(response);
      if (response.headers?.containsKey(refreshTokenKey) ?? false) {
        _writeRefreshToken(response.headers![refreshTokenKey]);
      }
      return response;
    });
  }

  // void addAuthenticator<T>(RequestModifier<T> auth) {
  //   _authenticator = auth as RequestModifier;
  //   client.httpClient.addAuthenticator(auth);
  // }

  final String refreshTokenKey = 'x-refresh-token';
  String? get refreshToken =>
      App.storage.read<String>('getxconnect-$refreshTokenKey');
  void _writeRefreshToken(String? token) {
    if (token == null) {
      App.storage.remove('getxconnect-$refreshTokenKey');
    } else {
      App.storage.write('getxconnect-$refreshTokenKey', token);
    }
  }

  void clearIdentityCache() {
    _writeRefreshToken(null);
    _cookie.deleteAll();
  }
}
