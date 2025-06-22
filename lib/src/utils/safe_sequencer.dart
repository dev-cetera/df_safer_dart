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

import 'dart:async' show FutureOr;

import 'package:df_safer_dart_annotations/df_safer_dart_annotations.dart'
    show noFuturesAllowed;

import '/df_safer_dart.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// A queue that manages the execution of functions sequentially, allowing for
/// optional throttling.
class SafeSequencer<T extends Object> {
  //
  //
  //

  final _TOnPrevErr<T>? _onPrevErr;
  final bool _eagerError;
  final Duration? _buffer;

  /// The current value or future in the queue.
  Resolvable<Option<T>> get current => _current;
  late var _current = Resolvable<Option<T>>(() => const None());

  /// Indicates whether the queue is empty or processing.
  bool get isEmpty => _isEmpty;
  bool _isEmpty = true;

  //
  //
  //

  SafeSequencer({
    _TOnPrevErr<T>? onPrevErr,
    bool eagerError = false,
    Duration? buffer,
  }) : _onPrevErr = onPrevErr,
       _eagerError = eagerError,
       _buffer = buffer;

  //
  //
  //

  /// Retrieves the last value in the queue.
  @pragma('vm:prefer-inline')
  Resolvable<Option<T>> get last => addSafe((e) => Sync.unsafe(e));

  /// Adds a [handler] to the queue that processes the previous value.
  ///
  /// The [buffer] duration can be used to throttle the execution.
  FutureOr<void> add(
    FutureOr<void> Function() handler, {
    Duration? buffer,
    _TOnPrevErr<T>? onPrevErr,
    bool? eagerError,
  }) {
    final result = addSafe(
      (_) {
        final value = handler();
        switch (value) {
          case Future():
            return Async(() async {
              // TODO: false positive linter!
              // ignore: no_futures_allowed
              await value;
              return const None();
            });
          default:
            return syncNone();
        }
      },
      buffer: buffer,
      onPrevErr: onPrevErr,
      eagerError: eagerError,
    ).value;
    if (result is Future<Result<Option<T>>>) {
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
  Resolvable<Option<T>> addSafe(
    @noFuturesAllowed
    Resolvable<Option<T>>? Function(Result<Option<T>> previous) handler, {
    Duration? buffer,
    _TOnPrevErr<T>? onPrevErr,
    bool? eagerError,
  }) {
    final buffer1 = buffer ?? _buffer;
    if (buffer1 == null) {
      return _enqueue(handler, onPrevErr, eagerError);
    } else {
      return _enqueue(
        (previous) {
          return Resolvable(() async {
            final a = await Future.wait<dynamic>([
              // TODO: false positive linter!
              // ignore: must_await_all_futures
              Future<Resolvable<Option<T>>?>.value(handler(previous)),
              // TODO: false positive linter!
              // ignore: must_await_all_futures
              Future<void>.delayed(buffer1),
            ]);
            return (a.first as Resolvable<Option<T>>?) ??
                Resolvable(() => None<T>());
          }).flatten();
        },
        onPrevErr,
        eagerError,
      );
    }
  }

  /// Enqueue a [handler] without buffering.
  Resolvable<Option<T>> _enqueue(
    Resolvable<Option<T>>? Function(Result<Option<T>> previous) handler,
    _TOnPrevErr<T>? onPrevErr,
    bool? eagerError,
  ) {
    final eagerError1 = eagerError ?? _eagerError;
    _isEmpty = false;
    final value = _current.value;
    if (value is Future<Result<Option<T>>>) {
      _current = Async(() async {
        final awaitedValue = await value;
        if (awaitedValue.isErr()) {
          final err = awaitedValue.err().unwrap().transfErr<T>();
          _onPrevErr?.call(err);
          onPrevErr?.call(err);
          if (eagerError1) {
            return _current;
          }
        }
        final temp = handler(awaitedValue);
        if (temp == null) {
          return _current;
        }
        _isEmpty = true;
        return temp;
      }).flatten();
    } else {
      if (value.isErr()) {
        final err = value.err().unwrap().transfErr<T>();
        _onPrevErr?.call(err);
        onPrevErr?.call(err);
        if (eagerError1) {
          return _transfCurrent<T>(_current);
        }
      }
      _current = Sync(() {
        return handler(value)?.map((e) {
              _isEmpty = true;
              return e;
            }) ??
            _current;
      }).flatten();
    }
    return _transfCurrent<T>(_current);
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

@pragma('vm:prefer-inline')
Resolvable<Option<T>> _transfCurrent<T extends Object>(
  Resolvable<Option<Object>> input,
) {
  return input.transf((e) => e.transf<T>().unwrap());
}

typedef _TOnPrevErr<T extends Object> = void Function(Err<T> err);
