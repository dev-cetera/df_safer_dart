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

import '../monads/monad.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

extension ToResolvableExtension<T extends Object> on FutureOr<T> {
  @pragma('vm:prefer-inline')
  Resolvable<T> toResolvable({
    Err<T> Function(Object?)? onError,
    void Function()? onFinalize,
  }) {
    return Resolvable(
      () => this,
      onError: onError,
      onFinalize: onFinalize,
    );
  }
}

extension ToAsyncExtension<T extends Object> on Future<T> {
  @pragma('vm:prefer-inline')
  Async<T> toAsync({
    Err<T> Function(Object?)? onError,
    void Function()? onFinalize,
  }) {
    assert(
      !_isSubtype<T, Future<Object>>(),
      'Do not call toAsync on nested futures: $T.',
    );
    return Async(
      () => this,
      onError: onError,
      onFinalize: onFinalize,
    );
  }
}

extension ToSync<T extends Object> on T {
  @pragma('vm:prefer-inline')
  Sync<T> toSync({
    Err<T> Function(Object?)? onError,
    void Function()? onFinalize,
  }) {
    assert(
      !_isSubtype<T, Future<Object>>(),
      'Do not call toSync on futures: $T.',
    );
    return Sync(
      () => this,
      onError: onError,
      onFinalize: onFinalize,
    );
  }
}

@pragma('vm:prefer-inline')
bool _isSubtype<TChild, TParent>() => <TChild>[] is List<TParent>;
