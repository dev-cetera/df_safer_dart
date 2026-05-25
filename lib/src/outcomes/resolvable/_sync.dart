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

part of '../outcome.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// A [Outcome] that represents a [Resolvable] that holds a synchronous [Result].
///
/// The contained [value] is never a [Future].
///
/// # IMPORTANT:
///
/// Do not use any Futures in the constructor [Sync.new] to ensure errors are
/// properly caught and propagated.
final class Sync<T extends Object> extends Resolvable<T>
    implements SyncImpl<T> {
  /// Combines 2 [Sync] outcomes into 1 containing a tuple of their values
  /// if all resolve to [Ok].
  ///
  /// If any resolve to [Err], applies [onErr] function to combine errors.
  ///
  /// See also: [combineSync].
  static Sync<(T1, T2)> combine2<T1 extends Object, T2 extends Object>(
    Sync<T1> s1,
    Sync<T2> s2, [
    @noFutures Err<(T1, T2)> Function(Result<T1>, Result<T2>)? onErr,
  ]) {
    final combined = combineSync<Object>(
      [s1, s2],
      onErr: onErr == null
          ? null
          : (l) => onErr(l[0].transf<T1>(), l[1].transf<T2>()).transfErr(),
    );
    return combined.map((l) => (l[0] as T1, l[1] as T2));
  }

  /// Combines 3 [Sync] outcomes into 1 containing a tuple of their values
  /// if all resolve to [Ok].
  ///
  /// If any resolve to [Err], applies [onErr] function to combine errors.
  ///
  /// See also: [combineSync].
  static Sync<(T1, T2, T3)>
      combine3<T1 extends Object, T2 extends Object, T3 extends Object>(
    Sync<T1> s1,
    Sync<T2> s2,
    Sync<T3> s3, [
    @noFutures
    Err<(T1, T2, T3)> Function(Result<T1>, Result<T2>, Result<T3>)? onErr,
  ]) {
    final combined = combineSync<Object>(
      [s1, s2, s3],
      onErr: onErr == null
          ? null
          : (l) => onErr(
                l[0].transf<T1>(),
                l[1].transf<T2>(),
                l[2].transf<T3>(),
              ).transfErr(),
    );
    return combined.map((l) => (l[0] as T1, l[1] as T2, l[2] as T3));
  }

  @override
  @pragma('vm:prefer-inline')
  Result<T> get value => super.value as Result<T>;

  Sync.result(Result<T> super.value)
      : assert(!isSubtype<T, Future<Object>>(), '$T must never be a Future.'),
        super.result();

  Sync.ok(Ok<T> super.ok)
      : assert(!isSubtype<T, Future<Object>>(), '$T must never be a Future.'),
        super.ok();

  Sync.okValue(T okValue)
      : assert(!isSubtype<T, Future<Object>>(), '$T must never be a Future.'),
        super.ok(Ok(okValue));

  Sync.err(Err<T> super.err)
      : assert(!isSubtype<T, Future<Object>>(), '$T must never be a Future.'),
        super.err();

  Sync.errValue(Object error, {int? statusCode})
      : assert(!isSubtype<T, Future<Object>>(), '$T must never be a Future.'),
        super.err(Err(error, statusCode: statusCode));

  /// Creates a [Sync] executing a synchronous function [noFutures].
  ///
  /// # IMPORTANT:
  ///
  /// Do not use any Futures in [noFutures] to ensure errors are be
  /// caught and propagated.
  factory Sync(
    @mustBeAnonymous @noFutures T Function() noFutures, {
    @noFutures TOnErrorCallback<T>? onError,
    @noFutures TVoidCallback? onFinalize,
  }) {
    assert(!isSubtype<T, Future<Object>>(), '$T must never be a Future.');
    // Compute the inner Result inline instead of wrapping the try/catch in an
    // IIFE — the closure allocation that `() { ... }()` would force on every
    // `Sync(...)` call is unnecessary, and the control flow reads the same.
    Result<T> result;
    try {
      result = Ok(noFutures());
    } on Err catch (err) {
      result = err.transfErr<T>();
    } catch (error, stackTrace) {
      if (onError == null) {
        result = Err<T>(error, stackTrace: stackTrace);
      } else {
        try {
          result = onError(error, stackTrace);
        } catch (error, stackTrace) {
          result = Err<T>(error, stackTrace: stackTrace);
        }
      }
    } finally {
      onFinalize?.call();
    }
    return Sync.result(result);
  }

  @override
  @pragma('vm:prefer-inline')
  bool isSync() => true;

  @override
  @pragma('vm:prefer-inline')
  bool isAsync() => false;

  @override
  @pragma('vm:prefer-inline')
  Ok<Sync<T>> sync() => Ok(this);

  @override
  @pragma('vm:prefer-inline')
  Err<Async<T>> async() {
    return Err('Called async() on Sync<$T>.');
  }

  @override
  @pragma('vm:prefer-inline')
  Sync<T> ifSync(
    @noFutures void Function(Sync<T> self, Sync<T> sync) noFutures,
  ) {
    // Side-effect path: if the user callback throws, the absorbed error must
    // surface as an Err on the returned Sync. Doing the catch inline avoids
    // the `Sync(...).flatten().sync().unwrap()` chain that the previous
    // implementation needed — that allocated four Outcomes per call.
    try {
      noFutures(this, this);
      return this;
    } on Err catch (err) {
      // Preserve a user-thrown `Err` verbatim — matches the behaviour of the
      // `Sync(...)` factory's `on Err catch` clause that this refactor
      // replaced. Wrapping it would lose statusCode/breadcrumbs/stackTrace.
      return Sync.err(err.transfErr<T>());
    } catch (error, stackTrace) {
      return Sync.err(Err<T>(error, stackTrace: stackTrace));
    }
  }

  @override
  @pragma('vm:prefer-inline')
  Sync<T> ifAsync(
    @noFutures void Function(Sync<T> self, Async<T> async) noFutures,
  ) {
    return this;
  }

  @override
  @pragma('vm:prefer-inline')
  Resolvable<T> ifOk(
    @noFutures void Function(Sync<T> self, Ok<T> ok) noFutures,
  ) {
    final v = value;
    if (v is Ok<T>) {
      // Direct try/catch is two allocations cheaper than the old
      // `Resolvable(() {...}).flatten()` path, which materialised a
      // `Sync<Result<T>>` plus a `Sync<T>` on the success branch. The
      // `on Err catch` clause preserves a user-thrown `Err` verbatim, matching
      // the behaviour of the `Sync(...)` factory the previous form went
      // through.
      try {
        noFutures(this, v);
        return this;
      } on Err catch (err) {
        return Sync.err(err.transfErr<T>());
      } catch (error, stackTrace) {
        return Sync.err(Err<T>(error, stackTrace: stackTrace));
      }
    }
    return this;
  }

  @override
  @pragma('vm:prefer-inline')
  Resolvable<T> ifErr(
    @noFutures void Function(Sync<T> self, Err<T> err) noFutures,
  ) {
    final v = value;
    if (v is Err<T>) {
      try {
        noFutures(this, v);
        return this;
      } on Err catch (err) {
        return Sync.err(err.transfErr<T>());
      } catch (error, stackTrace) {
        return Sync.err(Err<T>(error, stackTrace: stackTrace));
      }
    }
    return this;
  }

  @override
  @pragma('vm:prefer-inline')
  Sync<R> resultMap<R extends Object>(
    @noFutures Result<R> Function(Result<T> value) noFutures,
  ) {
    // The mapper returns a `Result<R>` we can wrap directly; only the user
    // callback itself can throw, so we catch around its invocation and skip
    // the `Sync(() { ... .unwrap() })` round trip the previous form did.
    // `on Err catch` preserves a user-thrown `Err` verbatim — matches the
    // `Sync(...)` factory's behaviour the previous form went through.
    try {
      return Sync.result(noFutures(value));
    } on Err catch (err) {
      return Sync.err(err.transfErr<R>());
    } catch (error, stackTrace) {
      return Sync.err(Err<R>(error, stackTrace: stackTrace));
    }
  }

  @override
  @pragma('vm:prefer-inline')
  Resolvable<R> mapFutureOr<R extends Object>(
    FutureOr<R> Function(T value) mapper,
  ) {
    return Resolvable(() => mapper(value.unwrap()));
  }

  @override
  Resolvable<Object> fold(
    @noFutures Resolvable<Object>? Function(Sync<T> sync) onSync,
    @noFutures Resolvable<Object>? Function(Async<T> async) onAsync,
  ) {
    try {
      return onSync(this) ?? this;
    } catch (error, stackTrace) {
      return Sync.err(Err(error, stackTrace: stackTrace));
    }
  }

  @override
  @pragma('vm:prefer-inline')
  Sync<Object> foldResult(
    @noFutures Result<Object>? Function(Ok<T> ok) onOk,
    @noFutures Result<Object>? Function(Err<T> err) onErr,
  ) {
    return Sync.result(value.fold(onOk, onErr));
  }

  @override
  @pragma('vm:prefer-inline')
  Async<T> toAsync() => Async.result(value);

  @override
  @pragma('vm:prefer-inline')
  Future<T?> orNull() => Future.value(value.orNull());

  @override
  @pragma('vm:prefer-inline')
  Sync<T> syncOr(Resolvable<T> other) => this;

  @override
  @pragma('vm:prefer-inline')
  Resolvable<T> asyncOr(Resolvable<T> other) => other;

  @override
  @pragma('vm:prefer-inline')
  Resolvable<T> okOr(Resolvable<T> other) {
    switch (value) {
      case Ok():
        return this;
      case Err():
        return other;
    }
  }

  @override
  @pragma('vm:prefer-inline')
  Resolvable<T> errOr(Resolvable<T> other) {
    switch (value) {
      case Err():
        return this;
      case Ok():
        return other;
    }
  }

  @override
  @pragma('vm:prefer-inline')
  Option<Ok<T>> ok() => value.ok();

  @override
  @pragma('vm:prefer-inline')
  Option<Err<T>> err() => value.err();

  @override
  @unsafeOrError
  @pragma('vm:prefer-inline')
  T unwrap() => value.unwrap();

  @override
  T unwrapOr(T fallback) => value.unwrapOr(fallback);

  @override
  @pragma('vm:prefer-inline')
  Sync<R> map<R extends Object>(@noFutures R Function(T value) noFutures) {
    // Pass the user callback directly to `Result.map` rather than wrapping it
    // in `(e) => noFutures(e)` — that wrapper would allocate one closure per
    // call for no semantic benefit.
    return Sync(() => value.map(noFutures).unwrap());
  }

  /// Prefer using [map] for [Sync].
  @protected
  @override
  @pragma('vm:prefer-inline')
  Sync<R> then<R extends Object>(@noFutures R Function(T value) noFutures) {
    return map(noFutures);
  }

  @override
  @pragma('vm:prefer-inline')
  Resolvable<R> whenComplete<R extends Object>(
    @noFutures Resolvable<R> Function(Sync<T> resolved) noFutures,
  ) {
    // The previous form built `Sync<Resolvable<R>>` and then `.flatten()`d it
    // — two extra Outcome allocations per call. Inline the try/catch and
    // return the user's Resolvable directly. `on Err catch` preserves a
    // user-thrown `Err` verbatim — matches the `Sync(...)` factory's
    // behaviour the previous form went through. The Err can come from either
    // `value.unwrap()` (when `value` is an `Err`) or from the user callback.
    try {
      value.unwrap();
      return noFutures(this);
    } on Err catch (err) {
      return Sync.err(err.transfErr<R>());
    } catch (error, stackTrace) {
      return Sync.err(Err<R>(error, stackTrace: stackTrace));
    }
  }

  @override
  @pragma('vm:prefer-inline')
  Sync<R> transf<R extends Object>([@noFutures R Function(T e)? noFutures]) {
    // `Result.transf` already absorbs callback throws into an `Err` and
    // never escapes, so we can wrap the result directly without going
    // through `Sync(() { ... throw ... })`. Saves the inner closure
    // allocation and the throw/catch round trip on every call.
    return Sync.result(value.transf<R>(noFutures));
  }

  @override
  @pragma('vm:prefer-inline')
  void end() {}
}
