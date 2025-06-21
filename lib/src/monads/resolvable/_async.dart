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

/// A [Monad] that represents a [Resolvable] that holds an asynchronous [Result].
///
/// The contained [value] is always a [Future].
///
/// # IMPORTANT:
///
/// Await all Futures in the constructor [Async.new] to ensure errors are
/// properly caught and propagated.
final class Async<T extends Object> extends Resolvable<T> {
  /// Combines 2 [Async] monads into 1 containing a tuple of their values
  /// if all resolve to [Ok].
  ///
  /// If any resolve to [Err], applies [onErr] function to combine errors.
  ///
  /// See also: [combineAsync].
  static Async<(T1, T2)> zip2<T1 extends Object, T2 extends Object>(
    Async<T1> a1,
    Async<T2> a2, [
    @noFuturesAllowed Err<(T1, T2)> Function(Result<T1>, Result<T2>)? onErr,
  ]) {
    final combined = combineAsync<Object>(
      [a1, a2],
      onErr: onErr == null
          ? null
          : (l) => onErr(l[0].transf<T1>(), l[1].transf<T2>()).transfErr(),
    );
    return combined.map((l) => (l[0] as T1, l[1] as T2));
  }

  /// Combines 3 [Async] monads into 1 containing a tuple of their values
  /// if all resolve to [Ok].
  ///
  /// If any resolve to [Err], applies [onErr] function to combine errors.
  ///
  /// See also: [combineAsync].
  static Async<(T1, T2, T3)>
  zip3<T1 extends Object, T2 extends Object, T3 extends Object>(
    Async<T1> a1,
    Async<T2> a2,
    Async<T3> a3, [
    @noFuturesAllowed
    Err<(T1, T2, T3)> Function(Result<T1>, Result<T2>, Result<T3>)? onErr,
  ]) {
    final combined = combineAsync<Object>(
      [a1, a2, a3],
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
  Future<Result<T>> get value => super.value as Future<Result<T>>;

  @protected
  @unsafeOrError
  const Async.unsafe(Future<Result<T>> super.value) : super.unsafe();

  /// Creates an [Async] with a pre-computed [Future] of a [Result].
  ///
  /// # IMPORTANT
  ///
  /// [T] must never be a [Future].
  Async.value(Future<Result<T>> super.value)
    : assert(!_isSubtype<T, Future<Object>>(), '$T must never be a Future.'),
      super.unsafe();

  /// Creates an [Async] by executing an asynchronous function
  /// [mustAwaitAllFutures].
  ///
  /// # IMPORTANT:
  ///
  /// Always all futures witin [mustAwaitAllFutures] to ensure errors are be
  /// caught and propagated.
  factory Async(
    @mustBeAnonymous
    @mustAwaitAllFutures
    Future<T> Function() mustAwaitAllFutures, {
    @noFuturesAllowed Err<T> Function(Object? error)? onError,
    @noFuturesAllowed void Function()? onFinalize,
  }) {
    assert(!_isSubtype<T, Future<Object>>(), '$T must never be a Future.');
    return Async.unsafe(() async {
      try {
        return Ok<T>(await mustAwaitAllFutures());
      } on Err catch (e) {
        return e.transfErr<T>();
      } catch (error) {
        try {
          if (onError == null) {
            rethrow;
          }
          return onError(error);
        } catch (error) {
          return Err<T>(error);
        }
      } finally {
        onFinalize?.call();
      }
    }());
  }

  @override
  @pragma('vm:prefer-inline')
  bool isSync() => false;

  @override
  @pragma('vm:prefer-inline')
  bool isAsync() => true;

  @override
  @pragma('vm:prefer-inline')
  Err<Sync<T>> sync() {
    return Err('Called sync() on Async<$T>.');
  }

  @override
  @pragma('vm:prefer-inline')
  Ok<Async<T>> async() => Ok(this);

  @override
  @pragma('vm:prefer-inline')
  Async<T> ifSync(
    @noFuturesAllowed void Function(Sync<T> async) noFuturesAllowed,
  ) {
    return this;
  }

  @override
  @pragma('vm:prefer-inline')
  Async<T> ifAsync(
    @noFuturesAllowed void Function(Async<T> async) noFuturesAllowed,
  ) {
    try {
      noFuturesAllowed(this);
      return this;
    } catch (error) {
      return Async.unsafe(Future.value(Err(error)));
    }
  }

  @override
  Async<R> resultMap<R extends Object>(
    @noFuturesAllowed Result<R> Function(Result<T> value) noFuturesAllowed,
  ) {
    return Async(() async {
      final a = await value;
      switch (a) {
        case Ok():
          final b = noFuturesAllowed(a);
          switch (b) {
            case Ok(value: final v):
              return v;
            case Err():
              throw b;
          }
        case Err():
          throw a;
      }
    });
  }

  @override
  @pragma('vm:prefer-inline')
  Async<R> mapFutureOr<R extends Object>(FutureOr<R> Function(T value) mapper) {
    return Async(() async => mapper((await value).unwrap()));
  }

  @override
  @pragma('vm:prefer-inline')
  Resolvable<Object> fold(
    @noFuturesAllowed Resolvable<Object>? Function(Sync<T> sync) onSync,
    @noFuturesAllowed Resolvable<Object>? Function(Async<T> async) onAsync,
  ) {
    try {
      return onAsync(this) ?? this;
    } catch (error) {
      return Async.unsafe(Future.value(Err(error)));
    }
  }

  @override
  @pragma('vm:prefer-inline')
  Async<Object> foldResult(
    @noFuturesAllowed Result<Object>? Function(Ok<T> ok) onOk,
    @noFuturesAllowed Result<Object>? Function(Err<T> err) onErr,
  ) {
    return this.resultMap((e) => e.fold(onOk, onErr));
  }

  @override
  @pragma('vm:prefer-inline')
  Sync<T> toSync() {
    throw Err<T>('Called toSync() on Async<$T>.');
  }

  @override
  @pragma('vm:prefer-inline')
  Async<T> toAsync() => this;

  @override
  @pragma('vm:prefer-inline')
  Future<T?> orNull() => value.then((e) => e.orNull());

  @override
  @pragma('vm:prefer-inline')
  Resolvable<T> syncOr(Resolvable<T> other) => other;

  @override
  @pragma('vm:prefer-inline')
  Async<T> asyncOr(Resolvable<T> other) => this;

  @override
  @pragma('vm:prefer-inline')
  Async<T> okOr(Resolvable<T> other) {
    return Async(() async {
      final awaitedValue = await value;
      switch (awaitedValue) {
        case Ok(value: final v):
          return v;
        case Err():
          return (await other.value).unwrap();
      }
    });
  }

  @override
  @pragma('vm:prefer-inline')
  Async<T> errOr(Resolvable<T> other) {
    return Async(() async {
      final awaitedValue = await value;
      switch (awaitedValue) {
        case Err():
          return awaitedValue.unwrap();
        case Ok():
          return (await other.value).unwrap();
      }
    });
  }

  @override
  @pragma('vm:prefer-inline')
  Future<Option<Ok<T>>> ok() => value.then((e) => e.ok());

  @override
  @pragma('vm:prefer-inline')
  Future<Option<Err<T>>> err() => value.then((e) => e.err());

  @override
  @unsafeOrError
  @pragma('vm:prefer-inline')
  Future<T> unwrap() => value.then((e) => e.unwrap());

  @override
  FutureOr<T> unwrapOr(T fallback) => value.then((e) => e.unwrapOr(fallback));

  @override
  @pragma('vm:prefer-inline')
  Async<R> map<R extends Object>(
    @noFuturesAllowed R Function(T value) noFuturesAllowed,
  ) {
    return Async.unsafe(value.then((e) => e.map(noFuturesAllowed)));
  }

  @override
  Async<R> transf<R extends Object>([
    @noFuturesAllowed R Function(T e)? noFuturesAllowed,
  ]) {
    return Async(() async {
      final okOrErr = (await value).transf<R>(noFuturesAllowed);
      switch (okOrErr) {
        case Ok(value: final v):
          return v;
        case Err():
          throw okOrErr;
      }
    });
  }

  @override
  @pragma('vm:prefer-inline')
  Some<Async<T>> wrapSome() => Some(this);

  @override
  @pragma('vm:prefer-inline')
  Ok<Async<T>> wrapOk() => Ok(this);

  @override
  @pragma('vm:prefer-inline')
  Resolvable<Async<T>> wrapResolvable() => Resolvable(() => this);

  @override
  @pragma('vm:prefer-inline')
  Sync<Async<T>> wrapSync() => Sync.unsafe(Ok(this));

  @override
  @pragma('vm:prefer-inline')
  Async<Async<T>> wrapAsync() => Async.unsafe(Future.value(Ok(this)));

  @override
  @pragma('vm:prefer-inline')
  Async<void> asVoid() => this;

  @override
  @pragma('vm:prefer-inline')
  Future<void> end() {
    return value.then((e) => e.end()).catchError((_) {});
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

@pragma('vm:prefer-inline')
bool _isSubtype<TChild, TParent>() => <TChild>[] is List<TParent>;
