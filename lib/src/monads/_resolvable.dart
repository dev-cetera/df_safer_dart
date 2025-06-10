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
/// [Sync] or asynchronously [Async]. The value of a [Sync] is never a [Future]
/// while the value of an [Async] is always a [Future].
sealed class Resolvable<T extends Object> extends Monad<T> {
  /// The underlying value, which is a `FutureOr` of a [Result].
  final FutureOr<Result<T>> value;

  const Resolvable.value(this.value);

  /// Creates a [Sync] or [Async] depending on the return type of [unsafe].
  factory Resolvable(
    FutureOr<T> Function() unsafe, {
    Err<T> Function(Object? error)? onError,
    void Function()? onFinalize,
  }) {
    final result = unsafe();
    if (result is Future<T>) {
      return Async(() => result, onError: onError, onFinalize: onFinalize);
    } else {
      return Sync(() => result, onError: onError, onFinalize: onFinalize);
    }
  }

  /// Returns this as an [Resolvable].
  @pragma('vm:prefer-inline')
  Resolvable<T> asResolvable() => this;

  /// Converts this [Resolvable] to an [Async].
  Async<T> asAsync();

  /// Returns this [Resolvable] as a [Some].
  Some<Resolvable<T>> asSome();

  /// Returns this [Resolvable] as a [None].
  None<Resolvable<T>> asNone();

  /// Returns this [Resolvable] as an [Ok].
  Ok<Resolvable<T>> asOk();

  /// Returns `true` if this is a [Sync] instance.
  bool isSync();

  /// Returns `true` if this is an [Async] instance.
  bool isAsync();

  /// Performs a side-effect if this is a [Sync].
  Resolvable<T> ifSync(void Function(Sync<T> sync) unsafe);

  /// Performs a side-effect if this is an [Async].
  Resolvable<T> ifAsync(void Function(Async<T> async) unsafe);

  /// Returns a [Result] containing the [Sync] instance if it is one.
  Result<Sync<T>> sync();

  /// Returns a [Result] containing the [Async] instance if it is one.
  Result<Async<T>> async();

  /// Returns the contained [Ok] value, resolving the [Future] if necessary.
  @override
  FutureOr<T> unwrap({int delta = 1});

  @override
  FutureOr<T> unwrapOr(T fallback);

  @override
  @pragma('vm:prefer-inline')
  FutureOr<T> unwrapOrElse(T Function() unsafe) => unwrapOr(unsafe());

  /// Unwraps the [Sync] instance and returns its value. Throws if not [Sync].
  @pragma('vm:prefer-inline')
  Sync<T> unwrapSync({int stackLevel = 2}) => sync().unwrap(delta: stackLevel);

  /// Unwraps the [Async] instance and returns its value. Throws if not [Async].
  @pragma('vm:prefer-inline')
  Async<T> unwrapAsync({int stackLevel = 2}) => async().unwrap(delta: stackLevel);

  /// Maps the contained [Ok] value to a new value.
  @override
  Resolvable<R> map<R extends Object>(R Function(T value) unsafe);

  /// Chains [Resolvable] computations by applying a function to the inner [Result].
  Resolvable<R> resultMap<R extends Object>(
    Result<R> Function(Result<T> value) mapper,
  );

  /// Maps the contained [Ok] value using a function that returns a `FutureOr`.
  Resolvable<R> mapFutureOr<R extends Object>(
    FutureOr<R> Function(T value) unsafe,
  );

  /// Handles [Sync] and [Async] cases to produce a new [Resolvable].
  Resolvable<Object> fold(
    Resolvable<Object>? Function(Sync<T> sync) onSync,
    Resolvable<Object>? Function(Async<T> async) onAsync,
  );

  /// Exhaustively handles [Ok] and [Err] cases, returning a final value.
  Resolvable<Object> foldResult(
    Result<Object>? Function(Ok<T> ok) onOk,
    Result<Object>? Function(Err<T> err) onErr,
  );

  /// Exhaustively handles [Ok] and [Err] cases, returning a final value.
  FutureOr<R> match<R extends Object>(
    R Function(T value) onOk,
    R Function(Err<T> err) onErr,
  );

  /// Converts this [Resolvable] to a [Sync]. Throws if it's an [Async].
  Sync<T> toSync();

  /// Converts this [Resolvable] to an [Async].
  Async<T> toAsync();

  /// Returns the contained [Ok] value or `null`, resolving the [Future] if necessary.
  Future<T?> orNull();

  /// Returns this if it's [Sync], otherwise returns [other].
  Resolvable<Object> syncOr<R extends Object>(Resolvable<R> other);

  /// Returns this if it's [Async], otherwise returns [other].
  Resolvable<Object> asyncOr<R extends Object>(Resolvable<R> other);

  /// Transforms the contained [Ok] value's type from `T` to `R`.
  @override
  Resolvable<R> transf<R extends Object>([R Function(T e)? transformer]);

  /// Returns the value as an [Ok] if possible or [None] if there's an error.
  FutureOr<Option<Ok<T>>> ok();

  /// Returns the [Err] if possible or [None] if there is a value.
  FutureOr<Option<Err<T>>> err();

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
  Sync<Resolvable<T>> wrapSync() => Sync.value(Ok(this));

  @override
  @pragma('vm:prefer-inline')
  Async<Resolvable<T>> wrapAsync() => Async.value(Future.value(Ok(this)));

  @override
  @pragma('vm:prefer-inline')
  List<Object?> get props => [this.value];

  @override
  @pragma('vm:prefer-inline')
  bool? get stringify => false;
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// A [Monad] that represnets a [Resolvable] that holds a synchronous [Result].
/// It's [value] is never a [Future].
final class Sync<T extends Object> extends Resolvable<T> {
  @override
  // ignore: overridden_fields
  final Result<T> value;

  /// Creates a [Sync] with a pre-computed [Result].
  const Sync.value(this.value) : super.value(value);

  /// Creates a [Sync] by executing a synchronous function [unsafe].
  factory Sync(
    T Function() unsafe, {
    Err<T> Function(Object? error)? onError,
    void Function()? onFinalize,
  }) {
    return Sync.value(() {
      try {
        return Ok(unsafe());
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
  Async<T> asAsync() => Async.value(Future.value(value));

  @override
  @pragma('vm:prefer-inline')
  Some<Sync<T>> asSome() => Some(this);

  @override
  @pragma('vm:prefer-inline')
  None<Sync<T>> asNone() => const None();

  @override
  @pragma('vm:prefer-inline')
  Ok<Sync<T>> asOk() => Ok(this);

  @override
  @pragma('vm:prefer-inline')
  bool isSync() => true;

  @override
  @pragma('vm:prefer-inline')
  bool isAsync() => false;

  @override
  @pragma('vm:prefer-inline')
  Sync<T> ifSync(void Function(Sync<T> sync) unsafe) {
    try {
      unsafe(this);
      return this;
    } catch (error) {
      return Sync.value(Err(error));
    }
  }

  @override
  @pragma('vm:prefer-inline')
  Sync<T> ifAsync(void Function(Async<T> async) unsafe) => this;

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
  T unwrap({int delta = 1}) => value.unwrap(delta: delta);

  @override
  T unwrapOr(T fallback) => value.unwrapOr(fallback);

  @override
  @pragma('vm:prefer-inline')
  Sync<R> map<R extends Object>(R Function(T value) unsafe) {
    return Sync(() => value.map((e) => unsafe(e)).unwrap());
  }

  @override
  @pragma('vm:prefer-inline')
  Sync<R> resultMap<R extends Object>(
    Result<R> Function(Result<T> value) mapper,
  ) {
    return Sync.value(mapper(value));
  }

  @override
  @pragma('vm:prefer-inline')
  Resolvable<R> mapFutureOr<R extends Object>(
    FutureOr<R> Function(T value) unsafe,
  ) {
    return Resolvable(() => unsafe(value.unwrap()));
  }

  @override
  Resolvable<Object> fold(
    Resolvable<Object>? Function(Sync<T> sync) onSync,
    Resolvable<Object>? Function(Async<T> async) onAsync,
  ) {
    try {
      return onSync(this) ?? this;
    } catch (error) {
      return Sync.value(Err(error));
    }
  }

  @override
  @pragma('vm:prefer-inline')
  Sync<Object> foldResult(
    Result<Object>? Function(Ok<T> ok) onOk,
    Result<Object>? Function(Err<T> err) onErr,
  ) {
    return Sync.value(value.fold(onOk, onErr));
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
  Async<T> toAsync() => Async.value(Future.value(value));

  @override
  @pragma('vm:prefer-inline')
  Future<T?> orNull() async => value.orNull();

  @override
  @pragma('vm:prefer-inline')
  Sync<Object> syncOr<R extends Object>(Resolvable<R> other) => this;

  @override
  @pragma('vm:prefer-inline')
  Resolvable<R> asyncOr<R extends Object>(Resolvable<R> other) => other;

  @override
  Sync<R> transf<R extends Object>([R Function(T e)? transformer]) {
    return Sync(() {
      final okOrErr = value.transf<R>(transformer);
      if (okOrErr.isErr()) {
        throw okOrErr;
      }
      return okOrErr.unwrap();
    });
  }

  @override
  @pragma('vm:prefer-inline')
  Option<Ok<T>> ok() => value.ok();

  @override
  @pragma('vm:prefer-inline')
  Option<Err<T>> err() => value.err();

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
  Sync<Sync<T>> wrapSync() => Sync.value(Ok(this));

  @override
  @pragma('vm:prefer-inline')
  Async<Sync<T>> wrapAsync() => Async.value(Future.value(Ok(this)));
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// A [Monad] that represents a [Resolvable] that holds an asynchronous
/// [Result]. It's [value] is always a [Future].
final class Async<T extends Object> extends Resolvable<T> {
  @override
  // ignore: overridden_fields
  final Future<Result<T>> value;

  /// Creates an [Async] with a [Future] of a [Result].
  const Async.value(this.value) : super.value(value);

  /// Creates an [Async] by executing an asynchronous function [unsafe].
  factory Async(
    Future<T> Function() unsafe, {
    Err<T> Function(Object? error)? onError,
    void Function()? onFinalize,
  }) {
    return Async.value(() async {
      try {
        return Ok<T>(await unsafe());
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
  Async<T> asAsync() => this;

  @override
  @pragma('vm:prefer-inline')
  Some<Async<T>> asSome() => Some(this);

  @override
  @pragma('vm:prefer-inline')
  None<Async<T>> asNone() => const None();

  @override
  @pragma('vm:prefer-inline')
  Ok<Async<T>> asOk() => Ok(this);

  @override
  @pragma('vm:prefer-inline')
  bool isSync() => false;

  @override
  @pragma('vm:prefer-inline')
  bool isAsync() => true;

  @override
  @pragma('vm:prefer-inline')
  Async<T> ifSync(void Function(Sync<T> async) unsafe) => this;

  @override
  @pragma('vm:prefer-inline')
  Async<T> ifAsync(void Function(Async<T> async) unsafe) {
    try {
      unsafe(this);
      return this;
    } catch (error) {
      return Async.value(Future.value(Err(error)));
    }
  }

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
  Future<T> unwrap({int delta = 1}) => value.then((e) => e.unwrap(delta: delta));

  @override
  FutureOr<T> unwrapOr(T fallback) => value.then((e) => e.unwrapOr(fallback));

  @override
  @pragma('vm:prefer-inline')
  Async<R> map<R extends Object>(R Function(T value) unsafe) {
    return Async.value(value.then((e) => e.map(unsafe)));
  }

  @override
  Async<R> resultMap<R extends Object>(
    Result<R> Function(Result<T> value) mapper,
  ) {
    return Async(() async {
      final a = await value;
      if (a.isErr()) {
        throw a;
      }
      final b = mapper(a);
      if (b.isErr()) {
        throw b;
      }
      return b.unwrap();
    });
  }

  @override
  @pragma('vm:prefer-inline')
  Async<R> mapFutureOr<R extends Object>(FutureOr<R> Function(T value) unsafe) {
    return Async(() async => unsafe((await value).unwrap()));
  }

  @override
  @pragma('vm:prefer-inline')
  Resolvable<Object> fold(
    Resolvable<Object>? Function(Sync<T> sync) onSync,
    Resolvable<Object>? Function(Async<T> async) onAsync,
  ) {
    try {
      return onAsync(this) ?? this;
    } catch (error) {
      return Async.value(Future.value(Err(error)));
    }
  }

  @override
  @pragma('vm:prefer-inline')
  Async<Object> foldResult(
    Result<Object>? Function(Ok<T> ok) onOk,
    Result<Object>? Function(Err<T> err) onErr,
  ) {
    return this..resultMap((e) => e.fold(onOk, onErr));
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
    throw Err<T>('Called toSync() on Async<$T>.').addStackLevel();
  }

  @override
  @pragma('vm:prefer-inline')
  Async<T> toAsync() => this;

  @override
  @pragma('vm:prefer-inline')
  Future<T?> orNull() => value.then((e) => e.orNull());

  @override
  Async<R> transf<R extends Object>([R Function(T e)? transformer]) {
    return Async(() async {
      final okOrErr = (await value).transf<R>(transformer);
      if (okOrErr.isErr()) {
        throw okOrErr;
      }
      return okOrErr.unwrap();
    });
  }

  @override
  @pragma('vm:prefer-inline')
  Resolvable<R> syncOr<R extends Object>(Resolvable<R> other) => other;

  @override
  @pragma('vm:prefer-inline')
  Async<Object> asyncOr<R extends Object>(Resolvable<R> other) => this;

  @override
  @pragma('vm:prefer-inline')
  Future<Option<Ok<T>>> ok() => value.then((e) => e.ok());

  @override
  @pragma('vm:prefer-inline')
  Future<Option<Err<T>>> err() => value.then((e) => e.err());

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
  Sync<Async<T>> wrapSync() => Sync.value(Ok(this));

  @override
  @pragma('vm:prefer-inline')
  Async<Async<T>> wrapAsync() => Async.value(Future.value(Ok(this)));
}
