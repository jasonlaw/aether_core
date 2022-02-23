extension AetherNullableStringExtensions on String? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  bool get isNotNullOrEmpty => this != null && this!.isNotEmpty;
}

extension AetherStringExtensions on String {
  String truncate(int maxLength, {String remaining = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }
}
// extension AetherStringExtensions on String {
//   /// check if the string is a date
//   bool get isDate {
//     try {
//       DateTime.parse(this);
//       return true;
//     } catch (e) {
//       return false;
//     }
//   }
