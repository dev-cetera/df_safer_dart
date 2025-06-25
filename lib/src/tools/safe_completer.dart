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

// ignore_for_file: no_future_monad_type_or_error

import '/_common.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// A wrapper around Dart's [Completer] that prevents it from being completed
/// more than once.
///
/// It provides a monadic API for resolving a value and safely accessing the
/// result via a [Resolvable]. This is useful for managing one-off asynchronous
/// operations where multiple callers might attempt to set the result.
class SafeCompleter<T extends Object> {
  final _completer = Completer<T>();

  // Caches the value once completed to avoid relying solely on the completer's
  // future, allowing synchronous access if the value is already available.
  Option<FutureOr<T>> _value = const None();

  // A guard to prevent re-entrant calls to `resolve`.
  bool _isCompleting = false;

  /// Safely resolves the completer with the outcome of a [Resolvable].
  ///
  /// If the completer is already completed or is in the process of completing,
  /// this method will return an [Err] and have no effect.
  Resolvable<T> resolve(Resolvable<T> resolvable) {
    if (_isCompleting) {
      return Sync.err(Err('SafeCompleter<$T> is already resolving!'));
    }
    _isCompleting = true;

    if (isCompleted) {
      _isCompleting = false;
      return Sync.err(Err('SafeCompleter<$T> is already completed!'));
    }

    // `ifOk` and `ifErr` are used to handle the two possible outcomes of the
    // resolvable, ensuring the completer is correctly handled in both cases.
    return resolvable
        .ifOk((_, ok) {
          final okValue = ok.unwrap();
          _value = Some(okValue);
          _completer.complete(okValue);
        })
        .ifErr((_, err) {
          _completer.completeError(err);
        })
        .whenComplete((_) {
          // Ensure the lock is always released.
          _isCompleting = false;
          return resolvable;
        });
  }

  /// A convenience method to complete with a direct value or future.
  @pragma('vm:prefer-inline')
  Resolvable<T> complete(FutureOr<T> value) {
    return resolve(Resolvable(() => value));
  }

  /// Returns a [Resolvable] that provides access to the completer's result.
  ///
  /// If the completer has already been resolved synchronously, this will
  /// return a [Sync] with the value. Otherwise, it returns an [Async]
  /// containing the completer's future.
  @pragma('vm:prefer-inline')
  Resolvable<T> resolvable() {
    return Resolvable(() {
      switch (_value) {
        case Some(value: final okValue):
          return okValue;
        case None():
          return _completer.future;
      }
    });
  }

  /// Indicates whether the completer has been fulfilled with a value or error.
  @pragma('vm:prefer-inline')
  bool get isCompleted => _completer.isCompleted || _value.isSome();

  /// Creates a new [SafeCompleter] by transforming the future value of this one.
  ///
  /// When this completer finishes, its value will be passed to the [noFutures]
  /// function (or cast if null), and the result will be used to resolve the
  /// new completer.
  SafeCompleter<R> transf<R extends Object>([
    @noFutures R Function(T e)? noFutures,
  ]) {
    final newCompleter = SafeCompleter<R>();
    resolvable().then((e) {
      try {
        final result = noFutures != null ? noFutures(e) : (e as R);
        newCompleter.complete(result).end();
      } catch (error, stackTrace) {
        newCompleter
            .resolve(Sync.err(Err(error, stackTrace: stackTrace)))
            .end();
      }
      return e;
    }).end();
    return newCompleter;
  }
}
