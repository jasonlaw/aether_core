import 'package:flutter/services.dart';

class FilteringMoneyFormatter extends TextInputFormatter {
  final _decimalFormatter = FilteringTextInputFormatter.allow(RegExp(r'\d+'));
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue, // unused.
    TextEditingValue newValue,
  ) {
    var value = _decimalFormatter.formatEditUpdate(oldValue, newValue);
    var digitOnly = value.text.replaceAll('.', '');
    var money = ((int.tryParse(digitOnly) ?? 0) * 0.01).toStringAsFixed(2);
    return TextEditingValue(
        text: money, selection: TextSelection.collapsed(offset: money.length));
  }
}
