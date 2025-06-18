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

part of 'monad.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// A [Monad] that represents a value which can be resolved either synchronously
/// [Sync] or asynchronously [Async].
///
/// The [value] of a [Sync] is never a [Future] while the value of an [Async]
/// is always a [Future].
sealed class Resolvable<T extends Object> extends Monad<T> {
  const Resolvable.unsafe(this.value);

  /// Combines 2 [Resolvable] monads into 1 containing a tuple of their values
  /// if all resolve to [Ok].
  ///
  /// If any resolve to [Err], applies [onErr] function to combine errors.
  static Resolvable<(T1, T2)> zip2<T1 extends Object, T2 extends Object>(
    Resolvable<T1> r1,
    Resolvable<T2> r2,
    @noFuturesAllowed Err<(T1, T2)> Function(Result<T1>, Result<T2>) onErr,
  ) {
    switch ((r1, r2)) {
      case (Sync(value: final v1), Sync(value: final v2)):
        return Sync.zip2(Sync.unsafe(v1), Sync.unsafe(v2), onErr);
      case (final res1, final res2):
        return Async.zip2(res1.toAsync(), res2.toAsync(), onErr);
    }
  }

  /// Combines 3 [Resolvable] monads into 1 containing a tuple of their values
  /// if all resolve to [Ok].
  ///
  /// If any resolve to [Err], applies [onErr] function to combine errors.
  static Resolvable<(T1, T2, T3)> zip3<T1 extends Object, T2 extends Object, T3 extends Object>(
    Resolvable<T1> r1,
    Resolvable<T2> r2,
    Resolvable<T3> r3,
    @noFuturesAllowed Err<(T1, T2, T3)> Function(Result<T1>, Result<T2>, Result<T3>) onErr,
  ) {
    switch ((r1, r2, r3)) {
      case (Sync(value: final v1), Sync(value: final v2), Sync(value: final v3)):
        return Sync.zip3(
          Sync.unsafe(v1),
          Sync.unsafe(v2),
          Sync.unsafe(v3),
          onErr,
        );
      case (final res1, final res2, final res3):
        return Async.zip3(
          res1.toAsync(),
          res2.toAsync(),
          res3.toAsync(),
          onErr,
        );
    }
  }

  /// The contained value.
  final FutureOr<Result<T>> value;

  /// Creates a [Sync] or [Async] depending on the return type of
  /// [mustAwaitAllFutures].
  ///
  /// # IMPORTANT:
  ///
  /// Always all futures witin [mustAwaitAllFutures] to ensure errors are be
  /// caught and propagated.
  factory Resolvable(
    @mustBeAnonymous @mustAwaitAllFutures FutureOr<T> Function() mustAwaitAllFutures, {
    @noFuturesAllowed Err<T> Function(Object? error)? onError,
    @noFuturesAllowed void Function()? onFinalize,
  }) {
    final result = mustAwaitAllFutures();
    if (result is Future<T>) {
      return Async(() => result, onError: onError, onFinalize: onFinalize);
    } else {
      return Sync(() => result, onError: onError, onFinalize: onFinalize);
    }
  }

  /// Returns `this` as a base [Resolvable] type.
  @pragma('vm:prefer-inline')
  Resolvable<T> asResolvable() => this;

  /// Returns `true` if this is a [Sync] instance.
  bool isSync();

  /// Returns `true` if this is an [Async] instance.
  bool isAsync();

  /// Safely gets the [Sync] instance.
  /// Returns an [Ok] on [Sync], or an [Err] on [Async].
  Result<Sync<T>> sync();

  /// Safely gets the [Async] instance.
  /// Returns an [Ok] on [Async], or an [Err] on [Sync].
  Result<Async<T>> async();

  /// Performs a side-effect if this is a [Sync].
  Resolvable<T> ifSync(
    @noFuturesAllowed void Function(Sync<T> sync) noFuturesAllowed,
  );

  /// Performs a side-effect if this is an [Async].
  Resolvable<T> ifAsync(
    @noFuturesAllowed void Function(Async<T> async) noFuturesAllowed,
  );

  /// Unsafely gets the [Sync] instance. Throws if not a [Sync].
  @unsafeOrError
  @pragma('vm:prefer-inline')
  Sync<T> unwrapSync() => sync().unwrap();

  /// Unsafely gets the [Async] instance. Throws if not an [Async].
  /// @unsafeOrError
  @unsafeOrError
  @pragma('vm:prefer-inline')
  Async<T> unwrapAsync() => async().unwrap();

  /// Maps the inner [Result] of this [Resolvable] using `mapper`.
  Resolvable<R> resultMap<R extends Object>(
    @noFuturesAllowed Result<R> Function(Result<T> value) noFuturesAllowed,
  );

  /// Maps the contained [Ok] value using a function that returns a `FutureOr`.
  Resolvable<R> mapFutureOr<R extends Object>(
    FutureOr<R> Function(T value) mapper,
  );

  /// Handles [Sync] and [Async] cases to produce a new [Resolvable].
  Resolvable<Object> fold(
    @noFuturesAllowed Resolvable<Object>? Function(Sync<T> sync) onSync,
    @noFuturesAllowed Resolvable<Object>? Function(Async<T> async) onAsync,
  );

  /// Exhaustively handles the inner [Ok] and [Err] cases, returning a new
  /// [Resolvable].
  Resolvable<Object> foldResult(
    @noFuturesAllowed Result<Object>? Function(Ok<T> ok) onOk,
    @noFuturesAllowed Result<Object>? Function(Err<T> err) onErr,
  );

  /// Exhaustively handles the inner [Ok] and [Err] cases, returning a value `R`.
  FutureOr<R> match<R extends Object>(
    R Function(T value) onOk,
    R Function(Err<T> err) onErr,
  );

  /// Unsafely converts this [Resolvable] to a [Sync]. Throws if it's an [Async].
  Sync<T> toSync();

  /// Converts this [Resolvable] to an [Async].
  Async<T> toAsync();

  /// Returns the contained [Ok] value or `null`, resolving any [Future].
  Future<T?> orNull();

  /// Returns this if it's [Sync], otherwise returns `other`.
  Resolvable<T> syncOr(Resolvable<T> other);

  /// Returns this if it's [Async], otherwise returns `other`.
  Resolvable<T> asyncOr(Resolvable<T> other);

  /// Returns this if it contains an [Ok], otherwise returns `other`.
  Resolvable<T> okOr(Resolvable<T> other);

  /// Returns this if it contains an [Err], otherwise returns `other`.
  Resolvable<T> errOr(Resolvable<T> other);

  /// Safely gets the [Ok] instance, resolving any [Future].
  FutureOr<Option<Ok<T>>> ok();

  /// Safely gets the [Err] instance, resolving any [Future].
  FutureOr<Option<Err<T>>> err();

  @override
  @unsafeOrError
  FutureOr<T> unwrap();

  @override
  FutureOr<T> unwrapOr(T fallback);

  @override
  Resolvable<R> map<R extends Object>(
    @noFuturesAllowed R Function(T value) noFuturesAllowed,
  );

  @override
  Resolvable<R> transf<R extends Object>([
    @noFuturesAllowed R Function(T e)? noFuturesAllowed,
  ]);

  @override
  @pragma('vm:prefer-inline')
  Some<Resolvable<T>> wrapSome() => Some(this);

  @override
  @pragma('vm:prefer-inline')
  Ok<Resolvable<T>> wrapOk() => Ok(this);

  @override
  @pragma('vm:prefer-inline')
  Resolvable<Resolvable<T>> wrapResolvable() => Resolvable(() => this);

  @override
  @pragma('vm:prefer-inline')
  Sync<Resolvable<T>> wrapSync() => Sync.unsafe(Ok(this));

  @override
  @pragma('vm:prefer-inline')
  Async<Resolvable<T>> wrapAsync() => Async.unsafe(Future.value(Ok(this)));

  @override
  @pragma('vm:prefer-inline')
  Resolvable<void> asVoid() => this;

  @override
  @pragma('vm:prefer-inline')
  List<Object?> get props => [value];

  @override
  @pragma('vm:prefer-inline')
  bool? get stringify => false;
}

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
  static Sync<(T1, T2)> zip2<T1 extends Object, T2 extends Object>(
    Sync<T1> s1,
    Sync<T2> s2,
    @noFuturesAllowed Err<(T1, T2)> Function(Result<T1>, Result<T2>) onErr,
  ) {
    return Sync(() {
      final r1 = s1.value;
      final r2 = s2.value;
      switch ((r1, r2)) {
        case (Ok(value: final v1), Ok(value: final v2)):
          return (v1, v2);
        default:
          throw onErr(r1, r2);
      }
    });
  }

  /// Combines 3 [Sync] monads into 1 containing a tuple of their values
  /// if all resolve to [Ok].
  ///
  /// If any resolve to [Err], applies [onErr] function to combine errors.
  static Sync<(T1, T2, T3)> zip3<T1 extends Object, T2 extends Object, T3 extends Object>(
    Sync<T1> s1,
    Sync<T2> s2,
    Sync<T3> s3,
    @noFuturesAllowed Err<(T1, T2, T3)> Function(Result<T1>, Result<T2>, Result<T3>) onErr,
  ) {
    return Sync(() {
      final r1 = s1.value;
      final r2 = s2.value;
      final r3 = s3.value;
      switch ((r1, r2, r3)) {
        case (Ok(value: final v1), Ok(value: final v2), Ok(value: final v3)):
          return (v1, v2, v3);
        default:
          throw onErr(r1, r2, r3);
      }
    });
  }

  @override
  // ignore: overridden_fields
  final Result<T> value;

  @protected
  const Sync.unsafe(this.value) : super.unsafe(value);

  /// Creates a [Sync] with a pre-computed [Result].
  ///
  /// # IMPORTANT
  ///
  /// [T] must never be a [Future].
  Sync.value(this.value)
      : assert(!_isSubtype<T, Future<Object>>(), '$T must never be a Future.'),
        super.unsafe(value);

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
  FutureOr<R> match<R extends Object>(
    R Function(T value) onOk,
    R Function(Err<T> err) onErr,
  ) {
    return value.match(onOk, onErr);
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
}

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
  static Async<(T1, T2)> zip2<T1 extends Object, T2 extends Object>(
    Async<T1> s1,
    Async<T2> s2,
    @noFuturesAllowed Err<(T1, T2)> Function(Result<T1>, Result<T2>) onErr,
  ) {
    return Async(() async {
      final r1 = await s1.value;
      final r2 = await s2.value;
      switch ((r1, r2)) {
        case (Ok(value: final v1), Ok(value: final v2)):
          return (v1, v2);
        default:
          throw onErr(r1, r2);
      }
    });
  }

  /// Combines 3 [Async] monads into 1 containing a tuple of their values
  /// if all resolve to [Ok].
  ///
  /// If any resolve to [Err], applies [onErr] function to combine errors.
  static Async<(T1, T2, T3)> zip3<T1 extends Object, T2 extends Object, T3 extends Object>(
    Async<T1> s1,
    Async<T2> s2,
    Async<T3> s3,
    @noFuturesAllowed Err<(T1, T2, T3)> Function(Result<T1>, Result<T2>, Result<T3>) onErr,
  ) {
    return Async(() async {
      final r1 = await s1.value;
      final r2 = await s2.value;
      final r3 = await s3.value;
      switch ((r1, r2, r3)) {
        case (Ok(value: final v1), Ok(value: final v2), Ok(value: final v3)):
          return (v1, v2, v3);
        default:
          throw onErr(r1, r2, r3);
      }
    });
  }

  @override
  // ignore: overridden_fields
  final Future<Result<T>> value;

  @protected
  const Async.unsafe(this.value) : super.unsafe(value);

  /// Creates an [Async] with a pre-computed [Future] of a [Result].
  ///
  /// # IMPORTANT
  ///
  /// [T] must never be a [Future].
  Async.value(this.value)
      : assert(!_isSubtype<T, Future<Object>>(), '$T must never be a Future.'),
        super.unsafe(value);

  /// Creates an [Async] by executing an asynchronous function
  /// [mustAwaitAllFutures].
  ///
  /// # IMPORTANT:
  ///
  /// Always all futures witin [mustAwaitAllFutures] to ensure errors are be
  /// caught and propagated.
  factory Async(
    @mustBeAnonymous @mustAwaitAllFutures Future<T> Function() mustAwaitAllFutures, {
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
  Future<R> match<R extends Object>(
    R Function(T value) onOk,
    R Function(Err<T> err) onErr,
  ) {
    return value.then((e) => e.match(onOk, onErr));
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
  @pragma('vm:prefer-inline')
  @unsafeOrError
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
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

@pragma('vm:prefer-inline')
bool _isSubtype<TChild, TParent>() => <TChild>[] is List<TParent>;
