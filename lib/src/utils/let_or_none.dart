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

Option<T> letAsOrNone<T extends Object>(dynamic input) {
  switch (input) {
    case T value:
      return Some(value);
    case Some(value: final innerValue):
      // Recursively unwrap and check the inner value.
      return letAsOrNone<T>(innerValue);
    default:
      return const None();
  }
}

Option<num> letNumOrNone(dynamic input) {
  switch (input) {
    case Option<num> o:
      return o;
    case num n:
      return Some(n);
    case String s:
      return Option.from(num.tryParse(s.trim()));
    case bool b:
      return Some(b ? 1 : 0);
    case Some(value: final v):
      // Handle nested Options like Some<String>
      return letNumOrNone(v);
    default:
      return const None();
  }
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
  switch (input) {
    case Option<bool> o:
      return o;
    case bool b:
      return Some(b);
    case num n:
      return Some(n != 0);
    case String s:
      return Option.from(bool.tryParse(s, caseSensitive: false));
    case Some(value: final v):
      return letBoolOrNone(v);
    default:
      return const None();
  }
}

Option<Uri> letUriOrNone(dynamic input) {
  switch (input) {
    case Option<Uri> o:
      return o;
    case Uri u:
      return Some(u);
    case String s:
      return Option.from(Uri.tryParse(s.trim()));
    case Some(value: final v):
      return letUriOrNone(v);
    default:
      return const None();
  }
}

Option<DateTime> letDateTimeOrNone(dynamic input) {
  switch (input) {
    case Option<DateTime> o:
      return o;
    case DateTime d:
      return Some(d);
    case String s:
      return Option.from(DateTime.tryParse(s.trim()));
    case Some(value: final v):
      return letDateTimeOrNone(v);
    default:
      return const None();
  }
}
