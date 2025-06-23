// ignore_for_file: must_use_unsafe_wrapper_or_error
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

import '../monads/monad/monad.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

extension $SaferIterableExtension<E extends Object> on Iterable<E> {
  /// Returns this [Iterable] wrapped in a [Some] if it's not empty,
  /// otherwise returns [None].
  Option<Iterable<E>> get noneIfEmpty => isEmpty ? const None() : Some(this);

  /// Returns the first element as a [Some], or [None] if the [Iterable] is empty.
  Option<E> get firstOrNone {
    final it = iterator;
    return it.moveNext() ? Some(it.current) : const None();
  }

  /// Returns the last element as a [Some], or [None] if the [Iterable] is empty.
  Option<E> get lastOrNone {
    if (isEmpty) return const None();
    return Some(last);
  }

  /// Returns the single element as a [Some], or [None] if the [Iterable] does
  /// not contain exactly one element.
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

  /// Returns the first element satisfying [test] as a [Some], or [None].
  Option<E> firstWhereOrNone(bool Function(E element) test) {
    for (final element in this) {
      if (test(element)) return Some(element);
    }
    return const None();
  }

  /// Returns the last element satisfying [test] as a [Some], or [None].
  Option<E> lastWhereOrNone(bool Function(E element) test) {
    late E result;
    var found = false;
    for (final element in this) {
      if (test(element)) {
        result = element;
        found = true;
      }
    }
    return found ? Some(result) : const None();
  }

  /// Returns the single element satisfying [test] as a [Some], or [None].
  Option<E> singleWhereOrNone(bool Function(E element) test) {
    late E result;
    var found = false;
    for (final element in this) {
      if (test(element)) {
        if (found) return const None(); // Found more than one
        result = element;
        found = true;
      }
    }
    return found ? Some(result) : const None();
  }

  /// Reduces the collection to a single value by iteratively combining elements.
  /// Returns the result as a [Some], or [None] if the [Iterable] is empty.
  Option<E> reduceOrNone(E Function(E value, E element) combine) {
    if (isEmpty) return const None();
    return Some(reduce(combine));
  }

  /// Returns the element at the given [index] as a [Some], or [None] if the
  /// index is out of bounds.
  Option<E> elementAtOrNone(int index) {
    if (index < 0) return const None();
    var i = 0;
    for (final element in this) {
      if (i == index) return Some(element);
      i++;
    }
    return const None();
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

extension $NonNoneOnIterableExtension<E extends Object> on Iterable<Option<E>> {
  /// Returns a new [Iterable] containing only the values from [Some] elements.
  Iterable<E> get nonNone => where((e) => e.isSome()).map((e) => e.unwrap());

  /// If all elements are [Some], returns a `Some<List<E>>` containing all
  /// unwrapped values. If even one element is [None], returns [None].
  Option<List<E>> get noneNoneAll {
    final buffer = <E>[];
    for (final e in this) {
      if (e.isNone()) return const None();
      buffer.add(e.unwrap());
    }
    return Some(buffer);
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

extension $NonErrOnIterableExtension<E extends Object> on Iterable<Result<E>> {
  /// Returns a new [Iterable] containing only the values from [Ok] elements.
  Iterable<E> get nonErr => where((e) => e.isOk()).map((e) => e.unwrap());

  /// If all elements are [Ok], returns a `Some<List<E>>` containing all
  /// unwrapped values. If even one element is [None], returns [None].
  Option<List<E>> get nonErrAll {
    final buffer = <E>[];
    for (final e in this) {
      if (e.isErr()) return const None();
      buffer.add(e.unwrap());
    }
    return Some(buffer);
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

extension $NoneIfEmptyOnListExtension<E extends Object> on List<E> {
  /// Returns this list wrapped in a [Some] if it's not empty, otherwise
  /// returns [None].
  Option<List<E>> get noneIfEmpty => isEmpty ? const None() : Some(this);
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

extension $NoneIfEmptyOnSetExtension<E extends Object> on Set<E> {
  /// Returns this set wrapped in a [Some] if it's not empty, otherwise returns
  /// [None].
  Option<Set<E>> get noneIfEmpty => isEmpty ? const None() : Some(this);
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

extension $NoneIfEmptyOnQueueExtension<E extends Object> on Queue<E> {
  /// Returns this queue wrapped in a [Some] if it's not empty, otherwise
  /// returns [None].
  Option<Queue<E>> get noneIfEmpty => isEmpty ? const None() : Some(this);
}
