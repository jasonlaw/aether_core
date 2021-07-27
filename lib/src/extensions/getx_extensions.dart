import 'package:aether_core/aether_core.dart';

extension GetxGetStorageExtensions on GetStorage {
  Future removeAll(List<String> keys) async {
    await Future.forEach(keys, (String key) async => await this.remove(key));
  }
}

extension GetxRxnExtensions on Rxn {
  void nil() => this(null);
  bool get isValueNull => this.value == null;
  bool get isValueNotNull => this.value != null;
}
