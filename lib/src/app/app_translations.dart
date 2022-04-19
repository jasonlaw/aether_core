import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:version/version.dart';

import '../../aether_core.dart';

class AppTranslations extends Translations {
  final _keys = <String, Map<String, String>>{};
  final languages = <String, String>{};

  @override
  Map<String, Map<String, String>> get keys => _keys;

  void import(Map<String, Map<String, String>> keys) {
    keys.forEach((key, value) {
      final kv = key.split(':');
      languages[kv.first] = kv.last;
      _keys[kv.first] = value;
    });
    //_writeToStorage();
  }

  /// Download translations which maintained in google sheets.
  /// First column will be used as the translation key.
  /// In GoogleSheets:
  ///   ..Publish the sheet under consideration as csv file, using
  ///   File -> Publish to the web, make sure to select the option
  ///   "Automatically republish when changes are made"
  ///   ..Copy the link provided by googleSheets for the csv connectivity url
  Future download({required String url, bool force = false}) async {
    final isDownloadRequired =
        force || _versionOutdated() || !_readFromStorage();

    if (!isDownloadRequired) return;

    final response = await url.api().external().get(
        timeout: const Duration(minutes: 10),
        headers: {'accept': 'text/csv;charset=UTF-8'});

    final bytes = utf8.encode(response.body);
    final csv = Stream<List<int>>.fromIterable([bytes]);

    final fields = await csv
        .transform(utf8.decoder)
        .transform(const CsvToListConverter(
          shouldParseNumbers: false,
        ))
        .toList();

    final index = fields[0]
        .cast<String>()
        .map((key) => key.trim().replaceAll('\n', ''))
        .takeWhile((x) => x.isNotEmpty)
        .map((key) {
      final kv = key.split(':');
      return {kv.first: kv.last};
    }).toList();

    for (var r = 1; r < fields.length; r++) {
      final rowValues = fields[r];
      final translationKey = rowValues[0];
      for (var c = 1; c < index.length; c++) {
        final langcode = index[c].keys.first;
        languages[langcode] ??= index[c].values.first;
        final lang = _keys[langcode] ??= {};
        lang[translationKey] = rowValues[c];
      }
    }
    _writeToStorage();
  }

  bool _readFromStorage() {
    final storedKeys = App.storage
        .read<Map<String, Map<String, String>>>('${App.name}.tr.keys');
    if (storedKeys == null) return false;
    final storedLanguages =
        App.storage.read<Map<String, String>>('${App.name}.tr.languages');
    _keys.assignAll(storedKeys);
    if (storedLanguages != null) {
      languages.assignAll(storedLanguages);
    }
    return true;
  }

  void _writeToStorage() {
    App.storage.write('${App.name}.tr.version', App.version);
    App.storage.write('${App.name}.tr.keys', _keys);
    App.storage.write('${App.name}.tr.languages', languages);
  }

  bool _versionOutdated() {
    final storedVersion = App.storage.read<String>('${App.name}.tr.version');
    return storedVersion.isNotNullOrEmpty &&
        Version.parse(App.version) > Version.parse(storedVersion);
  }
}
