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

  late final EntityField<String> id = this.field("id");
  late final EntityField<String> username = this.field("username");
  late final EntityField<String> name = this.field("name");
  late final EntityField<String> email = this.field("email");
  late final EntityField<String> roles = this.field("roles");
  late final EntityField<String> refreshToken = this.field("refreshToken");
  bool get isAuthenticated => id.value.isNotNullOrEmpty;

  @mustCallSuper
  void logout() {
    GetStorage().remove('CredentialIdentity.RefreshToken');
    this.reset();
    //onLogoutCallback?.call();
  }
}
