extension AetherTypeExtensions on Type {
  bool isTypeOf<T>() => this == T;

  dynamic getDefault() {
    if (isTypeOf<String>()) return '';
    if (isTypeOf<bool>()) return false;
    if (isTypeOf<int>() || isTypeOf<num>()) return 0;
    if (isTypeOf<double>()) return 0.0;
    return null;
  }
}
