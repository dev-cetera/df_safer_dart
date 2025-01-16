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

sealed class Resolvable<T extends Object> extends Monad<T> {
  final FutureOr<Result<T>> value;
  const Resolvable._(this.value);

  factory Resolvable.unsafe(FutureOr<T> Function() functionCanThrow) {
    try {
      final result = functionCanThrow();
      if (result is Future<T>) {
        return Async.unsafe(() => result);
      } else {
        return Sync(Ok(result));
      }
    } on Err catch (e) {
      return Sync(e.castErr<T>());
    } catch (e) {
      return Sync(
        Err<T>(
          stack: [Sync<T>, Sync.unsafe],
          error: e,
        ),
      );
    }
  }

  bool isSync();

  bool isAsync();

  @visibleForTesting
  Result<Sync<T>> sync();

  @visibleForTesting
  Result<Async<T>> async();

  @visibleForTesting
  @pragma('vm:prefer-inline')
  // ignore: invalid_use_of_visible_for_testing_member
  Sync<T> unwrapSync() => sync().unwrap();

  @visibleForTesting
  @pragma('vm:prefer-inline')
  // ignore: invalid_use_of_visible_for_testing_member
  Async<T> unwrapAsync() => async().unwrap();

  @visibleForTesting
  @pragma('vm:prefer-inline')
  T unwrapSyncValue() => unwrapSync().value.unwrap();

  @visibleForTesting
  @pragma('vm:prefer-inline')
  Future<T> unwrapAsyncValue() => unwrapAsync().value.then((e) => e.unwrap());

  Resolvable<T> ifSync(void Function(Sync<T> sync) callback);

  Resolvable<T> ifAsync(void Function(Async<T> async) callback);

  Resolvable<R> map<R extends Object>(R Function(T value) mapper);

  Resolvable<R> mapB<R extends Object>(Result<R> Function(Result<T> value) mapper);

  Resolvable<R> mapC<R extends Object>(FutureOr<R> Function(T value) mapper);

  ResolvableOption<R> fold<R extends Object>(
    ResolvableOption<R> Function(Sync<T> sync) onSync,
    ResolvableOption<R> Function(Async<T> async) onAsync,
  );

  Async<T> toAsync();

  Resolvable<R> cast<R extends Object>() {
    if (isSync()) {
      return Sync.unsafe(() {
        final okOrErr = (sync().unwrap().value).cast<R>();
        if (okOrErr.isErr()) {
          throw okOrErr;
        }
        return okOrErr.unwrap();
      });
    } else {
      return Async.unsafe(() async {
        final okOrErr = (await async().unwrap().value).cast<R>();
        if (okOrErr.isErr()) {
          throw okOrErr;
        }
        return okOrErr.unwrap();
      });
    }
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

final class Sync<T extends Object> extends Resolvable<T> {
  @override
  // ignore: overridden_fields
  final Result<T> value;

  const Sync(this.value) : super._(value);

  factory Sync.unsafe(T Function() functionCanThrow) {
    try {
      return Sync(Ok(functionCanThrow()));
    } on Err catch (e) {
      return Sync(e.castErr<T>());
    } catch (e) {
      return Sync(
        Err<T>(
          stack: [Sync<T>, Sync.unsafe],
          error: e,
        ),
      );
    }
  }

  @protected
  @pragma('vm:prefer-inline')
  // ignore: invalid_use_of_visible_for_testing_member
  Option<Ok<T>> ok() => value.ok();

  @protected
  @pragma('vm:prefer-inline')
  // ignore: invalid_use_of_visible_for_testing_member
  Option<Err<T>> err() => value.err();

  @override
  @pragma('vm:prefer-inline')
  bool isSync() => true;

  @override
  @pragma('vm:prefer-inline')
  bool isAsync() => false;

  @override
  @pragma('vm:prefer-inline')
  Result<Sync<T>> sync() => Ok(this);

  @protected
  @override
  @pragma('vm:prefer-inline')
  Result<Async<T>> async() {
    return Err(
      stack: [Sync<T>, sync],
      error: 'Cannot get Async from Sync.',
    );
  }

  @protected
  @override
  @pragma('vm:prefer-inline')
  Sync<T> ifSync(void Function(Sync<T> sync) callback) {
    callback(this);
    return this;
  }

  @protected
  @override
  @pragma('vm:prefer-inline')
  Sync<T> ifAsync(void Function(Async<T> async) callback) => this;

  @override
  ResolvableOption<R> fold<R extends Object>(
    ResolvableOption<R> Function(Sync<T> sync) onSync,
    ResolvableOption<R> Function(Async<T> async) onAsync,
  ) {
    try {
      return onSync(this);
    } catch (e) {
      return SyncSome(
        Err(
          stack: [Sync<T>, fold],
          error: e,
        ),
      );
    }
  }

  @override
  @pragma('vm:prefer-inline')
  Sync<R> map<R extends Object>(R Function(T value) mapper) {
    return Sync(value.map((e) => mapper(e)));
  }

  @override
  @pragma('vm:prefer-inline')
  Sync<R> mapB<R extends Object>(Result<R> Function(Result<T> value) mapper) {
    return Sync(mapper(value));
  }

  @override
  @pragma('vm:prefer-inline')
  Resolvable<R> mapC<R extends Object>(FutureOr<R> Function(T value) mapper) {
    return Resolvable.unsafe(() => mapper(value.unwrap()));
  }

  @override
  @pragma('vm:prefer-inline')
  Async<T> toAsync() => Async(Future.value(value));
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

final class Async<T extends Object> extends Resolvable<T> {
  @override
  // ignore: overridden_fields
  final Future<Result<T>> value;

  const Async(this.value) : super._(value);

  factory Async.unsafe(Future<T> Function() functionCanThrow) {
    return Async(() async {
      try {
        return Ok<T>(await functionCanThrow());
      } on Err catch (e) {
        return e.castErr<T>();
      } catch (e) {
        return Err<T>(
          stack: [Async<T>, Async.unsafe],
          error: e,
        );
      }
    }());
  }

  @visibleForTesting
  @pragma('vm:prefer-inline')
  // ignore: invalid_use_of_visible_for_testing_member
  Future<Option<Ok<T>>> ok() => value.then((e) => e.ok());

  @visibleForTesting
  @pragma('vm:prefer-inline')
  // ignore: invalid_use_of_visible_for_testing_member
  Future<Option<Err<T>>> err() => value.then((e) => e.err());

  @override
  @pragma('vm:prefer-inline')
  bool isSync() => false;

  @override
  @pragma('vm:prefer-inline')
  bool isAsync() => true;

  @protected
  @override
  @pragma('vm:prefer-inline')
  Result<Sync<T>> sync() {
    return Err(
      stack: [Async<T>, sync],
      error: 'Cannot get Sync from Async.',
    );
  }

  @override
  @pragma('vm:prefer-inline')
  Result<Async<T>> async() => Ok(this);

  @protected
  @override
  @pragma('vm:prefer-inline')
  Async<T> ifSync(void Function(Sync<T> async) callback) => this;

  @protected
  @override
  @pragma('vm:prefer-inline')
  Async<T> ifAsync(void Function(Async<T> async) callback) {
    callback(this);
    return this;
  }

  @override
  @pragma('vm:prefer-inline')
  ResolvableOption<R> fold<R extends Object>(
    ResolvableOption<R> Function(Sync<T> sync) onSync,
    ResolvableOption<R> Function(Async<T> async) onAsync,
  ) {
    try {
      return onAsync(this);
    } catch (e) {
      return SyncSome(
        Err(
          stack: [Async<T>, fold],
          error: e,
        ),
      );
    }
  }

  @override
  @pragma('vm:prefer-inline')
  @override
  Async<R> map<R extends Object>(R Function(T value) mapper) {
    return Async(value.then((e) => e.map(mapper)));
  }

  @override
  Async<R> mapB<R extends Object>(Result<R> Function(Result<T> value) mapper) {
    return Async.unsafe(() async {
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
  Async<R> mapC<R extends Object>(FutureOr<R> Function(T value) mapper) {
    return Async.unsafe(() async => mapper((await value).unwrap()));
  }

  @override
  @pragma('vm:prefer-inline')
  Async<T> toAsync() => this;
}
