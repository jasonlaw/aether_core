part of 'app.dart';

class Credential extends Entity {
  late final Field<String> id = field('id');
  late final Field<String> username = field('username');
  late final Field<String> name = field('name');
  late final Field<String> email = field('email');
  late final Field<String> phone = field('phone');
  late final Field<String> roles = field('roles');
  //late final Field<String> tenantId = field('tenantId');
  bool get isAuthenticated => id.valueIsNotNullOrEmpty;

  final _roles = <String>{};

  Credential() {
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

  void signIn(String id, String username,
      {String? name, String? email, String? phone, String? roles}) {
    load({
      'id': id,
      'username': username,
      'name': name ?? username,
      'email': email,
      'phone': phone,
      //'tenantId': tenantId,
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
    App.api.clearCredentialCache();
    reset();
  }
}
