// import 'package:aether_core/aether_core.dart';

// extension AetherMapExtensions on Map<String, dynamic> {
//   Map<String, dynamic> params(List<dynamic> params) {
//     params.forEach((item) {
//       if (item is EntityField) {
//         this[item.name] = item.value;
//       } else if (item is FormInputField) {
//         this[item.name] = item.value;
//       } else if (item is InputField) {
//         this[item.name] = item.value;
//       } else if (item is Map<String, dynamic>) {
//         this.addAll(item);
//       } else if (item is MapEntry<String, dynamic>) {
//         this[item.key] = item.value;
//       } else {
//         assert(false, 'Invalid param type of ${item.runtimeType}');
//       }
//     });
//     return this;
//   }
// }
