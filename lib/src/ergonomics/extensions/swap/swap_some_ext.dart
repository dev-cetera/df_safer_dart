//.title
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//
// Copyright © dev-cetera.com & contributors.
//
// The use of this source code is governed by an MIT-style license described in
// the LICENSE file located in this project's root directory.
//
// See: https://opensource.org/license/mit
//
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//.title~

import '/_common.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

extension SwapSomeSyncExt<T extends Object> on Some<Sync<T>> {
  @pragma('vm:prefer-inline')
  Sync<Some<T>> swap() => unwrap().map(Some.new);
}

extension SwapSomeAsyncExt<T extends Object> on Some<Async<T>> {
  @pragma('vm:prefer-inline')
  Async<Some<T>> swap() => unwrap().then(Some.new);
}

extension SwapSomeResolvableExt<T extends Object> on Some<Resolvable<T>> {
  @pragma('vm:prefer-inline')
  Resolvable<Some<T>> swap() => unwrap().then(Some.new);
}

extension SwapSomeOptionExt<T extends Object> on Some<Option<T>> {
  @pragma('vm:prefer-inline')
  Option<Some<T>> swap() => unwrap().map(Some.new);
}

extension SwapSomeNoneExt<T extends Object> on Some<None<T>> {
  @pragma('vm:prefer-inline')
  None<Some<T>> swap() => const None();
}

extension SwapSomeResultExt<T extends Object> on Some<Result<T>> {
  @pragma('vm:prefer-inline')
  Result<Some<T>> swap() => unwrap().map(Some.new);
}

extension SwapSomeOkExt<T extends Object> on Some<Ok<T>> {
  @pragma('vm:prefer-inline')
  Ok<Some<T>> swap() => Ok(Some(unwrap().unwrap()));
}

extension SwapSomeErrExt<T extends Object> on Some<Err<T>> {
  @pragma('vm:prefer-inline')
  Err<Some<T>> swap() => unwrap().transfErr<Some<T>>();
}
