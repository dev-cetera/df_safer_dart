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

import 'dart:collection' show Queue;

import '../monads/monad.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

extension SaferIterable<E extends Object> on Iterable<E> {
  Option<Iterable<E>> get noneIfEmpty {
    return Option.from(isEmpty ? null : this);
  }

  Option<E> get firstOrNone {
    final it = iterator;
    if (it.moveNext()) {
      return Some(it.current);
    }
    return const None();
  }

  Option<E> get lastOrNone {
    final it = iterator;
    if (!it.moveNext()) {
      return const None();
    }
    E result;
    do {
      result = it.current;
    } while (it.moveNext());
    return Some(result);
  }

  Option<E> get singleOrNone {
    final it = iterator;
    if (it.moveNext()) {
      final result = it.current;
      if (!it.moveNext()) {
        return Some(result);
      }
    }
    return const None();
  }

  Option<E> firstWhereOrNone(bool Function(E element) test) {
    for (final element in this) {
      if (test(element)) return Some(element);
    }
    return const None();
  }

  Option<E> lastWhereOrNone(bool Function(E element) test) {
    Option<E> result = const None();
    for (final element in this) {
      if (test(element)) {
        result = Some(element);
      }
    }
    return result;
  }

  Option<E> singleWhereOrNone(bool Function(E element) test) {
    Option<E> result = const None();
    for (final element in this) {
      if (test(element)) {
        if (result.isSome()) {
          return const None();
        }
        result = Some(element);
      }
    }
    return result;
  }

  Option<E> reduceOrNone(E Function(E value, E element) combine) {
    final it = iterator;
    if (!it.moveNext()) {
      return const None();
    }
    var value = it.current;
    while (it.moveNext()) {
      value = combine(value, it.current);
    }
    return Some(value);
  }

  Option<E> elementAtOrNone(int index) {
    if (index < 0) return const None();

    var i = 0;
    for (final element in this) {
      if (i == index) {
        return Some(element);
      }
      i++;
    }
    return const None();
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

extension SaferList<E extends Object> on List<E> {
  Option<List<E>> get noneIfEmpty {
    return Option.from(isEmpty ? null : this);
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

extension SaferSet<E extends Object> on Set<E> {
  Option<Set<E>> get noneIfEmpty {
    return Option.from(isEmpty ? null : this);
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

extension SaferQueue<E extends Object> on Queue<E> {
  Option<Queue<E>> get noneIfEmpty {
    return Option.from(isEmpty ? null : this);
  }
}
