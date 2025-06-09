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

import 'dart:convert';
import 'let_or_none.dart';

import '../monads/monad.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

Option<T> _tryJsonDecode<T extends Object>(String s) {
  try {
    final decoded = jsonDecode(s);
    return decoded is T ? Some(decoded) : const None();
  } catch (_) {
    return const None();
  }
}

Option<Map<K, V>> letMapOrNone<K extends Object, V extends Object>(
  dynamic input,
) {
  if (input is Option<Map<K, V>>) return input;
  if (input is Map<K, V>) return Some(input);
  final rawValue = unwrapOptionOrNull(input);
  if (rawValue == null) return const None();
  if (rawValue is Map<K, V>) return Some(rawValue);
  final sourceMap = switch (rawValue) {
    Map<dynamic, dynamic> m => Some(m),
    String s => _tryJsonDecode<Map<dynamic, dynamic>>(s),
    _ => const None<Map<dynamic, dynamic>>(),
  };
  return sourceMap.flatMap((map) => letAsOrNone<Map<K, V>>(map));
}
