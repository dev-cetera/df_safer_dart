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

  factory Resolvable.resolve(FutureOr<T> Function() functionCanThrow) {
    if (functionCanThrow is Future<T> Function()) {
      return Async.resolve(functionCanThrow);
    } else {
      return Sync.resolve(functionCanThrow as T Function());
    }
  }

  bool get isSync;

  bool get isAsync;

  @visibleForTesting
  Result<Sync<T>> get sync;

  @visibleForTesting
  Result<Async<T>> get async;

  @visibleForTesting
  @pragma('vm:prefer-inline')
  // ignore: invalid_use_of_visible_for_testing_member
  Sync<T> unwrapSync() => sync.unwrap();

  @visibleForTesting
  @pragma('vm:prefer-inline')
  // ignore: invalid_use_of_visible_for_testing_member
  Async<T> unwrapAsync() => async.unwrap();

  @visibleForTesting
  @pragma('vm:prefer-inline')
  T unwrapSyncValue() => unwrapSync().unwrapValue();

  @visibleForTesting
  @pragma('vm:prefer-inline')
  Future<T> unwrapAsyncValue() => unwrapAsync().unwrapValue();

  Result<Resolvable<T>> ifSync(Result<void> Function(Result<T> value) fn);

  Result<Resolvable<T>> ifAsync(Result<void> Function(Future<Result<T>> future) fn);

  Resolvable<R> map<R extends Object>(Result<R> Function(Result<T> value) fn);

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

  factory Sync.resolve(T Function() functionCanThrow) {
    try {
      return Sync(Ok(functionCanThrow()));
    } catch (e) {
      return Sync(Err<T>(e));
    }
  }

  @protected
  @pragma('vm:prefer-inline')
  // ignore: invalid_use_of_visible_for_testing_member
  Ok<T> get ok => value.ok;

  @protected
  @pragma('vm:prefer-inline')
  // ignore: invalid_use_of_visible_for_testing_member
  Err<T> get err => value.err;

  @visibleForTesting
  @pragma('vm:prefer-inline')
  T unwrapValue() => ok.unwrap();

  @override
  @pragma('vm:prefer-inline')
  bool get isSync => true;

  @override
  @pragma('vm:prefer-inline')
  bool get isAsync => false;

  @override
  @pragma('vm:prefer-inline')
  Result<Sync<T>> get sync => Ok(this);

  @protected
  @override
  @pragma('vm:prefer-inline')
  Result<Async<T>> get async => const Err('Cannot get async from Sync.');

  @override
  @pragma('vm:prefer-inline')
  Result<Resolvable<T>> ifSync(Result<void> Function(Result<T> value) fn) {
    return fn(value).map((e) => this);
  }

  @override
  @pragma('vm:prefer-inline')
  Result<Resolvable<T>> ifAsync(Result<void> Function(Future<Result<T>> future) fn) => Ok(this);

  @override
  Option<Resolvable<R>> fold<R extends Object>(
    Option<Resolvable<R>> Function(Result<T> value) onSync,
    Option<Resolvable<R>> Function(Future<Result<T>> value) onAsync,
  ) {
    return onSync(value);
  }

  @override
  @pragma('vm:prefer-inline')
  Sync<R> map<R extends Object>(Result<R> Function(Result<T> value) fn) {
    return Sync(fn(value));
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

  factory Async.resolve(Future<T> Function() functionCanThrow) {
    return Async(() async {
      try {
        return Ok<T>(await functionCanThrow());
      } on Err catch (e) {
        return Err<T>(e.value);
      } catch (e) {
        return Err<T>(e);
      }
    }());
  }

  @visibleForTesting
  @pragma('vm:prefer-inline')
  // ignore: invalid_use_of_visible_for_testing_member
  Future<Ok<T>> get ok => value.then((e) => e.ok);

  @visibleForTesting
  @pragma('vm:prefer-inline')
  // ignore: invalid_use_of_visible_for_testing_member
  Future<Err<T>> get err => value.then((e) => e.err);

  @visibleForTesting
  @pragma('vm:prefer-inline')
  Future<T> unwrapValue() => ok.then((e) => e.unwrap());

  @override
  @pragma('vm:prefer-inline')
  bool get isSync => false;

  @override
  @pragma('vm:prefer-inline')
  bool get isAsync => true;

  @protected
  @override
  @pragma('vm:prefer-inline')
  Result<Sync<T>> get sync => const Err('Cannot get sync from Async.');

  @override
  @pragma('vm:prefer-inline')
  Result<Async<T>> get async => Ok(this);

  @override
  @pragma('vm:prefer-inline')
  Result<Resolvable<T>> ifSync(Result<void> Function(Result<T> value) fn) => Ok(this);

  @override
  @pragma('vm:prefer-inline')
  Result<Resolvable<T>> ifAsync(Result<void> Function(Future<Result<T>> future) fn) {
    return fn(value).map((e) => this);
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
  Async<R> map<R extends Object>(Result<R> Function(Result<T> value) fn) {
    return Async(value.then((e) => fn(e)));
  }

  @override
  @pragma('vm:prefer-inline')
  Async<T> toAsync() => this;
}
