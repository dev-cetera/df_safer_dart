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

extension $ErrSyncSwapX<T extends Object> on Err<Sync<T>> {
  @pragma('vm:prefer-inline')
  Sync<Err<T>> swap() => transfErr<T>().wrapSync();
}

extension $ErrAsyncSwapX<T extends Object> on Err<Async<T>> {
  @pragma('vm:prefer-inline')
  Async<Err<T>> swap() => transfErr<T>().wrapAsync();
}

extension $ErrResolvableSwapX<T extends Object> on Err<Resolvable<T>> {
  @pragma('vm:prefer-inline')
  Resolvable<Err<T>> swap() => transfErr<T>().wrapSync();
}

extension $ErrOptionSwapX<T extends Object> on Err<Option<T>> {
  @pragma('vm:prefer-inline')
  Option<Err<T>> swap() => Some(transfErr<T>());
}

extension $ErrSomeSwapX<T extends Object> on Err<Some<T>> {
  @pragma('vm:prefer-inline')
  Some<Err<T>> swap() => Some(transfErr<T>());
}

extension $ErrNoneSwapX<T extends Object> on Err<None<T>> {
  @pragma('vm:prefer-inline')
  None<Err<T>> swap() => const None();
}

extension $ErrResultSwapX<T extends Object> on Err<Result<T>> {
  @pragma('vm:prefer-inline')
  Result<Err<T>> swap() => Ok(transfErr<T>());
}

extension $ErrOkSwapX<T extends Object> on Err<Ok<T>> {
  @pragma('vm:prefer-inline')
  Ok<Err<T>> swap() => Ok(transfErr<T>());
}
