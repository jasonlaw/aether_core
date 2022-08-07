part of 'app.dart';

class CredentialIdentity extends Entity {
  late final Field<String> id = field('id');
  late final Field<String> username = field('username');
  late final Field<String> name = field('name');
  late final Field<String> email = field('email');
  late final Field<String> roles = field('roles');
  bool get isAuthenticated => id.valueIsNotNullOrEmpty;

  final _roles = <String>{};

  CredentialIdentity() {
    roles.onLoaded(
      action: (value) {
        _roles.clear();
        if (value.isNotNullOrEmpty) {
          _roles.addAll(value!
              .split(',')
              .map((e) => e.trim())
              .where((element) => element.isNotEmpty)
              .toSet());
        }
      },
      reset: _roles.clear,
    );
  }

  void signIn(String id, String username, String name, String email,
      {String? roles}) {
    load({
      'id': id,
      'username': username,
      'name': name,
      'email': email,
      'roles': roles,
    });
  }

  // static void _writeRefreshToken(String? token) {
  //   if (token == null) {
  //     GetStorage().remove('CredentialIdentity.RefreshToken');
  //     return;
  //   }
  //   GetStorage().write('CredentialIdentity.RefreshToken', token);
  //   //   print('Write token = $refreshToken');
  // }

  // String? get refreshToken {
  //   final token = GetStorage().read<String>('CredentialIdentity.RefreshToken');
  //   if (token == null || token == '') return null;
  //   return '$token ${Crypto.checkSum(token)}';
  // }

  // Future<String?> getRefreshTokenAsync() async {
  //   return GetStorage().read<String>('CredentialIdentity.RefreshToken');
  // }

  bool hasRoles(Set<String> roles) {
    if (_roles.isEmpty || roles.isEmpty) return false;
    return roles.intersection(_roles).containsAll(roles);
  }

  bool anyRoles(Set<String> roles) {
    if (_roles.isEmpty || roles.isEmpty) return false;
    return roles.intersection(_roles).isNotEmpty;
  }

  @mustCallSuper
  void signOut() {
    App.httpClient.clearIdentityCache();
    reset();
  }
}
