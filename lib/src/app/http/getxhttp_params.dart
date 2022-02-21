part of 'getxhttp.dart';

class Parameter {
  dynamic get paramValue => throw UnimplementedError();
  String get paramType => this.runtimeType.toString();
}

class RestBody {
  final Map<String, dynamic> data = {};
  bool _formDataMode;
  bool get formDataMode => _formDataMode;

  RestBody({bool formData: false}) : _formDataMode = formData;

  RestBody addField(FieldBase field) {
    if (field is ListField<MediaFile>) {
      _formDataMode = true;
      final _uploads =
          field.where((e) => e.canUpload).map((e) => e.file!).toList();
      if (_uploads.isEmpty) return this;
      return addParam(field.name, _uploads);
    }
    if (field is Field<MediaFile>) {
      _formDataMode = true;
      if (field.valueIsNull || !field().canUpload) return this;
      return addParam(field.name, field().file!);
    }
    return addParam(field.name, field.value);
  }

  RestBody addMap(Map<String, dynamic> map) {
    map.forEach((key, value) => addParam(key, value));
    return this;
  }

  RestBody addParam(String name, dynamic value) {
    if (value != null) {
      _formDataMode = _formDataMode || value is XFile || value is List<XFile>;
      data[name] = value;
    }
    return this;
  }

  /// param can be [FieldBase], [Map<String, dynamic>] or [MapEntry<String, dynamic>]
  RestBody addParams(List params) {
    params.forEach((item) {
      if (item is FieldBase) {
        this.addField(item);
      } else if (item is Map<String, dynamic>) {
        this.addMap(item);
      } else if (item is MapEntry<String, dynamic>) {
        this.addParam(item.key, item.value);
      }
    });
    return this;
  }

  static RestBody params(List<dynamic> params) {
    return RestBody().addParams(params);
  }
}
