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
      if (response.headers?.containsKey('x-refresh-token') ?? false) {
        CredentialIdentity._writeRefreshToken(
            response.headers!['x-refresh-token']);
      }
      return response;
    });
  }

  void addAuthenticator<T>(RequestModifier<T> auth) {
    client.httpClient.addAuthenticator(auth);
  }

  void clearCookies() {
    _cookie.deleteAll();
  }
}
