part of 'app.dart';

class CredentialService {
  Future signIn(dynamic request) async {
    final response = await '/api/credential/signin'.api(body: request).post();
    App.credential.load(response.data);
  }

  Future signOut() async {
    try {
      await '/api/credential/signout'.api().post(
        extra: {
          'SIGN_OUT': true,
        },
      );
    } on Exception catch (_) {
    } finally {
      App.credential.signOut();
    }
  }

  Future<Response> refresh() async {
    return await '/api/credential/refresh'.api(
      body: {
        'refreshToken': App.api.refreshToken,
        'checkSum': Crypto.checkSum(App.api.refreshToken!)
      },
    ).post(
      extra: {
        'RENEW_CREDENTIAL': true,
      },
    );
  }

  //before this is getCredential
  Future load() async {
    try {
      final response = await '/api/credential'.api().get(
            timeout: const Duration(seconds: 10),
          );
      App.credential.load(response.data);
    } on AppNetworkResponseException catch (_) {
      App.api.clearCredentialCache();
    } on Exception catch (err) {
      return Future.error(err.toString());
    }
  }

  Future resetPassword(dynamic request) async {
    await '/api/credential/resetpassword'.api(body: request).post();
  }

  static Map<String, String> signInInput(
    String username,
    String password,
  ) {
    return {
      'username': username,
      'password': password,
    };
  }

  static Map<String, String> resetPasswordInput({
    required String username,
    required String password,
    String? tenantId,
  }) {
    return {
      'username': username,
      'password': password,
      if (tenantId != null) 'tenantId': tenantId,
    };
  }
}
