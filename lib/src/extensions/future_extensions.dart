import 'package:flutter/foundation.dart';

extension AetherFutureExtensions on Future {
  Future ignoreError() {
    return this.catchError((_) {
      if (kDebugMode) print("Ignored Error: $_");
    });
  }
}
