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

import 'concur.dart';
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

  //
  //
  //

  /// Completes the operation with the provided [concur].
  Concur<T> completeC(Concur<T> value) {
    if (isCompleted) return const Sync(Err('[SafeCompleter] Already completed!'));
    if (value.isAsync) {
      return value.async.unwrap().map((e) {
        return e.fold(
          (e) {
            _value = Some(e);
            _completer.complete(e);
            return Ok<T>(e);
          },
          (e) => Err<T>(e),
        );
      });
    } else {
      return value.sync.unwrap().map((e) {
        return e.fold(
          (e) {
            _value = Some(e);
            _completer.complete(e);
            return Ok<T>(e);
          },
          (e) => Err<T>(e),
        );
      });
    }
  }

  /// Completes the operation with the provided [value].
  @pragma('vm:prefer-inline')
  Concur<T> complete(FutureOr<T> value) => completeC(Concur.wrap(() => value));

  /// Checks if the value has been set or if the [SafeCompleter] is completed.
  @pragma('vm:prefer-inline')
  Concur<T> get concur {
    return Concur.wrap(
      () => _value.fold((e) => Some(e), () => Some(_completer.future)).some.unwrap(),
    );
  }

  /// Checks if the value has been set or if the [SafeCompleter] is completed.
  @pragma('vm:prefer-inline')
  bool get isCompleted => _completer.isCompleted || _value.isSome;
}
