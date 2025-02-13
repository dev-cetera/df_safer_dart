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

import 'merge_resolvable.dart';
import 'result_option.dart';
import 'resolvable_option.dart';
import 'monad.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// A queue that manages the execution of functions sequentially, allowing for
/// optional throttling.
class SafeSequential {
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

  /// Creates an [SafeSequential] with an optional [buffer] for throttling
  /// execution.
  SafeSequential({Duration? buffer}) : _buffer = buffer;

  /// Adds multiple [unsafe] functions to the queue for sequential execution.
  /// See [add].
  @pragma('vm:prefer-inline')
  Iterable<ResolvableOption<T>> addAll<T extends Object>({
    required Iterable<TAddFunction<T>> unsafe,
    Duration? buffer,
  }) {
    return unsafe.map((e) => add<T>(unsafe: e, buffer: buffer));
  }

  /// Adds multiple [functions] to the queue for sequential execution. See
  /// [addSafe].
  @pragma('vm:prefer-inline')
  Iterable<ResolvableOption<T>> addAllSafe<T extends Object>(
    Iterable<ResolvableOption<T>? Function(ResultOption previous)> functions, {
    Duration? buffer,
  }) {
    return functions.map((e) => addSafe<T>(e, buffer: buffer));
  }

  /// Adds an [unsafe] function to the queue that processes the previous value.
  /// Applies an optional [buffer] duration to throttle the execution.
  ResolvableOption<T> add<T extends Object>({
    required TAddFunction<T> unsafe,
    Duration? buffer,
  }) {
    ResolvableOption<T> fn(ResultOption previous) => Resolvable.unsafe(() {
      final temp = unsafe(previous);
      if (temp is Future<Option<T>?>) {
        return temp.then((e) => e ?? const None());
      } else {
        return temp ?? const None();
      }
    });
    return addSafe<T>(fn, buffer: buffer);
  }

  /// Adds a [function] to the queue that processes the previous value.
  /// Applies an optional [buffer] duration to throttle the execution.
  ResolvableOption<T> addSafe<T extends Object>(
    ResolvableOption<T>? Function(ResultOption previous) function, {
    Duration? buffer,
  }) {
    final buffer1 = buffer ?? _buffer;
    if (buffer1 == null) {
      return _enqueue<T>(function);
    } else {
      return _enqueue<T>((previous) {
        return Resolvable.unsafe(() {
          return Future.wait<dynamic>([
            Future.value(function(previous)),
            Future<void>.delayed(buffer1),
          ]).then((e) => e.first as ResolvableOption<T>);
        }).merge();
      });
    }
  }

  /// Eenqueue a [function] without buffering.
  ResolvableOption<T> _enqueue<T extends Object>(
    ResolvableOption<T>? Function(ResultOption previous) function,
  ) {
    _isEmpty = false;
    // ignore: invalid_use_of_visible_for_testing_member
    final value = _current.value;
    if (value is Future<Result<Option<Object>>>) {
      _current =
          Async.unsafe(() async {
            final temp = function(await value);
            if (temp == null) {
              return _current;
            }
            _isEmpty = true;
            return temp;
          }).merge();
    } else {
      _current =
          function(value)?.map((e) {
            _isEmpty = true;
            return e;
          }) ??
          _current;
    }
    return _current as ResolvableOption<T>;
  }

  /// Retrieves the last value in the queue without altering the queue.
  Resolvable<void> get last => add(unsafe: (_) => null);
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

typedef TFutureOrOption<T extends Object> = FutureOr<Option<T>?>;
typedef TAddFunction<T extends Object> =
    TFutureOrOption<T> Function(ResultOption previous);
