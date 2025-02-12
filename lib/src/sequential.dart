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

import 'monad.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// A queue that manages the execution of functions sequentially, allowing for
/// optional throttling.
class Sequential {
  //
  //
  //

  final Duration? _buffer;

  /// The current value or future in the queue.
  late ResolvableOption _current = ResolvableOption.unsafe(() => const None());

  /// Indicates whether the queue is empty or processing.
  bool get isEmpty => _isEmpty;
  bool _isEmpty = true;

  //
  //
  //

  /// Creates an [Sequential] with an optional [buffer] for throttling
  /// execution.
  Sequential({Duration? buffer}) : _buffer = buffer;

  /// Adds a [function] to the queue that processes the previous value.
  /// Applies an optional [buffer] duration to throttle the execution.
  Resolvable<T> add<T extends Object>(
    FutureOr<Option> Function(Option previous) function, {
    Duration? buffer,
  }) {
    final buffer1 = buffer ?? _buffer;
    if (buffer1 == null) {
      return _enqueue<T>(function);
    } else {
      return _enqueue<T>((previous) {
        return Future.wait<dynamic>([
          Future.value(function(previous)),
          Future<void>.delayed(buffer1),
        ]).then((e) => e.first as Some<T>);
      });
    }
  }

  /// Adds multiple [functions] to the queue for sequential execution. See
  /// [add].
  List<Resolvable<T>> addAll<T extends Object>(
    Iterable<FutureOr<Option> Function(Option previous)> functions, {
    Duration? buffer,
  }) {
    final results = <Resolvable<T>>[];
    for (final function in functions) {
      results.add(add(function, buffer: buffer));
    }
    return results;
  }

  /// Eenqueue a [function] without buffering.
  Resolvable<T> _enqueue<T extends Object>(
    FutureOr<Option> Function(Option previous) function,
  ) {
    _isEmpty = false;
    _current = _current.mapFutureOr(function).map((e) {
      _isEmpty = true;
      return e;
    });
    return _current.cast();
  }

  /// Retrieves the last value in the queue without altering the queue.
  Resolvable<dynamic> get last => add<Object>((e) => e);
}
