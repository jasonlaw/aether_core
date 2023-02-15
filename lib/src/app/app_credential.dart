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
      {String? tenantId, String? roles}) {
    load({
      'id': id,
      'username': username,
      'name': name,
      'email': email,
      'tenantId': tenantId,
      'roles': roles,
    });
  }

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
