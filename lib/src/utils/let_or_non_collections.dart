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
  switch (input) {
    case Option<Iterable<T>> o:
      return o;
    case Iterable<T> i:
      return Some(i);
    case String s:
      final decodedIterable = jsonDecodeOrNone<Iterable<dynamic>>(s);
      return decodedIterable.flatMap((iter) => letAsOrNone<Iterable<T>>(iter));
    case Iterable<dynamic> i:
      return letAsOrNone<Iterable<T>>(i);
    case Some(value: final v):
      return letIterableOrNone<T>(v);
    default:
      return const None();
  }
}

Option<List<T>> letListOrNone<T extends Object>(dynamic input) {
  return letIterableOrNone<T>(input).map((e) => List.from(e));
}

Option<Set<T>> letSetOrNone<T extends Object>(dynamic input) {
  return letIterableOrNone<T>(input).map((e) => Set.from(e));
}

Option<Queue<T>> letQueueOrNone<T extends Object>(dynamic input) {
  return letIterableOrNone<T>(input).map((e) => Queue.from(e));
}
