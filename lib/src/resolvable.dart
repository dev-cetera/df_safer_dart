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

import 'package:meta/meta.dart';

import '../df_safer_dart.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

sealed class Resolvable<T extends Object> {
  const Resolvable._();

  factory Resolvable.unsafe(FutureOr<T> Function() functionCanThrow) {
    if (functionCanThrow is Future<T> Function()) {
      return Async.unsafe(functionCanThrow);
    } else {
      return Sync.unsafe(functionCanThrow as T Function());
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
  T unwrapSyncValue() => unwrapSync().unwrapValue();

  @visibleForTesting
  @pragma('vm:prefer-inline')
  Future<T> unwrapAsyncValue() => unwrapAsync().unwrapValue();

  Resolvable<T> ifSync(void Function(Sync<T> sync) callback);

  Resolvable<T> ifAsync(void Function(Async<T> async) callback);

  Resolvable<R> map<R extends Object>(R Function(T value) mapper);

  Option<Resolvable<R>> fold<R extends Object>(
    Option<Resolvable<R>> Function(Result<T> value) onSync,
    Option<Resolvable<R>> Function(Future<Result<T>> value) onAsync,
  );

  Async<T> toAsync();
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

final class Sync<T extends Object> extends Resolvable<T> {
  @visibleForTesting
  final Result<T> value;

  const Sync(this.value) : super._();

  factory Sync.unsafe(T Function() functionCanThrow) {
    try {
      return Sync(Ok(functionCanThrow()));
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

  @visibleForTesting
  @pragma('vm:prefer-inline')
  // ignore: invalid_use_of_visible_for_testing_member
  T unwrapValue() => ok().unwrap().unwrap();

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
  Option<Resolvable<R>> fold<R extends Object>(
    Option<Resolvable<R>> Function(Result<T> value) onSync,
    Option<Resolvable<R>> Function(Future<Result<T>> value) onAsync,
  ) {
    return onSync(value);
  }

  @override
  @pragma('vm:prefer-inline')
  Sync<R> map<R extends Object>(R Function(T value) mapper) {
    return Sync(value.map((e) => mapper(e)));
  }

  @override
  @pragma('vm:prefer-inline')
  Async<T> toAsync() => Async(Future.value(value));
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

final class Async<T extends Object> extends Resolvable<T> {
  @visibleForTesting
  final Future<Result<T>> value;

  const Async(this.value) : super._();

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

  @visibleForTesting
  @pragma('vm:prefer-inline')
  // ignore: invalid_use_of_visible_for_testing_member
  Future<T> unwrapValue() => ok().then((e) => e.unwrap().unwrap());

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
  Option<Resolvable<R>> fold<R extends Object>(
    Option<Resolvable<R>> Function(Result<T> value) onSync,
    Option<Resolvable<R>> Function(Future<Result<T>> value) onAsync,
  ) {
    return onAsync(value);
  }

  @override
  @pragma('vm:prefer-inline')
  @override
  Async<R> map<R extends Object>(R Function(T value) mapper) {
    return Async(value.then((e) => e.map(mapper)));
  }

  @override
  @pragma('vm:prefer-inline')
  Async<T> toAsync() => this;
}
