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

import '../monads/monad.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

@Deprecated('Renamed to SafeCompleter.')
typedef SafeFinisher<T extends Object> = SafeCompleter<T>;

@Deprecated('Renamed to SafeCompleter.')
typedef Finisher<T extends Object> = SafeCompleter<T>;

/// A utility class for managing completion of both synchronous and asynchronous
/// values.
///
/// [SafeCompleter] is similar to a [Completer], but it handles both synchronous
/// and asynchronous results seamlessly.
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
      return Sync.value(Err('SafeFinisher<$T> is already resolving!'));
    }
    _isResolving = true;
    if (isCompleted) {
      return Sync.value(Err('SafeFinisher<$T> is already completed!'));
    }

    return resolvable.resultMap((e) {
      if (e.isOk()) {
        final a = e.unwrap();
        _value = Some(a);
        _completer.complete(a);
        return e;
      } else {
        final err = e.err().unwrap();
        _completer.completeError(err);
        return err;
      }
    });
  }

  @Deprecated('Use "complete" instead.')
  @pragma('vm:prefer-inline')
  Resolvable<T> finish(FutureOr<T> value) => complete(value);

  /// Completes the operation with the provided [value].
  @pragma('vm:prefer-inline')
  Resolvable<T> complete(FutureOr<T> value) => resolve(Resolvable(() => value));

  /// Returns a [Resolvable] that will complete when this [SafeCompleter] is
  /// completed.
  @pragma('vm:prefer-inline')
  Resolvable<T> resolvable() {
    return Resolvable(
      () => (_value.isSome() ? _value.unwrap() : _completer.future),
    );
  }

  /// Checks if the value has been set or if the [SafeCompleter] is completed.
  @pragma('vm:prefer-inline')
  bool get isCompleted => _completer.isCompleted || _value.isSome();

  /// Transforms the type of the value managed by this [SafeCompleter].
  SafeCompleter<R> transf<R extends Object>([R Function(T e)? transformer]) {
    final completer = SafeCompleter<R>();
    resolvable().map((e) {
      try {
        final result = transformer != null ? transformer(e) : (e as R);
        completer.resolve(Sync<R>.value(Ok(result)));
      } catch (e) {
        completer.resolve(Sync.value(Err('Failed to transform type $T to $R.')));
      }
      return e;
    });
    return completer;
  }
}
