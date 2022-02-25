part of 'getxhttp.dart';

class Parameter {
  final String type;
  final dynamic value;
  const Parameter({required this.type, required this.value});
}

class RestBody {
  final Map<String, dynamic> data = {};
  bool _formDataMode;
  bool get formDataMode => _formDataMode;

  RestBody({bool formData = false}) : _formDataMode = formData;

  void _addParam(String name, dynamic value) {
    if (value != null) {
      _formDataMode = _formDataMode ||
          value is MediaFile ||
          value is List<MediaFile> ||
          value is XFile ||
          value is List<XFile>;

      data[name] = value;
    }
  }

  void addField(FieldBase field) {
    if (field is ListField<MediaFile>) {
      _formDataMode = true;
      final _uploads = field.where((e) => e.canUpload).toList();
      if (_uploads.isNotEmpty) _addParam(field.name, _uploads);
      return;
    }
    if (field is Field<MediaFile>) {
      _formDataMode = true;
      if (field.valueIsNull || !field().canUpload) return;
      _addParam(field.name, field());
      return;
    }
    return _addParam(field.name, field.value);
  }

  void addMap(Map<String, dynamic> map) {
    map.forEach(_addParam);
  }

  /// param can be [FieldBase], [Map<String, dynamic>] or [MapEntry<String, dynamic>]
  void add(List params) {
    for (final item in params) {
      if (item is FieldBase) {
        addField(item);
      } else if (item is Map<String, dynamic>) {
        addMap(item);
      } else if (item is MapEntry<String, dynamic>) {
        _addParam(item.key, item.value);
      }
    }
  }

  static RestBody params(List<dynamic> params) {
    return RestBody()..add(params);
  }
}
