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
  @visibleForTesting
  final FutureOr<Result<T>> value;

  const Resolvable._(this.value);

  factory Resolvable.unsafe(FutureOr<T> Function() unsafe) {
    try {
      final result = unsafe();
      if (result is Future<T>) {
        return Async.unsafe(() => result);
      } else {
        return Sync(Ok(result));
      }
    } on Err catch (e) {
      return Sync(e.castErr<T>());
    } catch (e) {
      return Sync(Err<T>(stack: ['Sync', 'Sync.unsafe'], error: e));
    }
  }

  bool isSync();

  bool isAsync();

  Result<Sync<T>> sync();

  Result<Async<T>> async();

  FutureOr<T> unwrap() {
    if (isSync()) {
      return unwrapSync().value.unwrap();
    } else {
      return unwrapAsync().value.then((e) => e.unwrap());
    }
  }

  @pragma('vm:prefer-inline')
  Sync<T> unwrapSync() => sync().unwrap();

  @pragma('vm:prefer-inline')
  Async<T> unwrapAsync() => async().unwrap();

  @pragma('vm:prefer-inline')
  Resolvable<T> resolvable() => this;

  Resolvable<T> ifSync(void Function(Sync<T> sync) unsafe);

  Resolvable<T> ifAsync(void Function(Async<T> async) unsafe);

  Resolvable<R> map<R extends Object>(R Function(T value) unsafe);

  Resolvable<R> flatMap<R extends Object>(
    Result<R> Function(Result<T> value) mapper,
  );

  Resolvable<R> mapFutureOr<R extends Object>(
    FutureOr<R> Function(T value) unsafe,
  );

  Resolvable<Object> fold(
    Resolvable<Object>? Function(Sync<T> sync) onSync,
    Resolvable<Object>? Function(Async<T> async) onAsync,
  );

  FutureOr<R> when<R extends Object>({
    required R Function(T value) onOkUnsafe,
    required R Function(Err<T> err) onErrUnsafe,
  });

  FutureOr<Sync<T>> toSync();

  Async<T> toAsync();

  @visibleForTesting
  Future<T?> orNull();

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
  @visibleForTesting
  @override
  // ignore: overridden_fields
  final Result<T> value;

  const Sync(this.value) : super._(value);

  factory Sync.unsafe(T Function() unsafe) {
    try {
      return Sync(Ok(unsafe()));
    } on Err catch (e) {
      return Sync(e.castErr<T>());
    } catch (e) {
      return Sync(Err<T>(stack: ['Sync', 'Sync.unsafe'], error: e));
    }
  }

  @override
  @pragma('vm:prefer-inline')
  T unwrap() => unwrapSync().value.unwrap();

  @protected
  @pragma('vm:prefer-inline')
  Result<T> ok() => value.ok();

  @protected
  @pragma('vm:prefer-inline')
  Err<T> err() => value.err();

  @protected
  @override
  @pragma('vm:prefer-inline')
  bool isSync() => true;

  @protected
  @override
  @pragma('vm:prefer-inline')
  bool isAsync() => false;

  @protected
  @override
  @pragma('vm:prefer-inline')
  Ok<Sync<T>> sync() => Ok(this);

  @protected
  @override
  @pragma('vm:prefer-inline')
  Err<Async<T>> async() {
    return const Err(stack: ['Sync', 'sync'], error: 'Called async() on Sync.');
  }

  @protected
  @override
  @pragma('vm:prefer-inline')
  Sync<T> ifSync(void Function(Sync<T> sync) unsafe) {
    try {
      unsafe(this);
      return this;
    } catch (e) {
      return Sync(Err(stack: ['Sync', 'ifSync'], error: e));
    }
  }

  @protected
  @override
  @pragma('vm:prefer-inline')
  Sync<T> ifAsync(void Function(Async<T> async) unsafe) => this;

  @override
  Resolvable<Object> fold(
    Resolvable<Object>? Function(Sync<T> sync) onSync,
    Resolvable<Object>? Function(Async<T> async) onAsync,
  ) {
    try {
      return onSync(this) ?? this;
    } catch (e) {
      return Sync(Err(stack: ['Sync', 'fold'], error: e));
    }
  }

  @override
  @pragma('vm:prefer-inline')
  Sync<R> map<R extends Object>(R Function(T value) unsafe) {
    return Sync.unsafe(() => value.map((e) => unsafe(e)).unwrap());
  }

  @override
  @pragma('vm:prefer-inline')
  R when<R extends Object>({
    required R Function(T value) onOkUnsafe,
    required R Function(Err<T> err) onErrUnsafe,
  }) {
    return value.when(onOkUnsafe: onOkUnsafe, onErrUnsafe: onErrUnsafe);
  }

  @override
  @pragma('vm:prefer-inline')
  Sync<R> flatMap<R extends Object>(
    Result<R> Function(Result<T> value) mapper,
  ) {
    return Sync(mapper(value));
  }

  @override
  @pragma('vm:prefer-inline')
  Resolvable<R> mapFutureOr<R extends Object>(
    FutureOr<R> Function(T value) unsafe,
  ) {
    return Resolvable.unsafe(() => unsafe(value.unwrap()));
  }

  @override
  @pragma('vm:prefer-inline')
  Sync<T> toSync() => this;

  @override
  @pragma('vm:prefer-inline')
  Async<T> toAsync() => Async(Future.value(value));

  @override
  @pragma('vm:prefer-inline')
  Future<T?> orNull() async => value.orNull();
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

final class SyncOk<T extends Object> extends Sync<T> {
  SyncOk(T value) : super(Ok(value));
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

final class Async<T extends Object> extends Resolvable<T> {
  @visibleForTesting
  @override
  // ignore: overridden_fields
  final Future<Result<T>> value;

  const Async(this.value) : super._(value);

  factory Async.unsafe(Future<T> Function() unsafe) {
    return Async(() async {
      try {
        return Ok<T>(await unsafe());
      } on Err catch (e) {
        return e.castErr<T>();
      } catch (e) {
        return Err<T>(stack: ['Async', 'Async.unsafe'], error: e);
      }
    }());
  }

  @override
  @pragma('vm:prefer-inline')
  Future<T> unwrap() => unwrapAsync().unwrap();

  @visibleForTesting
  @pragma('vm:prefer-inline')
  Future<Result<T>> ok() => value.then((e) => e.ok());

  @visibleForTesting
  @pragma('vm:prefer-inline')
  Future<Err<T>> err() => value.then((e) => e.err());

  @protected
  @override
  @pragma('vm:prefer-inline')
  bool isSync() => false;

  @protected
  @override
  @pragma('vm:prefer-inline')
  bool isAsync() => true;

  @protected
  @override
  @pragma('vm:prefer-inline')
  Err<Sync<T>> sync() {
    return const Err(
      stack: ['Async', 'sync'],
      error: 'Called sync() on Async.',
    );
  }

  @protected
  @override
  @pragma('vm:prefer-inline')
  Ok<Async<T>> async() => Ok(this);

  @protected
  @override
  @pragma('vm:prefer-inline')
  Async<T> ifSync(void Function(Sync<T> async) unsafe) => this;

  @protected
  @override
  @pragma('vm:prefer-inline')
  Async<T> ifAsync(void Function(Async<T> async) unsafe) {
    try {
      unsafe(this);
      return this;
    } catch (e) {
      return Async(Future.value(Err(stack: ['Async', 'ifAsync'], error: e)));
    }
  }

  @override
  @pragma('vm:prefer-inline')
  Resolvable<Object> fold(
    Resolvable<Object>? Function(Sync<T> sync) onSync,
    Resolvable<Object>? Function(Async<T> async) onAsync,
  ) {
    try {
      return onAsync(this) ?? this;
    } catch (e) {
      return Async(Future.value(Err(stack: ['Async', 'fold'], error: e)));
    }
  }

  @override
  @pragma('vm:prefer-inline')
  @override
  Async<R> map<R extends Object>(R Function(T value) unsafe) {
    return Async(value.then((e) => e.map(unsafe)));
  }

  @override
  @pragma('vm:prefer-inline')
  Future<R> when<R extends Object>({
    required R Function(T value) onOkUnsafe,
    required R Function(Err<T> err) onErrUnsafe,
  }) {
    return value.then(
      (e) => e.when(onOkUnsafe: onOkUnsafe, onErrUnsafe: onErrUnsafe),
    );
  }

  @override
  Async<R> flatMap<R extends Object>(
    Result<R> Function(Result<T> value) mapper,
  ) {
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
  Async<R> mapFutureOr<R extends Object>(FutureOr<R> Function(T value) unsafe) {
    return Async.unsafe(() async => unsafe((await value).unwrap()));
  }

  @override
  Future<Sync<T>> toSync() async {
    try {
      final resolved = await value;
      return Sync(resolved);
    } catch (e) {
      return Sync(Err(stack: ['Async', 'toSync'], error: e));
    }
  }

  @protected
  @override
  @pragma('vm:prefer-inline')
  Async<T> toAsync() => this;

  @override
  @pragma('vm:prefer-inline')
  Future<T?> orNull() => value.then((e) => e.orNull());
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

final class AsyncOk<T extends Object> extends Async<T> {
  AsyncOk(Future<T> value) : super(value.then((e) => Ok(e)));
}
