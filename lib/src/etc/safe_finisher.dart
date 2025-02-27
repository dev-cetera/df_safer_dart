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

import '../monad/monad.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// A utility class for managing completion of both synchronous and asynchronous
/// values.
///
/// [SafeFinisher] is similar to a [Completer], but it handles both synchronous
/// and asynchronous results seamlessly.
class SafeFinisher<T extends Object> {
  //
  //
  //

  final _completer = Completer<T>();

  Option<FutureOr<T>> _value = const None();

  /// Completes the operation with the provided [resolvable].
  Resolvable<T> resolve(Resolvable<T> resolvable) {
    if (isCompleted) {
      return Sync.value(
        Err(
          debugPath: ['SafeCompleter', 'resolve'],
          error: 'Cannot resolved a finished SafeCompleter.',
        ),
      );
    }

    return resolvable.flatMap((e) {
      if (e.isOk()) {
        final a = e.unwrap();
        _value = Some(a);
        _completer.complete(a);
        return e;
      } else {
        final err = e.err();
        _completer.completeError(err);
        return err;
      }
    });
  }

  /// Completes the operation with the provided [value].
  @pragma('vm:prefer-inline')
  Resolvable<T> finish(FutureOr<T> value) => resolve(Resolvable(() => value));

  /// Checks if the value has been set or if the [SafeFinisher] is completed.
  @pragma('vm:prefer-inline')
  Resolvable<T> resolvable() {
    return Resolvable(
      () => (_value.isSome() ? _value.unwrap() : _completer.future),
    );
  }

  /// Checks if the value has been set or if the [SafeFinisher] is completed.
  @pragma('vm:prefer-inline')
  bool get isCompleted => _completer.isCompleted || _value.isSome();

  SafeFinisher<R> trans<R extends Object>([R Function(T e)? transformer]) {
    final finisher = SafeFinisher<R>();
    resolvable().map((e) {
      finisher.resolve(SyncOk<R>.value(transformer?.call(e) ?? (e as R)));
      return e;
    });
    return finisher;
  }
}
