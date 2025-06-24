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

import '/_common.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

extension $ToResolvableExtension<T extends Object> on FutureOr<T> {
  @pragma('vm:prefer-inline')
  Resolvable<T> toResolvable({
    @noFuturesAllowed TOnErrorCallback<T>? onError,
    @noFuturesAllowed TVoidCallback? onFinalize,
  }) {
    return Resolvable(() => this, onError: onError, onFinalize: onFinalize);
  }
}

extension $ToAsyncExtension<T extends Object> on Future<T> {
  @pragma('vm:prefer-inline')
  Async<T> toAsync({
    @noFuturesAllowed TOnErrorCallback<T>? onError,
    @noFuturesAllowed TVoidCallback? onFinalize,
  }) {
    assert(
      !isSubtype<T, Future<Object>>(),
      'Do not call toAsync on nested futures: $T.',
    );
    return Async(() => this, onError: onError, onFinalize: onFinalize);
  }
}

extension $ToSync<T extends Object> on T {
  @pragma('vm:prefer-inline')
  Sync<T> toSync({
    @noFuturesAllowed TOnErrorCallback<T>? onError,
    @noFuturesAllowed TVoidCallback? onFinalize,
  }) {
    assert(
      !isSubtype<T, Future<Object>>(),
      'Do not call toSync on futures: $T.',
    );
    return Sync(() => this, onError: onError, onFinalize: onFinalize);
  }
}

extension $SyncOptionExtension<T extends Object> on Sync<Option<T>> {
  @unsafeOrError
  @pragma('vm:prefer-inline')
  T unwrapSync() => unwrap().unwrap();
}

extension $AsyncOptionExtension<T extends Object> on Async<Option<T>> {
  @unsafeOrError
  @pragma('vm:prefer-inline')
  Future<T> unwrapAsync() => unwrap().then((e) => e.unwrap());
}

extension $ResolvableOptionExtension<T extends Object> on Resolvable<Option<T>> {
  @unsafeOrError
  @pragma('vm:prefer-inline')
  T unwrapSync() => sync().unwrap().unwrapSync();

  @unsafeOrError
  @pragma('vm:prefer-inline')
  Future<T> unwrapAsync() => async().unwrap().unwrapAsync();
}
