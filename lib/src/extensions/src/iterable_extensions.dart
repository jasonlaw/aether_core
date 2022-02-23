extension AetherIterableExtensions<E> on Iterable<E> {
  E? get firstOrDefault => isEmpty ? null : first;
  bool any(bool Function(E) test) => where(test).isNotEmpty;
}
