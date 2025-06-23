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

import 'dart:async' show Completer, FutureOr;

import 'package:df_safer_dart_annotations/df_safer_dart_annotations.dart'
    show noFuturesAllowed;

import '../monads/monad/monad.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

class SafeCompleter<T extends Object> {
  //
  //
  //

  final _completer = Completer<T>();
  Option<FutureOr<T>> _value = const None();
  bool _isResolving = false;

  //
  //
  //

  /// Completes the operation with the provided [resolvable].
  Resolvable<T> resolve(Resolvable<T> resolvable) {
    if (_isResolving) {
      return Sync.unsafe(Err('SafeCompleter<$T> is already resolving!'));
    }
    _isResolving = true;
    if (isCompleted) {
      return Sync.unsafe(Err('SafeCompleter<$T> is already completed!'));
    }

    return resolvable.resultMap((e) {
      // Use a switch on the Result 'e' for exhaustive, safe handling.
      switch (e) {
        case Ok(value: final value):
          _value = Some(value);
          _completer.complete(value);
          _isResolving = false;
          return e;
        case Err():
          _completer.completeError(e);
          _isResolving = false;
          return e;
      }
    });
  }

  /// Completes the operation with the provided [value].
  @pragma('vm:prefer-inline')
  Resolvable<T> complete(FutureOr<T> value) => resolve(Resolvable(() => value));

  /// Returns a [Resolvable] that will complete when this [SafeCompleter] is
  /// completed.
  @pragma('vm:prefer-inline')
  Resolvable<T> resolvable() {
    return Resolvable(() {
      // Use a switch on the Option '_value' for clear and safe state checking.
      switch (_value) {
        case Some(value: final okValue):
          return okValue;
        case None():
          return _completer.future;
      }
    });
  }

  /// Checks if the value has been set or if the [SafeCompleter] is completed.
  @pragma('vm:prefer-inline')
  bool get isCompleted => _completer.isCompleted || _value.isSome();

  /// Transforms the type of the value managed by this [SafeCompleter].
  SafeCompleter<R> transf<R extends Object>([
    @noFuturesAllowed R Function(T e)? noFuturesAllowed,
  ]) {
    final completer = SafeCompleter<R>();
    resolvable().map((e) {
      try {
        final result = noFuturesAllowed != null
            ? noFuturesAllowed(e)
            : (e as R);
        completer.resolve(Sync<R>.unsafe(Ok(result))).end();
      } catch (e) {
        completer
            .resolve(Sync.unsafe(Err('Failed to transform type $T to $R.')))
            .end();
      }
      return e;
    }).end();
    return completer;
  }
}
