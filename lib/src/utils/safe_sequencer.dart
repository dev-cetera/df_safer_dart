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

import 'package:df_safer_dart_annotations/df_safer_dart_annotations.dart' show noFuturesAllowed;

import '/df_safer_dart.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// A queue that manages the execution of functions sequentially, allowing for
/// optional throttling.
class SafeSequencer {
  //
  //
  //

  final _TOnPrevErr? _onPrevErr;
  final bool _eagerError;
  final Duration? _buffer;

  /// The current value or future in the queue.
  Resolvable<Option> get current => _current;
  late var _current = Resolvable<Option>(() => const None());

  /// Indicates whether the queue is empty or processing.
  bool get isEmpty => _isEmpty;
  bool _isEmpty = true;

  //
  //
  //

  SafeSequencer({
    _TOnPrevErr? onPrevErr,
    bool eagerError = false,
    Duration? buffer,
  })  : _onPrevErr = onPrevErr,
        _eagerError = eagerError,
        _buffer = buffer;

  //
  //
  //

  /// Retrieves the last value in the queue.
  @pragma('vm:prefer-inline')
  Resolvable<Object> get last => addSafe((e) => Sync.value(e));

  /// Adds a [handler] to the queue that processes the previous value.
  ///
  /// The [buffer] duration can be used to throttle the execution.
  FutureOr<void> add(
    FutureOr<void> Function() handler, {
    Duration? buffer,
  }) {
    final result = addSafe(
      (_) {
        final value = handler();
        if (value is FutureOr<Object>) {
          return value.toResolvable().map((e) => const None());
        }
        return const Sync.unsafe(Ok(None()));
      },
      buffer: buffer,
    ).value;
    if (result is Future<Result<Option<Object>>>) {
      return result.then<void>((e) {
        if (e.isErr()) {
          throw e;
        }
      });
    } else {
      if (result.isErr()) {
        throw result;
      }
    }
  }

  /// Adds a [handler] to the queue that processes the previous value.
  ///
  /// The [buffer] duration can be used to throttle the execution.
  Resolvable<Option<T>> addSafe<T extends Object>(
    @noFuturesAllowed Resolvable<Option<T>>? Function(Result<Option> previous) handler, {
    Duration? buffer,
  }) {
    final buffer1 = buffer ?? _buffer;
    if (buffer1 == null) {
      return _enqueue<T>(handler);
    } else {
      return _enqueue<T>((previous) {
        return Resolvable(() async {
          final a = await Future.wait<dynamic>([
            // ignore: must_await_all_futures
            Future<Resolvable<Option<T>>?>.value(handler(previous)),
            // ignore: must_await_all_futures
            Future<void>.delayed(buffer1),
          ]);
          return (a.first as Resolvable<Option<T>>?) ?? Resolvable(() => None<T>());
        }).flatten();
      });
    }
  }

  /// Enqueue a [function] without buffering.
  Resolvable<Option<T>> _enqueue<T extends Object>(
    Resolvable<Option<T>>? Function(Result<Option> previous) function,
  ) {
    _isEmpty = false;
    final value = _current.value;
    if (value is Future<Result<Option<Object>>>) {
      _current = Async(() async {
        final awaitedValue = await value;
        if (awaitedValue.isErr()) {
          _onPrevErr?.call(awaitedValue.err().unwrap());
          if (_eagerError) {
            return _current;
          }
        }
        final temp = function(awaitedValue);
        if (temp == null) {
          return _current;
        }
        _isEmpty = true;
        return temp;
      }).flatten();
    } else {
      if (value.isErr()) {
        _onPrevErr?.call(value.err().unwrap());
        if (_eagerError) {
          return _transfCurrent<T>(_current);
        }
      }
      _current = function(value)?.map((e) {
            _isEmpty = true;
            return e;
          }) ??
          _current;
    }
    return _transfCurrent<T>(_current);
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

@pragma('vm:prefer-inline')
Resolvable<Option<T>> _transfCurrent<T extends Object>(
  Resolvable<Option<Object>> input,
) {
  return input.transf((e) => e.transf((e) => e as T).unwrap());
}

typedef _TOnPrevErr<T extends Object> = void Function(Err<T> err);
