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

import 'dart:async' show FutureOr;

import '/df_safer_dart.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// A queue that manages the execution of functions sequentially, allowing for
/// optional throttling.
class SafeSequential {
  //
  //
  //

  final Duration? _buffer;

  /// The current value or future in the queue.
  late var _current = Resolvable<Option>(() => const None());

  /// Indicates whether the queue is empty or processing.
  bool get isEmpty => _isEmpty;
  bool _isEmpty = true;

  //
  //
  //

  /// Creates an [SafeSequential] with an optional [buffer] for throttling
  /// execution.
  SafeSequential({Duration? buffer}) : _buffer = buffer;

  /// Adds multiple [unsafe] functions to the queue for sequential execution.
  /// See [add].
  @pragma('vm:prefer-inline')
  List<Resolvable<Option<T>>> addAll<T extends Object>(
    Iterable<TAddFunction<T>> unsafe, {
    Duration? buffer,
  }) {
    return unsafe
        .map((e) => add<T>(e, buffer: buffer))
        .toList(); // Must be a list, not an Iterable so that the map function is immediately executed.
  }

  /// Adds multiple [functions] to the queue for sequential execution. See
  /// [addSafe].
  @pragma('vm:prefer-inline')
  List<Resolvable<Option<T>>> addAllSafe<T extends Object>(
    Iterable<Resolvable<Option<T>>? Function(Result<Option> previous)> functions, {
    Duration? buffer,
  }) {
    return functions
        .map((e) => addSafe<T>(e, buffer: buffer))
        .toList(); // Must be a list, not an Iterable so that the map function is immediately executed.
  }

  /// Adds an [unsafe] function to the queue that processes the previous value.
  /// Applies an optional [buffer] duration to throttle the execution.
  Resolvable<Option<T>> add<T extends Object>(
    TAddFunction<T> unsafe, {
    Duration? buffer,
  }) {
    Resolvable<Option<T>> fn(Result<Option> previous) => Resolvable(() {
          final temp = unsafe(previous);
          if (temp is Option<T>?) {
            return temp ?? const None();
          }
          return temp.then((e) => e ?? const None());
        });
    return addSafe<T>(fn, buffer: buffer);
  }

  /// Adds a [function] to the queue that processes the previous value.
  /// Applies an optional [buffer] duration to throttle the execution.
  Resolvable<Option<T>> addSafe<T extends Object>(
    Resolvable<Option<T>>? Function(Result<Option> previous) function, {
    Duration? buffer,
  }) {
    final buffer1 = buffer ?? _buffer;
    if (buffer1 == null) {
      return _enqueue<T>(function);
    } else {
      return _enqueue<T>((previous) {
        return Resolvable(() {
          return Future.wait<dynamic>([
            Future.value(function(previous)),
            Future<void>.delayed(buffer1),
          ]).then((e) =>
              (e.first as Resolvable).transf((e) => (e as Option).transf((e) => e as T).unwrap()));
        }).comb();
      });
    }
  }

  /// Eenqueue a [function] without buffering.
  Resolvable<Option<T>> _enqueue<T extends Object>(
    Resolvable<Option<T>>? Function(Result<Option> previous) function,
  ) {
    _isEmpty = false;
    // ignore: invalid_use_of_visible_for_testing_member
    final value = _current.value;
    if (value is Future<Result<Option<Object>>>) {
      _current = Async(() async {
        final temp = function(await value);
        if (temp == null) {
          return _current;
        }
        _isEmpty = true;
        return temp;
      }).comb();
    } else {
      _current = function(value)?.map((e) {
            _isEmpty = true;
            return e;
          }) ??
          _current;
    }
    return _current.transf((e) => e.transf((e) => e as T).unwrap());
  }

  /// Retrieves the last value in the queue without altering the queue.
  Resolvable<None<Object>> get last => add((_) => null).map((_) => const None());
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

typedef TFutureOrOption<T extends Object> = FutureOr<Option<T>?>;
typedef TAddFunction<T extends Object> = TFutureOrOption<T> Function(Result<Option> previous);
