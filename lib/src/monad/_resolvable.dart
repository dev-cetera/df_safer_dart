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

  factory Resolvable.unsafe(FutureOr<T> Function() unsafe) {
    try {
      final result = unsafe();
      if (result is Future<T>) {
        return Async.unsafe(() => result);
      } else {
        return Sync(Ok(result));
      }
    } on Err catch (e) {
      return Sync(e.transErr<T>());
    } catch (error) {
      return Sync(Err<T>(debugPath: ['Sync', 'Sync.unsafe'], error: error));
    }
  }

  bool isSync();

  bool isAsync();

  Result<Sync<T>> sync();

  Result<Async<T>> async();

  FutureOr<T> unwrap();

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

  Sync<T> toSync();

  Async<T> toAsync();

  Future<T?> orNull();

  Resolvable<R> trans<R extends Object>([R Function(T e)? transformer]);

  @override
  List<Object?> get props => [this.value];

  @override
  bool? get stringify => false;
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

final class Sync<T extends Object> extends Resolvable<T> {
  @override
  // ignore: overridden_fields
  final Result<T> value;

  const Sync(this.value) : super._(value);

  factory Sync.unsafe(T Function() unsafe) {
    try {
      return Sync(Ok(unsafe()));
    } on Err catch (e) {
      return Sync(e.transErr<T>());
    } catch (error) {
      return Sync(Err<T>(debugPath: ['Sync', 'Sync.unsafe'], error: error));
    }
  }

  @override
  @pragma('vm:prefer-inline')
  T unwrap() => value.unwrap();

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
    return Err(debugPath: ['Sync', 'sync'], error: 'Called async() on Sync.');
  }

  @protected
  @override
  @pragma('vm:prefer-inline')
  Sync<T> ifSync(void Function(Sync<T> sync) unsafe) {
    try {
      unsafe(this);
      return this;
    } catch (error) {
      return Sync(Err(debugPath: ['Sync', 'ifSync'], error: error));
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
    } catch (error) {
      return Sync(Err(debugPath: ['Sync', 'fold'], error: error));
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

  @override
  Sync<R> trans<R extends Object>([R Function(T e)? transformer]) {
    return Sync.unsafe(() {
      final okOrErr = (sync().unwrap().value).trans<R>(transformer);
      if (okOrErr.isErr()) {
        throw okOrErr;
      }
      return okOrErr.unwrap();
    });
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

final class SyncOk<T extends Object> extends Sync<T> {
  SyncOk(T value) : super(Ok(value));
}

final class SyncErr<T extends Object> extends Sync<T> {
  SyncErr({required List<Object> debugPath, required Object error})
      : super(Err<T>(debugPath: debugPath, error: error));
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

final class Async<T extends Object> extends Resolvable<T> {
  @override
  // ignore: overridden_fields
  final Future<Result<T>> value;

  const Async(this.value) : super._(value);

  factory Async.unsafe(Future<T> Function() unsafe) {
    return Async(() async {
      try {
        return Ok<T>(await unsafe());
      } on Err catch (e) {
        return e.transErr<T>();
      } catch (error) {
        return Err<T>(debugPath: ['Async', 'Async.unsafe'], error: error);
      }
    }());
  }

  @override
  @pragma('vm:prefer-inline')
  Future<T> unwrap() => value.then((e) => e.unwrap());

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
    return Err(debugPath: ['Async', 'sync'], error: 'Called sync() on Async.');
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
    } catch (error) {
      return Async(
        Future.value(Err(debugPath: ['Async', 'ifAsync'], error: error)),
      );
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
    } catch (error) {
      return Async(
        Future.value(Err(debugPath: ['Async', 'fold'], error: error)),
      );
    }
  }

  @override
  @pragma('vm:prefer-inline')
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

  @protected
  @override
  @pragma('vm:prefer-inline')
  Sync<T> toSync() {
    throw Err(
      debugPath: ['Async', 'toSync'],
      error: 'Called toSync() on Async.',
    );
  }

  @protected
  @override
  @pragma('vm:prefer-inline')
  Async<T> toAsync() => this;

  @override
  @pragma('vm:prefer-inline')
  Future<T?> orNull() => value.then((e) => e.orNull());

  @override
  Async<R> trans<R extends Object>([R Function(T e)? transformer]) {
    return Async.unsafe(() async {
      final okOrErr = (await async().unwrap().value).trans<R>(transformer);
      if (okOrErr.isErr()) {
        throw okOrErr;
      }
      return okOrErr.unwrap();
    });
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

final class AsyncOk<T extends Object> extends Async<T> {
  AsyncOk(Future<T> value) : super(value.then((e) => Ok(e)));
}

final class AsyncErr<T extends Object> extends Async<T> {
  AsyncErr({required List<Object> debugPath, required Object error})
      : super(Future.value(Err(debugPath: debugPath, error: error)));
}
