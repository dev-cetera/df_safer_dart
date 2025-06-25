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

extension SwapNoneSyncExt<T extends Object> on None<Sync<T>> {
  @pragma('vm:prefer-inline')
  Sync<None<T>> swap() => None<T>().wrapInSync();
}

extension SwapNoneAsyncExt<T extends Object> on None<Async<T>> {
  @pragma('vm:prefer-inline')
  Async<None<T>> swap() => None<T>().wrapInAsync();
}

extension SwapNoneResolvableExt<T extends Object> on None<Resolvable<T>> {
  @pragma('vm:prefer-inline')
  Resolvable<None<T>> swap() => None<T>().wrapInResolvable();
}

extension SwapNoneOptionExt<T extends Object> on None<Option<T>> {
  @pragma('vm:prefer-inline')
  Option<None<T>> swap() => const Some(None());
}

extension SwapNoneSomeExt<T extends Object> on None<Some<T>> {
  @pragma('vm:prefer-inline')
  Some<None<T>> swap() => const Some(None());
}

extension SwapNoneResultExt<T extends Object> on None<Result<T>> {
  @pragma('vm:prefer-inline')
  Result<None<T>> swap() => const Ok(None());
}

extension SwapNoneOkExt<T extends Object> on None<Ok<T>> {
  @pragma('vm:prefer-inline')
  Ok<None<T>> swap() => const Ok(None());
}

extension SwapNoneErrExt<T extends Object> on None<Err<T>> {
  @pragma('vm:prefer-inline')
  Err<None<T>> swap() {
    return Err(const None());
  }
}
