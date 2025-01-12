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

import 'dart:async';

import '../df_safer_dart.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

sealed class Concur<T extends Object> {
  const Concur._();

  static Concur<T> tryCatch<T extends Object>(
    FutureOr<T> Function() functionCanThrow,
  ) {
    try {
      final test = functionCanThrow();
      if (test is! Future<T>) {
        return Sync(Ok(test));
      } else {
        return Async(() async {
          try {
            return Ok<T>(await test);
          } catch (e) {
            return Err<T>(e);
          }
        }());
      }
    } catch (e) {
      return Sync(Err<T>(e));
    }
  }

  bool get isSync;

  bool get isAsync;

  Result<Sync<T>> get sync;

  Result<Async<T>> get async;

  @pragma('vm:prefer-inline')
  Sync<T> uwSync() => sync.unwrap();

  @pragma('vm:prefer-inline')
  Async<T> uwAsync() => async.unwrap();

  @pragma('vm:prefer-inline')
  T uwSyncValue() => uwSync().uwValue();

  @pragma('vm:prefer-inline')
  Future<T> uwAsyncValue() => uwAsync().uwValue();

  Result<Concur<T>> ifSync(Result<void> Function(Result<T> value) fn);

  Result<Concur<T>> ifAsync(Result<void> Function(Future<Result<T>> future) fn);

  Concur<R> map<R extends Object>(Result<R> Function(Result<T> value) fn);

  Option<Concur<R>> fold<R extends Object>(
    Option<Concur<R>> Function(Result<T> value) onSync,
    Option<Concur<R>> Function(Future<Result<T>> value) onAsync,
  );
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

final class Sync<T extends Object> extends Concur<T> {
  final Result<T> result;

  @pragma('vm:prefer-inline')
  Ok<T> get ok => result.ok;

  @pragma('vm:prefer-inline')
  Err<T> get err => result.err;

  @pragma('vm:prefer-inline')
  T uwValue() => ok.unwrap();

  @pragma('vm:prefer-inline')
  const Sync(this.result) : super._();

  @override
  @pragma('vm:prefer-inline')
  bool get isSync => true;

  @override
  @pragma('vm:prefer-inline')
  bool get isAsync => false;

  @override
  @pragma('vm:prefer-inline')
  Result<Sync<T>> get sync => Ok(this);

  @override
  @pragma('vm:prefer-inline')
  Result<Async<T>> get async => const Err('Cannot get async from Sync.');

  @override
  @pragma('vm:prefer-inline')
  Result<Concur<T>> ifSync(Result<void> Function(Result<T> value) fn) {
    return fn(result).map((e) => this);
  }

  @override
  @pragma('vm:prefer-inline')
  Result<Concur<T>> ifAsync(Result<void> Function(Future<Result<T>> future) fn) => Ok(this);

  @override
  Option<Concur<R>> fold<R extends Object>(
    Option<Concur<R>> Function(Result<T> value) onSync,
    Option<Concur<R>> Function(Future<Result<T>> value) onAsync,
  ) {
    return onSync(result);
  }

  @override
  @pragma('vm:prefer-inline')
  Sync<R> map<R extends Object>(Result<R> Function(Result<T> value) fn) {
    return Sync(fn(result));
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

final class Async<T extends Object> extends Concur<T> {
  final Future<Result<T>> result;

  @pragma('vm:prefer-inline')
  Future<Ok<T>> get ok => result.then((e) => e.ok);

  @pragma('vm:prefer-inline')
  Future<Err<T>> get err => result.then((e) => e.err);

  @pragma('vm:prefer-inline')
  Future<T> uwValue() => ok.then((e) => e.unwrap());

  const Async(this.result) : super._();

  @override
  @pragma('vm:prefer-inline')
  bool get isSync => false;

  @override
  @pragma('vm:prefer-inline')
  bool get isAsync => true;

  @override
  @pragma('vm:prefer-inline')
  Result<Sync<T>> get sync => const Err('Cannot get sync from Async.');

  @override
  @pragma('vm:prefer-inline')
  Result<Async<T>> get async => Ok(this);

  @override
  @pragma('vm:prefer-inline')
  Result<Concur<T>> ifSync(Result<void> Function(Result<T> value) fn) => Ok(this);

  @override
  @pragma('vm:prefer-inline')
  Result<Concur<T>> ifAsync(Result<void> Function(Future<Result<T>> future) fn) {
    return fn(result).map((e) => this);
  }

  @override
  @pragma('vm:prefer-inline')
  Option<Concur<R>> fold<R extends Object>(
    Option<Concur<R>> Function(Result<T> value) onSync,
    Option<Concur<R>> Function(Future<Result<T>> value) onAsync,
  ) {
    return onAsync(result);
  }

  @override
  @pragma('vm:prefer-inline')
  @override
  Async<R> map<R extends Object>(Result<R> Function(Result<T> value) fn) {
    return Async(result.then((e) => fn(e)));
  }
}
