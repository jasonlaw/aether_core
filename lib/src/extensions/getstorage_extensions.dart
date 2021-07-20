import 'package:aether_core/aether_core.dart';

extension AetherGetStorageExtensions on GetStorage {
  Future removeAll(List<String> keys) async {
    await Future.forEach(keys, (String key) async => await this.remove(key));
  }
}
