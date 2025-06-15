//.title
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//
// Dart/Flutter (DF) Packages by dev-cetera.com & contributors. The use of this
// source code is governed by an MIT-style license described in the LICENSE
// file located in this project's root directory.
//
// See: https://opensource.org/license/mit
//
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//.title~

import 'dart:convert' show jsonDecode;

import '../monads/monad.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

dynamic unwrapOptionOrNull(dynamic input) {
  return switch (input) {
    Some(value: final v) => v,
    None() => null,
    _ => input,
  };
}

Option<T> jsonDecodeOrNone<T extends Object>(String input) {
  try {
    final decoded = jsonDecode(input);
    return decoded is T ? Some(decoded) : const None();
  } catch (e) {
    assert(false, e);
    return const None();
  }
}

@pragma('vm:prefer-inline')
Option<T> letAsOrNone<T extends Object>(dynamic input) {
  if (input is T) return Some(input);
  final rawValue = unwrapOptionOrNull(input);
  return rawValue is T ? Some(rawValue) : const None();
}

Option<num> letNumOrNone(dynamic input) {
  if (input is Option<num>) return input;
  if (input is num) return Some(input);

  final rawValue = unwrapOptionOrNull(input);
  if (rawValue is num) return Some(rawValue);
  if (rawValue is String) {
    return Option.fromNullable(num.tryParse(rawValue.trim()));
  }
  if (rawValue is bool) return Some(rawValue ? 1 : 0);

  return const None();
}

@pragma('vm:prefer-inline')
Option<int> letIntOrNone(dynamic input) {
  if (input is Option<int>) return input;
  return letNumOrNone(input).map((n) => n.toInt());
}

@pragma('vm:prefer-inline')
Option<double> letDoubleOrNone(dynamic input) {
  if (input is Option<double>) return input;
  return letNumOrNone(input).map((n) => n.toDouble());
}

Option<bool> letBoolOrNone(dynamic input) {
  if (input is Option<bool>) return input;
  if (input is bool) return Some(input);

  final rawValue = unwrapOptionOrNull(input);
  if (rawValue is bool) return Some(rawValue);
  if (rawValue is num) return Some(rawValue != 0);
  if (rawValue is String) {
    return Option.fromNullable(bool.tryParse(rawValue, caseSensitive: false));
  }

  return const None();
}

Option<Uri> letUriOrNone(dynamic input) {
  if (input is Option<Uri>) return input;
  if (input is Uri) return Some(input);

  final rawValue = unwrapOptionOrNull(input);
  if (rawValue is Uri) return Some(rawValue);
  if (rawValue is String) {
    return Option.fromNullable(Uri.tryParse(rawValue.trim()));
  }

  return const None();
}

Option<DateTime> letDateTimeOrNone(dynamic input) {
  if (input is Option<DateTime>) return input;
  if (input is DateTime) return Some(input);

  final rawValue = unwrapOptionOrNull(input);
  if (rawValue is DateTime) return Some(rawValue);
  if (rawValue is String) {
    return Option.fromNullable(DateTime.tryParse(rawValue.trim()));
  }
  return const None();
}
