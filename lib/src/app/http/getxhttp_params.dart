// part of 'getxhttp.dart';

// @immutable
// class EnumSafeType {
//   final dynamic value;
//   const EnumSafeType(this.value);
//   String get gqlWords => EnumUtils.convertToGqlWords(value);
// }

// extension EnumSafeTypeExt on Enum {
//   EnumSafeType get safeType => EnumSafeType(this);
// }

// class RestBody {
//   final Map<String, dynamic> data = {};
//   bool _formDataMode;
//   bool get formDataMode => _formDataMode;

//   RestBody({bool formData = false}) : _formDataMode = formData;

//   void _addParam(String name, dynamic value) {
//     if (value != null) {
//       _formDataMode = _formDataMode ||
//           value is MediaFile ||
//           value is List<MediaFile> ||
//           value is XFile ||
//           value is List<XFile>;

//       data[name] = value;
//     }
//   }

//   void addField(FieldBase field) {
//     if (field is ListField<MediaFile>) {
//       _formDataMode = true;
//       final uploads = field.where((e) => e.canUpload).toList();
//       if (uploads.isNotEmpty) _addParam(field.name, uploads);
//       return;
//     }
//     if (field is Field<MediaFile>) {
//       _formDataMode = true;
//       if (field.valueIsNull || !field().canUpload) return;
//       _addParam(field.name, field());
//       return;
//     }
//     return _addParam(field.name, field.value);
//   }

//   void addMap(Map<String, dynamic> map) {
//     map.forEach(_addParam);
//   }

//   /// param can be [FieldBase], [Map<String, dynamic>] or
//   /// [MapEntry<String, dynamic>]
//   void add(List params) {
//     for (final item in params) {
//       if (item is FieldBase) {
//         addField(item);
//       } else if (item is Map<String, dynamic>) {
//         addMap(item);
//       } else if (item is MapEntry<String, dynamic>) {
//         _addParam(item.key, item.value);
//       }
//     }
//   }

//   static RestBody params(List<dynamic> params) {
//     return RestBody()..add(params);
//   }
// }
