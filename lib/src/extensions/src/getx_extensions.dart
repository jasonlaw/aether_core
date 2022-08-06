import 'package:get/get_rx/src/rx_types/rx_types.dart';

extension GetxRxnExtensions on Rxn {
  void nil() => value = null;
  bool get isValueNull => value == null;
  bool get isValueNotNull => value != null;
}
