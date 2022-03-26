import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class Field<T> {
  T _value;

  Field(this._value);

  Rx<Field<T>> get rx => _rx ??= Rx<Field<T>>(this);
  Rx<Field<T>>? _rx;
  T? get value => _value;

  T call([T? value]) {
    if (value != null) {
      _value = value;
      _rx?.trigger(this);
    }

    return _value;
  }
}

void main() {
  test('ever', () async {
    final count = Field<int>(0);
    var result = -1;
    ever<Field<int>>(count.rx, (value) {
      result = value();
    });
    count(count() + 1);
    await Future.delayed(Duration.zero);
    expect(1, result);
    count(count() + 1);
    await Future.delayed(Duration.zero);
    expect(2, result);
    count(count() + 1);
    await Future.delayed(Duration.zero);
    expect(3, result);
  });
}
