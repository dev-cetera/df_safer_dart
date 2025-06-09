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

import '/src/_src.g.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

extension OkSyncSwapX<T extends Object> on Ok<Sync<T>> {
  @pragma('vm:prefer-inline')
  Sync<Ok<T>> swap() => unwrap().map((e) => Ok(e));
}

extension OkAsyncSwapX<T extends Object> on Ok<Async<T>> {
  @pragma('vm:prefer-inline')
  Async<Ok<T>> swap() => unwrap().map((e) => Ok(e));
}

extension OkResolvableSwapX<T extends Object> on Ok<Resolvable<T>> {
  @pragma('vm:prefer-inline')
  Resolvable<Ok<T>> swap() => unwrap().map((e) => Ok(e));
}

extension OkOptionSwapX<T extends Object> on Ok<Option<T>> {
  @pragma('vm:prefer-inline')
  Option<Ok<T>> swap() => unwrap().map((e) => Ok(e));
}

extension OkSomeSwapX<T extends Object> on Ok<Some<T>> {
  @pragma('vm:prefer-inline')
  Some<Ok<T>> swap() => unwrap().map((e) => Ok(e));
}

extension OkNoneSwapX<T extends Object> on Ok<None<T>> {
  @pragma('vm:prefer-inline')
  None<Ok<T>> swap() => const None();
}

extension OkResultSwapX<T extends Object> on Ok<Result<T>> {
  @pragma('vm:prefer-inline')
  Result<Ok<T>> swap() => unwrap().map((e) => Ok(e));
}

extension OkErrSwapX<T extends Object> on Ok<Err<T>> {
  @pragma('vm:prefer-inline')
  Err<Ok<T>> swap() => unwrap().transfErr<Ok<T>>();
}
