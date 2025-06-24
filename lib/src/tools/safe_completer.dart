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

import '/_common.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

class SafeCompleter<T extends Object> {
  //
  //
  //

  final _completer = Completer<T>();
  Option<FutureOr<T>> _value = const None();
  bool _isCompleting = false;

  //
  //
  //

  /// Completes the operation with the provided [resolvable].
  Resolvable<T> resolve(Resolvable<T> resolvable) {
    if (_isCompleting) {
      return Sync.err(Err('SafeCompleter<$T> is already resolving!'));
    }
    _isCompleting = true;
    if (isCompleted) {
      _isCompleting = false;
      return Sync.err(Err('SafeCompleter<$T> is already completed!'));
    }

    return resolvable.ifOk((self, ok) {
      final okValue = ok.unwrap();
      _value = Some(okValue);
      _completer.complete(okValue);
      _isCompleting = false;
    }).ifErr((self, err) {
      _completer.completeError(err);
      _isCompleting = false;
    });
  }

  /// Completes the operation with the provided [value].
  @pragma('vm:prefer-inline')
  Resolvable<T> complete(FutureOr<T> value) {
    return resolve(Resolvable(() => value));
  }

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
    resolvable().then((e) {
      try {
        final result = noFuturesAllowed != null ? noFuturesAllowed(e) : (e as R);
        completer.resolve(Sync.okValue(result)).end();
      } catch (error, stackTrace) {
        completer
            .resolve(
              Sync.err(
                Err(
                  error,
                  stackTrace: stackTrace,
                ),
              ),
            )
            .end();
      }
      return e;
    }).end();
    return completer;
  }
}
