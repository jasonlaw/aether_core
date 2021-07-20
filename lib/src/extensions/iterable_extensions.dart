extension AetherIterableExtensions<E> on Iterable<E> {
  E? get firstOrDefault => this.isEmpty ? null : this.first;
  bool any(bool Function(E) test) => this.where(test).isNotEmpty;
}
