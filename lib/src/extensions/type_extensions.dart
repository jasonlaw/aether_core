extension AetherTypeExtensions on Type {
  bool isTypeOf<T>() => this == T;
  defaultValue() {
    if (this.isTypeOf<String>()) return '';
    if (this.isTypeOf<bool>()) return false;
    if (this.isTypeOf<int>() || this.isTypeOf<num>()) return 0;
    if (this.isTypeOf<double>()) return 0.0;
    return null;
  }
}
