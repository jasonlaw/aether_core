extension AetherIntExtensions on int {
  bool hasFlag(int bitPosition) => (this & (1 << bitPosition)) != 0;
}
