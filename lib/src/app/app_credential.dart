part of 'app.dart';

class CredentialIdentity extends Entity {
  // CredentialIdentity() {
  //   this.token(GetStorage().read<String>('CredentialIdentity.Token'));

  //   this.token.onChanged(action: (value) {
  //     if (value != null) {
  //       GetStorage().write('CredentialIdentity.Token', value);
  //     }
  //   });
  // }

  late final Field<String> id = this.field("id");
  late final Field<String> username = this.field("username");
  late final Field<String> name = this.field("name");
  late final Field<String> email = this.field("email");
  late final Field<String> roles = this.field("roles");
  //late final Field<String> token = this.field("token");
  bool get isAuthenticated => id.value.isNotNullOrEmpty;

  void signIn(String id, String username, String name, String email,
      {String? roles}) {
    this.load({
      'id': id,
      'username': username,
      'name': name,
      'email': email,
      'roles': roles,
      //'token': token
    });
  }

  static void _writeRefreshToken(String? token) {
    GetStorage().write('CredentialIdentity.RefreshToken', token);
  }

  static String? get refreshToken {
    final token = GetStorage().read<String>('CredentialIdentity.RefreshToken');
    return token;
  }

  @mustCallSuper
  void signOut() {
    GetStorage().remove('CredentialIdentity.RefreshToken');
    this.reset();
  }
}
