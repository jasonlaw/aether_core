part of 'app.dart';

class AppCredential {
  Future signIn(dynamic request) async {
    final response = await '/api/credential/signin'.api(body: request).post();
    App.identity.load(response.data);
  }

  Future signOut() async {
    try {
      await '/api/credential/signout'.api().post();
    } on Exception catch (_) {
    } finally {
      App.identity.signOut();
    }
  }

  Future renewCredential() async {
    try {
      final response = await '/api/credential/refresh'.api(body: {
        'refreshToken': App.api.refreshToken,
        'checkSum': Crypto.checkSum(App.api.refreshToken!)
      }).post(
        extra: {
          'RENEW_CREDENTIAL': true,
        },
      );
      App.identity.load(response.data);
    } on AppNetworkResponseException catch (_) {
      App.api.clearIdentityCache();
      rethrow;
    }
  }

  //before this is getCredential
  Future reloadCredential() async {
    try {
      final response = await '/api/credential'.api().get(
            timeout: const Duration(seconds: 10),
          );
      App.identity.load(response.data);
    } on AppNetworkResponseException catch (_) {
      App.api.clearIdentityCache();
    } on Exception catch (err) {
      return Future.error(err.toString());
    }
  }

  Future<String> sendVerificationCode(dynamic request) async {
    final response =
        await '/api/credential/verificationcode'.api(body: request).post();
    return response.data!['code'];
  }

  Future signUp(dynamic request) async {
    await '/api/credential/signup'.api(body: request).post();
  }

  Future resetPassword(dynamic request) async {
    await '/api/credential/resetpassword'.api(body: request).post();
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
    required String password,
    String? name,
    String? tenantId,
  }) {
    return {
      'username': username,
      'password': password,
      if (name != null) 'name': name,
      if (tenantId != null) 'tenantId': tenantId,
    };
  }

  static Map<String, String> resetPasswordRequest({
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

  static Map<String, dynamic> verificationCodeRequest({
    required String emailOrPhone,
    required String action,
    String? name,
    bool validate = false,
  }) {
    return {
      'emailOrPhone': emailOrPhone,
      'action': action,
      if (name != null) 'name': name,
      'validate': validate
    };
  }
}
