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

  RestBody addField(EntityFieldBase field) {
    if (field is EntityListField<UploadFile>) {
      _formDataMode = true;
      if (!field.any((x) => x.isNew)) return this;
      return addParam(field.name, field().map((e) => e.file).toList());
    }
    if (field is EntityField<UploadFile>) {
      _formDataMode = true;
      if (field.valueIsNull || !field().isNew) return this;
      return addParam(field.name, field().file);
    }
    return addParam(field.name, field.value);
  }

  // RestBody addFormField(FormInputField field) {
  //   return addParam(field.name, field.value);
  // }

  // RestBody addInputField(InputField field) {
  //   return addParam(field.name, field.value);
  // }

  RestBody addMap(Map<String, dynamic> map) {
    map.forEach((key, value) => addParam(key, value));
    return this;
  }

  RestBody addParam(String name, dynamic value) {
    if (value != null) {
      _formDataMode = _formDataMode || value is File || value is List<File>;
      data[name] = value;
    }
    return this;
  }

  /// param can be [EntityField], [Map<String, dynamic>] or [MapEntry<String, dynamic>]
  RestBody addParams(List<dynamic> params) {
    params.forEach((item) {
      if (item is EntityField) {
        this.addField(item);
      }
      // else if (item is FormInputField) {
      //   this.addFormField(item);
      // } else if (item is InputField) {
      //   this.addInputField(item);
      // }
      else if (item is Map<String, dynamic>) {
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
