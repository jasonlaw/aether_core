import 'filtering_input_formatter/money_filter.dart';
import 'filtering_input_formatter/profanity_filter.dart';

class FilteringTextInputFormatters {
  static final money = FilteringMoneyFormatter();
  static final censor = CensorProfanityInputFormatter();
}
