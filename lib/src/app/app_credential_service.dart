part of 'app.dart';

abstract class AbstractCredentialService {
  Future signIn(dynamic request);
  Future signInTenant(dynamic request);
  Future signOut();
  Future renewCredential();
  //before this is getCredential
  Future reloadCredential();
}

class CredentialService extends AbstractCredentialService {
  @override
  Future signIn(dynamic request) async {
    final response = await '/api/credential/signin'.api(body: request).post();
    App.identity.load(response.data);
  }

  @override
  Future signInTenant(dynamic request) async {
    final response =
        await '/api/credential/signin/tenant'.api(body: request).post();
    App.identity.load(response.data);
  }

  @override
  Future signOut() async {
    try {
      await '/api/credential/signout'.api().post();
    } on Exception catch (_) {
    } finally {
      App.identity.signOut();
    }
  }

  @override
  Future renewCredential() async {
    try {
      final response = await '/api/credential/refresh'.api(body: {
        'refreshToken': App.httpClient.refreshToken,
        'checkSum': Crypto.checkSum(App.httpClient.refreshToken!)
      }).post(
        extra: {
          'RENEW_CREDENTIAL': true,
        },
      );
      App.identity.load(response.data);
    } on AppNetworkResponseException catch (_) {
      App.httpClient.clearIdentityCache();
      rethrow;
    }
  }

  //before this is getCredential
  @override
  Future reloadCredential() async {
    try {
      final response = await '/api/credential'.api().get(
            timeout: const Duration(seconds: 10),
          );
      App.identity.load(response.data);
    } on AppNetworkResponseException catch (_) {
      App.httpClient.clearIdentityCache();
    } on Exception catch (err) {
      return Future.error(err.toString());
    }
  }

  static Map<String, String> userPass(
    String username,
    String password,
  ) {
    return {
      'username': username,
      'password': password,
    };
  }

  static Map<String, String> idToken(
    String idToken,
  ) {
    return {
      'idToken': idToken,
    };
  }

  static Map<String, String> tenantUserPass(
    String tenantId,
    String username,
    String password,
  ) {
    return {'username': username, 'password': password, 'tenantId': tenantId};
  }

  static Map<String, String> tenantIdToken(
    String tenantId,
    String idToken,
  ) {
    return {
      'idToken': idToken,
      'tenantId': tenantId,
    };
  }

  static Map<String, String> signUpRequest({
    required String username,
    String? password,
    String? tenantId,
  }) {
    return {
      'username': username,
      if (password != null) 'password': password,
      if (tenantId != null) 'tenantId': tenantId,
    };
  }
}
