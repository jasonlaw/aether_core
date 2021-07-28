part of 'app.dart';

class CredentialIdentity extends Entity {
  CredentialIdentity() {
    this.refreshToken(
        GetStorage().read<String>('CredentialIdentity.RefreshToken'));

    this.refreshToken.onChanged(action: (value) {
      if (value != null) {
        GetStorage().write('CredentialIdentity.RefreshToken', value);
      }
    });
  }

  late final Field<String> id = this.field("id");
  late final Field<String> username = this.field("username");
  late final Field<String> name = this.field("name");
  late final Field<String> email = this.field("email");
  late final Field<String> roles = this.field("roles");
  late final Field<String> refreshToken = this.field("refreshToken");
  bool get isAuthenticated => id.value.isNotNullOrEmpty;

  @mustCallSuper
  void logout() {
    GetStorage().remove('CredentialIdentity.RefreshToken');
    this.reset();
    //onLogoutCallback?.call();
  }
}
