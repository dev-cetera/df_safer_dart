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

import 'dart:collection';

import '../monads/monad.dart';
import 'let_or_none.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

Option<Iterable<T>> letIterableOrNone<T extends Object>(dynamic input) {
  if (input is Option<Iterable<T>>) return input;
  if (input is Iterable<T>) return Some(input);
  final rawValue = unwrapOptionOrNull(input);
  if (rawValue == null) return const None();
  if (rawValue is Iterable<T>) return Some(rawValue);
  final sourceIterable = switch (rawValue) {
    Iterable<dynamic> i => Some(i),
    String s => jsonDecodeOrNone<Iterable<dynamic>>(s),
    _ => const None<Iterable<dynamic>>(),
  };
  return sourceIterable.flatMap((e) => letAsOrNone<Iterable<T>>((e)));
}

Option<List<T>> letListOrNone<T extends Object>(dynamic input) {
  if (input is Option<List<T>>) return input;
  if (input is List<T>) return Some(input);

  return letIterableOrNone<T>(input).flatMap((i) => letAsOrNone<List<T>>(i));
}

Option<Set<T>> letSetOrNone<T extends Object>(dynamic input) {
  if (input is Option<Set<T>>) return input;
  if (input is Set<T>) return Some(input);

  return letIterableOrNone<T>(input).flatMap((i) => letAsOrNone<Set<T>>(i));
}

Option<Queue<T>> letQueueOrNone<T extends Object>(dynamic input) {
  if (input is Option<Queue<T>>) return input;
  if (input is Queue<T>) return Some(input);

  return letIterableOrNone<T>(input).flatMap((i) => letAsOrNone<Queue<T>>(i));
}
