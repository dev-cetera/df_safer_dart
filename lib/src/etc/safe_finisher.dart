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
  Resolvable<T> resolve(Resolvable<T> value) {
    if (isCompleted) {
      return const Sync(
        Err(
          stack: ['SafeCompleter', 'resolve'],
          error: 'Tried completing a completed SafeCompleter.',
        ),
      );
    }

    return value.flatMap((e) {
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
  Resolvable<T> complete(FutureOr<T> value) =>
      resolve(Resolvable.unsafe(() => value));

  /// Checks if the value has been set or if the [SafeFinisher] is completed.
  @pragma('vm:prefer-inline')
  Resolvable<T> get resolvable {
    return Resolvable.unsafe(
      () => _value.isSome() ? _value.unwrap() : _completer.future,
    );
  }

  /// Checks if the value has been set or if the [SafeFinisher] is completed.
  @pragma('vm:prefer-inline')
  bool get isCompleted => _completer.isCompleted || _value.isSome();
}
