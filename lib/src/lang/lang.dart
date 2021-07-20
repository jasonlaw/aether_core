import 'package:aether_core/src/lang/zh.dart';

final Map<String, Map<String, String>> _translations = {
  'zh': zh,
};

Map<String, Map<String, String>> appendTranslations(
    Map<String, Map<String, String>>? tr) {
  tr?.forEach((key, map) {
    if (_translations.containsKey(key)) {
      _translations[key]!.addAll(map);
    } else {
      _translations[key] = map;
    }
  });
  return _translations;
}
