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

/// A [Outcome] that represents a [Resolvable] that holds an asynchronous [Result].
///
/// The contained [value] is always a [Future].
///
/// # IMPORTANT:
///
/// Await all Futures in the constructor [Async.new] to ensure errors are
/// properly caught and propagated.
final class Async<T extends Object> extends Resolvable<T>
    implements AsyncImpl<T> {
  /// Combines 2 [Async] outcomes into 1 containing a tuple of their values
  /// if all resolve to [Ok].
  ///
  /// If any resolve to [Err], applies [onErr] function to combine errors.
  ///
  /// See also: [combineAsync].
  static Async<(T1, T2)> combine2<T1 extends Object, T2 extends Object>(
    Async<T1> a1,
    Async<T2> a2, [
    @noFutures Err<(T1, T2)> Function(Result<T1>, Result<T2>)? onErr,
  ]) {
    final combined = combineAsync<Object>(
      [a1, a2],
      onErr: onErr == null
          ? null
          : (l) => onErr(l[0].transf<T1>(), l[1].transf<T2>()).transfErr(),
    );
    return combined.map((l) => (l[0] as T1, l[1] as T2));
  }

  /// Combines 3 [Async] outcomes into 1 containing a tuple of their values
  /// if all resolve to [Ok].
  ///
  /// If any resolve to [Err], applies [onErr] function to combine errors.
  ///
  /// See also: [combineAsync].
  static Async<(T1, T2, T3)>
      combine3<T1 extends Object, T2 extends Object, T3 extends Object>(
    Async<T1> a1,
    Async<T2> a2,
    Async<T3> a3, [
    @noFutures
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
  Future<Result<T>> get value {
    final raw = super.value;
    // `Async.new` always stores a `Future<Result<T>>` directly. Only
    // `Sync.toAsync()` (which stores a synchronous `Result<T>` in the base
    // field) needs the `Future.value(...)` wrap.
    if (raw is Future<Result<T>>) return raw;
    return Future<Result<T>>.value(raw as FutureOr<Result<T>>);
  }

  @unsafeOrError
  Async.result(super.value)
      : assert(isSubtype<T, Never>() || !isSubtype<T, Future<Object>>(),
            '$T must never be a Future.',),
        super.result();

  @unsafeOrError
  Async.ok(super.ok)
      : assert(isSubtype<T, Never>() || !isSubtype<T, Future<Object>>(),
            '$T must never be a Future.',),
        super.ok();

  @unsafeOrError
  Async.okValue(FutureOr<T> okValue)
      : assert(isSubtype<T, Never>() || !isSubtype<T, Future<Object>>(),
            '$T must never be a Future.',),
        super.ok(Future.value(okValue).then(Ok.new));

  @unsafeOrError
  Async.err(super.err)
      : assert(isSubtype<T, Never>() || !isSubtype<T, Future<Object>>(),
            '$T must never be a Future.',),
        super.err();

  @unsafeOrError
  Async.errValue(FutureOr<({Object error, int? statusCode})> error)
      : assert(isSubtype<T, Never>() || !isSubtype<T, Future<Object>>(),
            '$T must never be a Future.',),
        super.err(
          Future.value(error)
              .then((e) => Err(e.error, statusCode: e.statusCode)),
        );

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
    @noFutures TOnErrorCallback<T>? onError,
    @noFutures TVoidCallback? onFinalize,
  }) {
    assert(isSubtype<T, Never>() || !isSubtype<T, Future<Object>>(),
        '$T must never be a Future.',);
    return Async.result(() async {
      Result<T> result;
      try {
        result = Ok<T>(await mustAwaitAllFutures());
      } on Err catch (err) {
        result = err.transfErr<T>();
      } catch (error, stackTrace) {
        if (onError == null) {
          result = Err<T>(error, stackTrace: stackTrace);
        } else {
          try {
            result = onError(error, stackTrace);
          } on Err catch (err) {
            // `onError` itself can throw an `Err` — preserve its statusCode
            // and breadcrumbs rather than nesting it as another Err's value.
            result = err.transfErr<T>();
          } catch (error, stackTrace) {
            result = Err<T>(error, stackTrace: stackTrace);
          }
        }
      }
      // Run `onFinalize` separately so its throws are absorbed into `result`
      // instead of escaping the async block and leaving `Async.value` to
      // reject with an uncaught error. Following standard `try/finally`
      // semantics, a thrown finalize error overrides whatever `result` held.
      if (onFinalize != null) {
        try {
          onFinalize();
        } on Err catch (err) {
          result = err.transfErr<T>();
        } catch (error, stackTrace) {
          result = Err<T>(error, stackTrace: stackTrace);
        }
      }
      return result;
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
    @noFutures void Function(Async<T> self, Sync<T> async) noFutures,
  ) {
    return this;
  }

  @override
  @pragma('vm:prefer-inline')
  Async<T> ifAsync(
    @noFutures void Function(Async<T> self, Async<T> async) noFutures,
  ) {
    // Callback is `void` + `@noFutures`, so we run it inline and absorb any
    // throw onto the returned `Async`. `on Err catch` preserves a user-thrown
    // `Err` verbatim — wrapping it would lose statusCode/breadcrumbs.
    try {
      noFutures(this, this);
      return this;
    } on Err catch (err) {
      return Async.err(err.transfErr<T>());
    } catch (error, stackTrace) {
      return Async.err(Err<T>(error, stackTrace: stackTrace));
    }
  }

  @override
  @visibleForTesting
  @pragma('vm:prefer-inline')
  Async<T> mapSync(@noFutures Sync<T> Function(Sync<T> sync) noFutures) {
    return this;
  }

  @override
  @visibleForTesting
  @pragma('vm:prefer-inline')
  Async<T> mapAsync(@noFutures Async<T> Function(Async<T> async) noFutures) {
    try {
      return noFutures(this);
    } on Err catch (err) {
      return Async.err(err.transfErr<T>());
    } catch (error, stackTrace) {
      return Async.err(Err<T>(error, stackTrace: stackTrace));
    }
  }

  @override
  @pragma('vm:prefer-inline')
  Async<R> flatMap<R extends Object>(
    @noFutures Resolvable<R> Function(T value) noFutures,
  ) {
    return Async<R>(() async {
      final result = await value;
      switch (result) {
        case Ok(value: final v):
          return await noFutures(v).unwrap();
        case final Err<T> err:
          throw err;
      }
    });
  }

  @override
  Resolvable<T> ifOk(
    @noFutures void Function(Async<T> self, Ok<T> ok) noFutures,
  ) {
    return Async<T>(() async {
      final awaitedValue = await value;
      if (awaitedValue case Ok<T> ok) {
        noFutures(this, ok);
        return ok.value;
      }
      throw awaitedValue as Err<T>;
    });
  }

  @override
  Resolvable<T> ifErr(
    @noFutures void Function(Async<T> self, Err<T> err) noFutures,
  ) {
    return Async<T>(() async {
      final awaitedValue = await value;
      if (awaitedValue case Err<T> err) {
        noFutures(this, err);
        throw err;
      }
      return (awaitedValue as Ok<T>).value;
    });
  }

  @override
  Async<R> resultMap<R extends Object>(
    @noFutures Result<R> Function(Result<T> value) noFutures,
  ) {
    return Async(() async {
      final a = await value;
      switch (a) {
        case Ok():
          final b = noFutures(a);
          switch (b) {
            case Ok(value: final okValue):
              return okValue;
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
    @noFutures Resolvable<Object>? Function(Sync<T> sync) onSync,
    @noFutures Resolvable<Object>? Function(Async<T> async) onAsync,
  ) {
    try {
      return onAsync(this) ?? this;
    } on Err catch (err) {
      // Preserve a user-thrown Err verbatim — statusCode/breadcrumbs matter.
      return Async.err(err.transfErr<Object>());
    } catch (error, stackTrace) {
      return Async.err(Err(error, stackTrace: stackTrace));
    }
  }

  @override
  @pragma('vm:prefer-inline')
  Async<Object> foldResult(
    @noFutures Result<Object>? Function(Ok<T> ok) onOk,
    @noFutures Result<Object>? Function(Err<T> err) onErr,
  ) {
    return resultMap((e) => e.fold(onOk, onErr));
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
        case Ok(value: final okValue):
          return okValue;
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

  /// Prefer using [then] for [Async].
  @override
  @pragma('vm:prefer-inline')
  Async<R> map<R extends Object>(@noFutures R Function(T value) noFutures) {
    return then(noFutures);
  }

  @override
  @pragma('vm:prefer-inline')
  Async<R> then<R extends Object>(@noFutures R Function(T value) noFutures) {
    // Route through `Async(() async {...})` so a synchronous throw from
    // `noFutures` is captured as an Err on the chain instead of escaping to
    // whoever awaits the resulting Async.
    return Async<R>(() async {
      final result = await value;
      switch (result) {
        case Ok(value: final v):
          return noFutures(v);
        case final Err err:
          throw err;
      }
    });
  }

  @override
  @pragma('vm:prefer-inline')
  Async<R> whenComplete<R extends Object>(
    @noFutures Resolvable<R> Function(Sync<T> resolved) noFutures,
  ) {
    return Async<R>(() async {
      final result = await value;
      result.unwrap(); // surface any Err as a throw caught by `Async()` below.
      return await noFutures(Sync<T>.result(result)).unwrap();
    });
  }

  @override
  Async<R> transf<R extends Object>([@noFutures R Function(T e)? noFutures]) {
    return Async(() async {
      final okOrErr = (await value).transf<R>(noFutures);
      switch (okOrErr) {
        case Ok(value: final okValue):
          return okValue;
        case Err():
          throw okOrErr;
      }
    });
  }

  @override
  @pragma('vm:prefer-inline')
  void end() {
    // `.end()` is the "discard this Outcome" marker — deliberately detach the
    // future. Callers who need to await settlement should use `.value`. The
    // outer `try` is belt-and-braces: `value.then(...).catchError(...)` is
    // not expected to throw synchronously, but the package contract is that
    // `.end()` *never* throws — so we absorb anything the getter or future
    // chain could conceivably surface (e.g., a future-chain failure on a
    // weird host platform).
    try {
      unawaited(value.then((e) => e.end()).catchError((_) {}));
    } catch (_) {
      // Swallow — `.end()` must never escape.
    }
  }
}
