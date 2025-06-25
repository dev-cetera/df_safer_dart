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

// ignore_for_file: must_use_unsafe_wrapper_or_error

import '/_common.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
//
// General Iterable Extensions
//
// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

extension IterableExt<T extends Object> on Iterable<T> {
  /// Returns this [Iterable] wrapped in a [Some] if it's not empty,
  /// otherwise returns [None].
  Option<Iterable<T>> get noneIfEmpty => isEmpty ? const None() : Some(this);

  /// Returns the first element as a [Some], or [None] if the [Iterable] is empty.
  Option<T> get firstOrNone {
    final it = iterator;
    return it.moveNext() ? Some(it.current) : const None();
  }

  /// Returns the last element as a [Some], or [None] if the [Iterable] is empty.
  Option<T> get lastOrNone => isEmpty ? const None() : Some(last);

  /// Returns the single element as a [Some], or [None] if the [Iterable] does
  /// not contain exactly one element.
  Option<T> get singleOrNone {
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
  Option<T> firstWhereOrNone(bool Function(T element) test) {
    for (final element in this) {
      if (test(element)) return Some(element);
    }
    return const None();
  }

  /// Returns the last element satisfying [test] as a [Some], or [None].
  Option<T> lastWhereOrNone(bool Function(T element) test) {
    late T result;
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
  Option<T> singleWhereOrNone(bool Function(T element) test) {
    late T result;
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
  Option<T> reduceOrNone(T Function(T value, T element) combine) {
    if (isEmpty) return const None();
    return Some(reduce(combine));
  }

  /// Returns the element at the given [index] as a [Some], or [None] if the
  /// index is out of bounds.
  Option<T> elementAtOrNone(int index) {
    if (index < 0) return const None();
    var i = 0;
    for (final element in this) {
      if (i == index) return Some(element);
      i++;
    }
    return const None();
  }
}

extension NoneIfEmptyOnListExt<T extends Object> on List<T> {
  /// Returns this list wrapped in a [Some] if it's not empty, otherwise
  /// returns [None].
  Option<List<T>> get noneIfEmpty => isEmpty ? const None() : Some(this);
}

extension NoneIfEmptyOnSetExt<T extends Object> on Set<T> {
  /// Returns this set wrapped in a [Some] if it's not empty, otherwise returns
  /// [None].
  Option<Set<T>> get noneIfEmpty => isEmpty ? const None() : Some(this);
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
//
// Monadic Iterable Extensions
//
// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

extension IterableOptionExt<T extends Object> on Iterable<Option<T>> {
  /// Filters for [Some] elements, returning an iterable of the [Some] instances.
  Iterable<Some<T>> whereSome() => where((e) => e.isSome()).map((e) => e.some().unwrap());

  /// Filters for [None] elements, returning an iterable of the [None] instances.
  Iterable<None<T>> whereNone() => where((e) => e.isNone()).map((e) => e.none().unwrap());

  /// Returns a new [Iterable] containing only the values from [Some] elements.
  Iterable<T> get values => where((e) => e.isSome()).map((e) => e.unwrap());

  /// Turns an `Iterable<Option<T>>` into an `Option<List<T>>`.
  /// If all elements are [Some], it returns a `Some<List<T>>`. If any element
  /// is a [None], it returns [None].
  Option<List<T>> sequenceList() {
    final buffer = <T>[];
    for (final e in this) {
      if (e.isNone()) return const None();
      buffer.add(e.unwrap());
    }
    return Some(buffer);
  }

  /// Turns an `Iterable<Option<T>>` into an `Option<Set<T>>`.
  /// If all elements are [Some], it returns a `Some<Set<T>>`. If any element
  /// is a [None], it returns [None].
  Option<Set<T>> sequenceSet() {
    final buffer = <T>{};
    for (final e in this) {
      if (e.isNone()) return const None();
      buffer.add(e.unwrap());
    }
    return Some(buffer);
  }

  /// Partitions the iterable into `someParts` and `noneParts` in a single pass.
  OptionPartition<T> partition() {
    final someParts = <Some<T>>[];
    final noneParts = <None<T>>[];
    for (final option in this) {
      switch (option) {
        case Some():
          someParts.add(option);
        case None():
          noneParts.add(option);
      }
    }
    return (someParts: someParts, noneParts: noneParts);
  }
}

extension IterableFutureOptionExt<T extends Object> on Iterable<Future<Option<T>>> {
  /// Awaits all futures and then filters for [Some] elements.
  Future<Iterable<Some<T>>> whereSome() => Future.wait(this).then((e) => e.whereSome());

  /// Awaits all futures and then filters for [None] elements.
  Future<Iterable<None<T>>> whereNone() => Future.wait(this).then((e) => e.whereNone());
}

extension IterableSomeExt<T extends Object> on Iterable<Some<T>> {
  /// Extracts the value from every [Some] element in the iterable.
  Iterable<T> unwrapAll() => map((e) => e.value);
}

extension FutureIterableSomeExt<T extends Object> on Future<Iterable<Some<T>>> {
  /// Awaits and then extracts the value from every [Some] element.
  Future<Iterable<T>> unwrapAll() => then((e) => e.unwrapAll());
}

extension IterableResultExt<T extends Object> on Iterable<Result<T>> {
  /// Filters for [Ok] elements, returning an iterable of the [Ok] instances.
  Iterable<Ok<T>> whereOk() => where((e) => e.isOk()).map((e) => e.ok().unwrap());

  /// Filters for [Err] elements, returning an iterable of the [Err] instances.
  Iterable<Err<T>> whereErr() => where((e) => e.isErr()).map((e) => e.err().unwrap());

  /// Returns a new [Iterable] containing only the values from [Ok] elements.
  Iterable<T> get values => where((e) => e.isOk()).map((e) => e.unwrap());

  /// Turns an `Iterable<Result<T>>` into an `Option<List<T>>`.
  /// If all elements are [Ok], it returns a `Some<List<T>>`. If any element
  /// is an [Err], it returns [None], discarding the specific error.
  Option<List<T>> sequenceList() {
    final buffer = <T>[];
    for (final e in this) {
      if (e.isErr()) {
        return const None();
      }
      buffer.add(e.unwrap());
    }
    return Some(buffer);
  }

  /// Turns an `Iterable<Result<T>>` into an `Option<Set<T>>`.
  /// If all elements are [Ok], it returns a `Some<Set<T>>`. If any element
  /// is an [Err], it returns [None], discarding the specific error.
  Option<Set<T>> sequenceSet() {
    final buffer = <T>{};
    for (final e in this) {
      if (e.isErr()) {
        return const None();
      }
      buffer.add(e.unwrap());
    }
    return Some(buffer);
  }

  /// Partitions the iterable into `okParts` and `errParts` in a single pass.
  ResultPartition<T> partition() {
    final okParts = <Ok<T>>[];
    final errParts = <Err<T>>[];
    for (final result in this) {
      switch (result) {
        case Ok():
          okParts.add(result);
        case Err():
          errParts.add(result);
      }
    }
    return (okParts: okParts, errParts: errParts);
  }
}

extension IterableFutureResultExt<T extends Object> on Iterable<Future<Result<T>>> {
  /// Awaits all futures and then filters for [Ok] elements.
  Future<Iterable<Ok<T>>> whereOk() => Future.wait(this).then((e) => e.whereOk());

  /// Awaits all futures and then filters for [Err] elements.
  Future<Iterable<Err<T>>> whereErr() => Future.wait(this).then((e) => e.whereErr());
}

extension IterableOkExt<T extends Object> on Iterable<Ok<T>> {
  /// Extracts the value from every [Ok] element in the iterable.
  Iterable<T> unwrapAll() => map((e) => e.value);
}

extension FutureIterableOkExt<T extends Object> on Future<Iterable<Ok<T>>> {
  /// Awaits and then extracts the value from every [Ok] element.
  Future<Iterable<T>> unwrapAll() => then((e) => e.unwrapAll());
}

extension IterableResolvableExt<T extends Object> on Iterable<Resolvable<T>> {
  /// Filters for [Sync] elements, returning an iterable of the [Sync] instances.
  Iterable<Sync<T>> whereSync() => where((e) => e.isSync()).map((e) => e.sync().unwrap());

  /// Filters for [Async] elements, returning an iterable of the [Async] instances.
  Iterable<Async<T>> whereAsync() => where((e) => e.isAsync()).map((e) => e.async().unwrap());

  /// Converts every [Resolvable] in the iterable to an [Async].
  Iterable<Async<T>> mapToAsync() => map((e) => e.toAsync());

  /// Partitions the iterable into `syncParts` and `asyncParts` in a single pass.
  ResolvablePartition<T> partition() {
    final syncParts = <Sync<T>>[];
    final asyncParts = <Async<T>>[];
    for (final resolvable in this) {
      if (resolvable.isSync()) {
        syncParts.add(resolvable as Sync<T>);
      } else {
        asyncParts.add(resolvable as Async<T>);
      }
    }
    return (syncParts: syncParts, asyncParts: asyncParts);
  }
}

extension IterableSyncExt<T extends Object> on Iterable<Sync<T>> {
  /// Extracts the inner [Result] from each [Sync] element.
  Iterable<Result<T>> mapToResults() => map((e) => e.value);

  Sync<List<T>> resolveInSequence() {
    final values = <T>[];
    final series = TaskSequencer<T>();
    for (final e in this) {
      series.then((_) {
        return e.map((e) {
          values.add(e);
          return e;
        }).wrapValueInSome();
      }).end();
    }
    return series.completion.then((_) => values).sync().unwrap();
  }
}

extension IterableAsyncExt<T extends Object> on Iterable<Async<T>> {
  /// Extracts the inner `Future<Result>` from each [Async] element.
  Iterable<Future<Result<T>>> mapToResults() => map((e) => e.value);
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
//
// Partition Typedefs
//
// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// The result of partitioning an `Iterable<Option<T>>`.
typedef OptionPartition<T extends Object> = ({
  Iterable<Some<T>> someParts,
  Iterable<None<T>> noneParts
});

/// The result of partitioning an `Iterable<Result<T>>`.
typedef ResultPartition<T extends Object> = ({Iterable<Ok<T>> okParts, Iterable<Err<T>> errParts});

/// The result of partitioning an `Iterable<Resolvable<T>>`.
typedef ResolvablePartition<T extends Object> = ({
  Iterable<Sync<T>> syncParts,
  Iterable<Async<T>> asyncParts
});
