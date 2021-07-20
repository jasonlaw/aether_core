part of 'app.dart';

class GetxApi extends GetxHttp {
  final CookieManager cookie = CookieManager();

  GetxApi._() {
    client.timeout = Duration(seconds: App.settings.apiConnectTimeoutInSec()!);

    client.baseUrl = App.settings.apiBaseUrl();

    client.httpClient.addRequestModifier<void>((request) async {
      request.headers.addAll({
        if (App.useLocalTimezoneInHttp)
          "timezoneoffset": "${DateTime.now().timeZoneOffset.inHours}",
        if (Get.locale != null)
          "languagecode":
              "${Get.locale!.languageCode}_${Get.locale!.countryCode}",
        if (App.settings.apiKey().isNotNullOrEmpty)
          "appkey": App.settings.apiKey()!,
      });

      await cookie.loadForRequest(request);
      return request;
    });

    client.httpClient.addResponseModifier<void>((request, response) async {
      await cookie.saveFromResponse(response);
      return response;
    });
  }

  void addAuthenticator<T>(RequestModifier<T> auth) {
    client.httpClient.addAuthenticator(auth);
  }
}
