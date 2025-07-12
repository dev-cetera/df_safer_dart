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

extension SwapErrSyncExt<T extends Object> on Err<Sync<T>> {
  @pragma('vm:prefer-inline')
  Sync<Err<T>> swap() => transfErr<T>().wrapInSync();
}

extension SwapErrAsyncExt<T extends Object> on Err<Async<T>> {
  @pragma('vm:prefer-inline')
  Async<Err<T>> swap() => transfErr<T>().wrapInAsync();
}

extension SwapErrResolvableExt<T extends Object> on Err<Resolvable<T>> {
  @pragma('vm:prefer-inline')
  Resolvable<Err<T>> swap() => transfErr<T>().wrapInSync();
}

extension SwapErrOptionExt<T extends Object> on Err<Option<T>> {
  @pragma('vm:prefer-inline')
  Option<Err<T>> swap() => Some(transfErr<T>());
}

extension SwapErrSomeExt<T extends Object> on Err<Some<T>> {
  @pragma('vm:prefer-inline')
  Some<Err<T>> swap() => Some(transfErr<T>());
}

extension SwapErrNoneExt<T extends Object> on Err<None<T>> {
  @pragma('vm:prefer-inline')
  None<Err<T>> swap() => const None();
}

extension SwapErrResultExt<T extends Object> on Err<Result<T>> {
  @pragma('vm:prefer-inline')
  Result<Err<T>> swap() => Ok(transfErr<T>());
}

extension SwapErrOkExt<T extends Object> on Err<Ok<T>> {
  @pragma('vm:prefer-inline')
  Ok<Err<T>> swap() => Ok(transfErr<T>());
}
