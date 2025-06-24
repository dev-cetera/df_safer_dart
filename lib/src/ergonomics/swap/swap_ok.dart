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

import '/_common.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

extension $OkSyncSwapExtension<T extends Object> on Ok<Sync<T>> {
  @pragma('vm:prefer-inline')
  Sync<Ok<T>> swap() => unwrap().map((e) => Ok(e));
}

extension $OkAsyncSwapExtension<T extends Object> on Ok<Async<T>> {
  @pragma('vm:prefer-inline')
  Async<Ok<T>> swap() => unwrap().map((e) => Ok(e));
}

extension $OkResolvableSwapExtension<T extends Object> on Ok<Resolvable<T>> {
  @pragma('vm:prefer-inline')
  Resolvable<Ok<T>> swap() => unwrap().then((e) => Ok(e));
}

extension $OkOptionSwapExtension<T extends Object> on Ok<Option<T>> {
  @pragma('vm:prefer-inline')
  Option<Ok<T>> swap() => unwrap().map((e) => Ok(e));
}

extension $OkSomeSwapExtension<T extends Object> on Ok<Some<T>> {
  @pragma('vm:prefer-inline')
  Some<Ok<T>> swap() => unwrap().map((e) => Ok(e));
}

extension $OkNoneSwapExtension<T extends Object> on Ok<None<T>> {
  @pragma('vm:prefer-inline')
  None<Ok<T>> swap() => const None();
}

extension $OkResultSwapExtension<T extends Object> on Ok<Result<T>> {
  @pragma('vm:prefer-inline')
  Result<Ok<T>> swap() => unwrap().map((e) => Ok(e));
}

extension $OkErrSwapExtension<T extends Object> on Ok<Err<T>> {
  @pragma('vm:prefer-inline')
  Err<Ok<T>> swap() => unwrap().transfErr<Ok<T>>();
}
