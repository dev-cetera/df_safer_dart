// ignore_for_file: must_use_unsafe_wrapper_or_error
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

import 'package:df_safer_dart_annotations/df_safer_dart_annotations.dart' show unsafeOrError;

import '/src/_src.g.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

@pragma('vm:prefer-inline')
Sync<None<T>> syncNone<T extends Object>() => const Sync.unsafe(Ok(None()));

@pragma('vm:prefer-inline')
Async<None<T>> asyncNone<T extends Object>() => Async.unsafe(Future.value(Ok(None<T>())));

@pragma('vm:prefer-inline')
Resolvable<None<T>> resolvableNone<T extends Object>() => syncNone();

@pragma('vm:prefer-inline')
Sync<Unit> syncUnit() => Sync.unsafe(Ok(Unit()));

@pragma('vm:prefer-inline')
Async<Unit> asyncUnit() => Async.unsafe(Future.value(Ok(Unit())));

@pragma('vm:prefer-inline')
Resolvable<Unit> resolvableUnit() => syncUnit();

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

extension $$SyncOptionExtension<T extends Object> on Sync<Option<T>> {
  @unsafeOrError
  @pragma('vm:prefer-inline')
  T unwrapSync() => unwrap().unwrap();
}

extension $$AsyncOptionExtension<T extends Object> on Async<Option<T>> {
  @unsafeOrError
  @pragma('vm:prefer-inline')
  Future<T> unwrapAsync() => unwrap().then((e) => e.unwrap());
}

extension $$ResolvableOptionExtension<T extends Object> on Resolvable<Option<T>> {
  @unsafeOrError
  @pragma('vm:prefer-inline')
  T unwrapSync() => sync().unwrap().unwrapSync();

  @unsafeOrError
  @pragma('vm:prefer-inline')
  Future<T> unwrapAsync() => async().unwrap().unwrapAsync();
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

typedef TReducedMonad<T extends Object> = Resolvable<Option<T>>;
typedef TOptionResult<T extends Object> = Option<Result<T>>;
