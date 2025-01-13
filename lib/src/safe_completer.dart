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

import 'resolvable.dart';
import 'option.dart';
import 'result.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

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

  /// Completes the operation with the provided [resolvable].
  Resolvable<T> resolve(Resolvable<T> value) {
    if (isCompleted) {
      return Sync(
        Err(
          stack: [SafeCompleter, resolve],
          error: 'Cannot complete an already completed SafeCompleter.',
        ),
      );
    }
    return value.map((e) {
      _value = Some(e);
      _completer.complete(e);
      return e;
    });
  }

  /// Completes the operation with the provided [value].
  @pragma('vm:prefer-inline')
  Resolvable<T> complete(FutureOr<T> value) => resolve(Resolvable.resolve(() => value));

  /// Checks if the value has been set or if the [SafeCompleter] is completed.
  @pragma('vm:prefer-inline')
  Resolvable<T> get resolvable {
    return Resolvable.resolve(
      // ignore: invalid_use_of_visible_for_testing_member
      () => _value.fold((e) => Some(e), () => Some(_completer.future)).some().unwrap().unwrap(),
    );
  }

  /// Checks if the value has been set or if the [SafeCompleter] is completed.
  @pragma('vm:prefer-inline')
  bool get isCompleted => _completer.isCompleted || _value.isSome();
}
