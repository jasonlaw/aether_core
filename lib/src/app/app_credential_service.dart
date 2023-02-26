part of 'app.dart';

abstract class AbstractCredentialService {
  Future signIn(dynamic request);
  // Future signInTenant(dynamic request);
  Future signOut();
  Future renewCredential();
  //before this is getCredential
  Future reloadCredential();
  Future<String> sendVerificationCode(dynamic request);
  Future signUp(dynamic request);
  Future resetPassword(dynamic request);
}

class CredentialService extends AbstractCredentialService {
  @override
  Future signIn(dynamic request) async {
    final response = await '/api/credential/signin'.api(body: request).post();
    App.identity.load(response.data);
  }

  // @override
  // Future signInTenant(dynamic request) async {
  //   final response =
  //       await '/api/credential/signin/tenant'.api(body: request).post();
  //   App.identity.load(response.data);
  // }

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

  @override
  Future<String> sendVerificationCode(dynamic request) async {
    final response =
        await '/api/credential/verificationcode'.api(body: request).post();
    return response.data!['code'];
  }

  @override
  Future signUp(dynamic request) async {
    await '/api/credential/signup'.api(body: request).post();
  }

  @override
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
