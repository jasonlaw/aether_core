import 'package:flutter/cupertino.dart';

// Black:   \x1B[30m
// Red:     \x1B[31m
// Green:   \x1B[32m
// Yellow:  \x1B[33m
// Blue:    \x1B[34m
// Magenta: \x1B[35m
// Cyan:    \x1B[36m
// White:   \x1B[37m
// Reset:   \x1B[0m

@immutable
class Debug {
  /// developer.log
  static void print(Object? object) {
    //developer.log('\x1B[35m$object\x1B[0m', name: 'AETHER');
    debugPrint('\x1B[36m[AETHER]\x1B[0m \x1B[35m$object\x1B[0m');
  }
}
