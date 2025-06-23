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

import '/src/_src.g.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

extension $SomeSyncSwapX<T extends Object> on Some<Sync<T>> {
  @pragma('vm:prefer-inline')
  Sync<Some<T>> swap() => unwrap().map((e) => Some(e));
}

extension $SomeAsyncSwapX<T extends Object> on Some<Async<T>> {
  @pragma('vm:prefer-inline')
  Async<Some<T>> swap() => unwrap().map((e) => Some(e));
}

extension $SomeResolvableSwapX<T extends Object> on Some<Resolvable<T>> {
  @pragma('vm:prefer-inline')
  Resolvable<Some<T>> swap() => unwrap().map((e) => Some(e));
}

extension $SomeOptionSwapX<T extends Object> on Some<Option<T>> {
  @pragma('vm:prefer-inline')
  Option<Some<T>> swap() => unwrap().map((e) => Some(e));
}

extension $SomeNoneSwapX<T extends Object> on Some<None<T>> {
  @pragma('vm:prefer-inline')
  None<Some<T>> swap() => const None();
}

extension $SomeResultSwapX<T extends Object> on Some<Result<T>> {
  @pragma('vm:prefer-inline')
  Result<Some<T>> swap() => unwrap().map((e) => Some(e));
}

extension $SomeOkSwapX<T extends Object> on Some<Ok<T>> {
  @pragma('vm:prefer-inline')
  Ok<Some<T>> swap() => Ok(Some(unwrap().unwrap()));
}

extension $SomeErrSwapX<T extends Object> on Some<Err<T>> {
  @pragma('vm:prefer-inline')
  Err<Some<T>> swap() => unwrap().transfErr<Some<T>>();
}
