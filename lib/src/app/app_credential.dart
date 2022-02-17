part of 'app.dart';

class CredentialIdentity extends Entity {
  late final Field<String> id = this.field("id");
  late final Field<String> username = this.field("username");
  late final Field<String> name = this.field("name");
  late final Field<String> email = this.field("email");
  late final Field<String> roles = this.field("roles");
  bool get isAuthenticated => id.value.isNotNullOrEmpty;

  void signIn(String id, String username, String name, String email,
      {String? roles}) {
    this.load({
      'id': id,
      'username': username,
      'name': name,
      'email': email,
      'roles': roles,
    });
  }

  static void _writeRefreshToken(String? token) {
    if (token == null) {
      GetStorage().remove('CredentialIdentity.RefreshToken');
      return;
    }
    GetStorage().write('CredentialIdentity.RefreshToken', token);
    //   print('Write token = $refreshToken');
  }

  static bool get hasRefreshToken =>
      GetStorage().hasData('CredentialIdentity.RefreshToken');

  static Map<String, String>? get refreshTokenHeader {
    final token = GetStorage().read<String>('CredentialIdentity.RefreshToken');
    if (token == null) return null;
    final tokenWithChecksum = '$token ${App.crypto.checkSum(token)}';
    return {'x-refresh-token': tokenWithChecksum};
  }

  @mustCallSuper
  void signOut() {
    GetStorage().remove('CredentialIdentity.RefreshToken');
    this.reset();
  }
}
