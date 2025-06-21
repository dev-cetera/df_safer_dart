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

// ignore_for_file: must_use_unsafe_wrapper_or_error

part of '../monad.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// A [Monad] that represents a [Resolvable] that holds a synchronous [Result].
///
/// The contained [value] is never a [Future].
///
/// # IMPORTANT:
///
/// Do not use any Futures in the constructor [Sync.new] to ensure errors are
/// properly caught and propagated.
final class Sync<T extends Object> extends Resolvable<T> {
  /// Combines 2 [Sync] monads into 1 containing a tuple of their values
  /// if all resolve to [Ok].
  ///
  /// If any resolve to [Err], applies [onErr] function to combine errors.
  ///
  /// See also: [combineSync].
  static Sync<(T1, T2)> zip2<T1 extends Object, T2 extends Object>(
    Sync<T1> s1,
    Sync<T2> s2, [
    @noFuturesAllowed
    Err<(T1, T2)> Function(
      Result<T1>,
      Result<T2>,
    )? onErr,
  ]) {
    final combined = combineSync<Object>(
      [s1, s2],
      onErr: onErr == null
          ? null
          : (l) => onErr(
                l[0].transf<T1>(),
                l[1].transf<T2>(),
              ).transfErr(),
    );
    return combined.map(
      (l) => (
        l[0] as T1,
        l[1] as T2,
      ),
    );
  }

  /// Combines 3 [Sync] monads into 1 containing a tuple of their values
  /// if all resolve to [Ok].
  ///
  /// If any resolve to [Err], applies [onErr] function to combine errors.
  ///
  /// See also: [combineSync].
  static Sync<(T1, T2, T3)> zip3<T1 extends Object, T2 extends Object, T3 extends Object>(
    Sync<T1> s1,
    Sync<T2> s2,
    Sync<T3> s3, [
    @noFuturesAllowed
    Err<(T1, T2, T3)> Function(
      Result<T1>,
      Result<T2>,
      Result<T3>,
    )? onErr,
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
    return combined.map(
      (l) => (
        l[0] as T1,
        l[1] as T2,
        l[2] as T3,
      ),
    );
  }

  @override
  @pragma('vm:prefer-inline')
  Result<T> get value => super.value as Result<T>;

  @protected
  @unsafeOrError
  const Sync.unsafe(Result<T> super.value) : super.unsafe();

  /// Creates a [Sync] with a pre-computed [Result].
  ///
  /// # IMPORTANT
  ///
  /// [T] must never be a [Future].
  Sync.value(Result<T> super.value)
      : assert(!_isSubtype<T, Future<Object>>(), '$T must never be a Future.'),
        super.unsafe();

  /// Creates a [Sync] executing a synchronous function [noFuturesAllowed].
  ///
  /// # IMPORTANT:
  ///
  /// Do not use any Futures in [noFuturesAllowed] to ensure errors are be
  /// caught and propagated.
  factory Sync(
    @mustBeAnonymous @noFuturesAllowed T Function() noFuturesAllowed, {
    @noFuturesAllowed Err<T> Function(Object? error)? onError,
    @noFuturesAllowed void Function()? onFinalize,
  }) {
    assert(!_isSubtype<T, Future<Object>>(), '$T must never be a Future.');
    return Sync.unsafe(() {
      try {
        return Ok(noFuturesAllowed());
      } on Err catch (e) {
        return e.transfErr<T>();
      } catch (error) {
        try {
          if (onError == null) {
            rethrow;
          }
          return onError(error);
        } catch (e) {
          return Err<T>(e);
        }
      } finally {
        onFinalize?.call();
      }
    }());
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
    @noFuturesAllowed void Function(Sync<T> sync) noFuturesAllowed,
  ) {
    try {
      noFuturesAllowed(this);
      return this;
    } catch (error) {
      return Sync.unsafe(Err(error));
    }
  }

  @override
  @pragma('vm:prefer-inline')
  Sync<T> ifAsync(
    @noFuturesAllowed void Function(Async<T> async) noFuturesAllowed,
  ) =>
      this;

  @override
  @pragma('vm:prefer-inline')
  Sync<R> resultMap<R extends Object>(
    @noFuturesAllowed Result<R> Function(Result<T> value) noFuturesAllowed,
  ) {
    return Sync(() => noFuturesAllowed(value).unwrap());
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
    @noFuturesAllowed Resolvable<Object>? Function(Sync<T> sync) onSync,
    @noFuturesAllowed Resolvable<Object>? Function(Async<T> async) onAsync,
  ) {
    try {
      return onSync(this) ?? this;
    } catch (error) {
      return Sync.unsafe(Err(error));
    }
  }

  @override
  @pragma('vm:prefer-inline')
  Sync<Object> foldResult(
    @noFuturesAllowed Result<Object>? Function(Ok<T> ok) onOk,
    @noFuturesAllowed Result<Object>? Function(Err<T> err) onErr,
  ) {
    return Sync.unsafe(value.fold(onOk, onErr));
  }

  @override
  @pragma('vm:prefer-inline')
  Sync<T> toSync() => this;

  @override
  @pragma('vm:prefer-inline')
  Async<T> toAsync() => Async.unsafe(Future.value(value));

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
  Sync<R> map<R extends Object>(
    @noFuturesAllowed R Function(T value) noFuturesAllowed,
  ) {
    return Sync(() => value.map((e) => noFuturesAllowed(e)).unwrap());
  }

  @override
  Sync<R> transf<R extends Object>([
    @noFuturesAllowed R Function(T e)? noFuturesAllowed,
  ]) {
    return Sync(() {
      final okOrErr = value.transf<R>(noFuturesAllowed);
      if (okOrErr.isErr()) {
        throw okOrErr;
      }
      return okOrErr.unwrap();
    });
  }

  @override
  @pragma('vm:prefer-inline')
  Some<Sync<T>> wrapSome() => Some(this);

  @override
  @pragma('vm:prefer-inline')
  Ok<Sync<T>> wrapOk() => Ok(this);

  @override
  @pragma('vm:prefer-inline')
  Resolvable<Sync<T>> wrapResolvable() => Resolvable(() => this);

  @override
  @pragma('vm:prefer-inline')
  Sync<Sync<T>> wrapSync() => Sync.unsafe(Ok(this));

  @override
  @pragma('vm:prefer-inline')
  Async<Sync<T>> wrapAsync() => Async.unsafe(Future.value(Ok(this)));

  @override
  @pragma('vm:prefer-inline')
  Sync<void> asVoid() => this;

  @override
  @pragma('vm:prefer-inline')
  void end() {}
}
