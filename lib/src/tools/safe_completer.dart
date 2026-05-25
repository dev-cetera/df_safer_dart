//.title
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//
// Copyright © dev-cetera.com & contributors.
//
// The use of this source code is governed by an MIT-style license described in
// the LICENSE file located in this project's root directory.
//
// See: https://opensource.org/license/mit
//
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//.title~

import '/_common.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// A wrapper around Dart's [Completer] that prevents it from being completed
/// more than once.
///
/// It provides an API for resolving a value and safely accessing the result
/// via a [Resolvable]. This is useful for managing one-off asynchronous
/// operations where multiple callers might attempt to set the result.
///
/// ### Isolate sendability (current state)
///
/// `SafeCompleter` is **not yet sendable** through `SendPort`: it wraps a
/// `dart:async` [Completer], which is bound to the isolate that created it.
/// Sending a `SafeCompleter` will throw at runtime. A future phase will
/// replace the internal completer with a conditional `SendPort` broker on VM
/// platforms so the completer itself can travel between isolates. Web
/// platforms have no isolates, so the current implementation is appropriate
/// there.
///
/// In the meantime, ship the **result** instead: await the completer locally,
/// then send the resulting [Result] (which is fully sendable) to the
/// destination isolate.
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
    // Check terminal state directly (do NOT read `isCompleted` here — that
    // now includes the `_isCompleting` flag we're about to set below, which
    // would always make this check trip).
    if (_completer.isCompleted || _value.isSome()) {
      return Sync.err(Err('SafeCompleter<$T> is already completed!'));
    }
    _isCompleting = true;

    // `ifOk` and `ifErr` are used to handle the two possible outcomes of the
    // resolvable, ensuring the completer is correctly handled in both cases.
    return resolvable.ifOk((_, ok) {
      final okValue = ok.unwrap();
      _value = Some(okValue);
      _completer.complete(okValue);
    }).ifErr((_, err) {
      _completer.completeError(err);
    }).whenComplete((_) {
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
    // Dispatch inline. Going through `Resolvable.new(() {...})` would invoke
    // the caller's closure to peek at the value, then allocate a second
    // closure for the chosen `Sync()`/`Async()`. By branching here we save
    // one closure allocation per call.
    final v = _value;
    if (v is Some<FutureOr<T>>) {
      final inner = v.value;
      if (inner is Future<T>) return Async<T>(() => inner);
      return Sync.okValue(inner);
    }
    return Async<T>(() => _completer.future);
  }

  /// Indicates whether the completer has been claimed for completion.
  ///
  /// Returns `true` once any of the following holds:
  ///
  /// 1. A resolve has been accepted (even if its underlying future has not
  ///    yet settled — the completer is "committed" and subsequent resolves
  ///    will be rejected with an [Err]).
  /// 2. The wrapped [Completer] has been completed synchronously.
  /// 3. The cached value has been populated.
  ///
  /// Reading this property does not race with an in-flight async resolve:
  /// observers see `true` for the entire interval starting when [resolve]
  /// accepts work, not only after the underlying future settles.
  @pragma('vm:prefer-inline')
  bool get isCompleted =>
      _isCompleting || _completer.isCompleted || _value.isSome();

  /// Creates a new [SafeCompleter] by transforming the future value of this one.
  ///
  /// When this completer finishes, its value will be passed to the [noFutures]
  /// function (or cast if null), and the result will be used to resolve the
  /// new completer.
  SafeCompleter<R> transf<R extends Object>([
    @noFutures @sendable R Function(T e)? noFutures,
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
