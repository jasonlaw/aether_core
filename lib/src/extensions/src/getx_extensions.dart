import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get_storage/get_storage.dart';

extension GetxGetStorageExtensions on GetStorage {
  Future removeAll(List<String> keys) async {
    await Future.forEach(keys, (String key) async => await remove(key));
  }
}

extension GetxRxnExtensions on Rxn {
  void nil() => value = null;
  bool get isValueNull => value == null;
  bool get isValueNotNull => value != null;
}
