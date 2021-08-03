import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get_storage/get_storage.dart';

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
