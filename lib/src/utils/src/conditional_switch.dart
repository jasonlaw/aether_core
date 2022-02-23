import 'package:flutter/material.dart';

// https://github.com/crizant/flutter_conditional_rendering
/// Conditional rendering switch class
class ConditionalSwitch {
  ConditionalSwitch._();

  /// A function which returns a single `Widget`
  ///
  /// - [valueBuilder] is a function which returns a value.
  /// - [caseBuilders] is a `Map` of value to `Widget` builders,
  /// when one of the keys matches the value returns by [valueBuilder],
  /// the corresponding `Widget` builder will be used.
  /// - [fallbackBuilder] is a function which returns a `Widget`,
  ///  it is used when none of the keys in [caseBuilders]matches
  /// the value returns by [valueBuilder].
  static Widget single<T>({
    required T Function() valueBuilder,
    required Map<T, Widget Function()> caseBuilders,
    required Widget Function() fallbackBuilder,
  }) {
    final value = valueBuilder();
    if (caseBuilders[value] != null) {
      return caseBuilders[value]!();
    } else {
      return fallbackBuilder();
    }
  }

  /// A function which returns a `List<Widget>`
  ///
  /// - [valueBuilder] is a function which returns a value.
  /// - [caseBuilders] is a `Map` of value to `List<Widget>` builders,
  /// when one of the keys matches the value returns by [valueBuilder],
  /// the corresponding `List<Widget>` builder will be used.
  /// - [fallbackBuilder] is a function which returns a `List<Widget>`,
  ///  it is used when none of the keys in [caseBuilders] matches
  /// the value returns by [valueBuilder].
  static List<Widget> list<T>({
    required T Function() valueBuilder,
    required Map<T, List<Widget> Function()> caseBuilders,
    required List<Widget> Function() fallbackBuilder,
  }) {
    final value = valueBuilder();
    if (caseBuilders[value] != null) {
      return caseBuilders[value]!();
    } else {
      return fallbackBuilder();
    }
  }
}
