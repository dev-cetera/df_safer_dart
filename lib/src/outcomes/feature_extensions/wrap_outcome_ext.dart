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

extension WrapOnOutcomeExt<T extends Object, M extends Outcome<T>> on M {
  @pragma('vm:prefer-inline')
  Some<M> wrapInSome() => Some(this);

  @pragma('vm:prefer-inline')
  Ok<M> wrapInOk() => Ok(this);

  @pragma('vm:prefer-inline')
  Resolvable<M> wrapInResolvable() => Resolvable(() => this);

  @pragma('vm:prefer-inline')
  Sync<M> wrapInSync() => Sync.okValue(this);

  @pragma('vm:prefer-inline')
  Async<M> wrapInAsync() => Async.okValue(this);

  Outcome<Some<T>> wrapValueInSome() => map((e) => Some(e));

  @pragma('vm:prefer-inline')
  Outcome<Ok<T>> wrapValueInOk() => map((e) => Ok(e));

  @pragma('vm:prefer-inline')
  Outcome<Resolvable<T>> wrapValueInResolvable() => map((e) => Sync.okValue(e));

  @pragma('vm:prefer-inline')
  Outcome<Sync<T>> wrapValueInSync() => map((e) => Sync.okValue(e));

  @pragma('vm:prefer-inline')
  Outcome<Async<T>> wrapValueInAsync() => map((e) => Async.okValue(e));
}

extension WrapOnResolvableExt<T extends Object> on Resolvable<T> {
  @pragma('vm:prefer-inline')
  Resolvable<Some<T>> wrapValueInSome() => then((e) => Some(e));

  @pragma('vm:prefer-inline')
  Resolvable<Ok<T>> wrapValueInOk() => then((e) => Ok(e));

  @pragma('vm:prefer-inline')
  Resolvable<Resolvable<T>> wrapValueInResolvable() =>
      then((e) => Sync.okValue(e));

  @pragma('vm:prefer-inline')
  Resolvable<Sync<T>> wrapValueInSync() => then((e) => Sync.okValue(e));

  @pragma('vm:prefer-inline')
  Resolvable<Async<T>> wrapValueInAsync() => then((e) => Async.okValue(e));
}

extension WrapOnSyncExt<T extends Object> on Sync<T> {
  @pragma('vm:prefer-inline')
  Sync<Some<T>> wrapValueInSome() => map((e) => Some(e));

  @pragma('vm:prefer-inline')
  Sync<Ok<T>> wrapValueInOk() => map((e) => Ok(e));

  @pragma('vm:prefer-inline')
  Sync<Resolvable<T>> wrapValueInResolvable() => map((e) => Sync.okValue(e));

  @pragma('vm:prefer-inline')
  Sync<Sync<T>> wrapValueInSync() => map((e) => Sync.okValue(e));

  @pragma('vm:prefer-inline')
  Sync<Async<T>> wrapValueInAsync() => map((e) => Async.okValue(e));
}

extension WrapOnAsyncExt<T extends Object> on Async<T> {
  @pragma('vm:prefer-inline')
  Async<Some<T>> wrapValueInSome() => then((e) => Some(e));

  @pragma('vm:prefer-inline')
  Async<Ok<T>> wrapValueInOk() => then((e) => Ok(e));

  @pragma('vm:prefer-inline')
  Async<Resolvable<T>> wrapValueInResolvable() => then((e) => Sync.okValue(e));

  @pragma('vm:prefer-inline')
  Async<Sync<T>> wrapValueInSync() => then((e) => Sync.okValue(e));

  @pragma('vm:prefer-inline')
  Async<Async<T>> wrapValueInAsync() => then((e) => Async.okValue(e));
}

extension WrapOnOptionExt<T extends Object> on Option<T> {
  @pragma('vm:prefer-inline')
  Option<Some<T>> wrapValueInSome() => map((e) => Some(e));

  @pragma('vm:prefer-inline')
  Option<Ok<T>> wrapValueInOk() => map((e) => Ok(e));

  @pragma('vm:prefer-inline')
  Option<Resolvable<T>> wrapValueInResolvable() => map((e) => Sync.okValue(e));

  @pragma('vm:prefer-inline')
  Option<Sync<T>> wrapValueInSync() => map((e) => Sync.okValue(e));

  @pragma('vm:prefer-inline')
  Option<Async<T>> wrapValueInAsync() => map((e) => Async.okValue(e));
}

extension WrapOnSomeExt<T extends Object> on Some<T> {
  @pragma('vm:prefer-inline')
  Some<Some<T>> wrapValueInSome() => map((e) => Some(e));

  @pragma('vm:prefer-inline')
  Some<Ok<T>> wrapValueInOk() => map((e) => Ok(e));

  @pragma('vm:prefer-inline')
  Some<Resolvable<T>> wrapValueInResolvable() => map((e) => Sync.okValue(e));

  @pragma('vm:prefer-inline')
  Some<Sync<T>> wrapValueInSync() => map((e) => Sync.okValue(e));

  @pragma('vm:prefer-inline')
  Some<Async<T>> wrapValueInAsync() => map((e) => Async.okValue(e));
}

extension WrapOnNoneExt<T extends Object> on None<T> {
  @pragma('vm:prefer-inline')
  None<Some<T>> wrapValueInSome() => const None();

  @pragma('vm:prefer-inline')
  None<Ok<T>> wrapValueInOk() => const None();

  @pragma('vm:prefer-inline')
  None<Resolvable<T>> wrapValueInResolvable() => const None();

  @pragma('vm:prefer-inline')
  None<Sync<T>> wrapValueInSync() => const None();

  @pragma('vm:prefer-inline')
  None<Async<T>> wrapValueInAsync() => const None();
}

extension WrapOnResultExt<T extends Object> on Result<T> {
  @pragma('vm:prefer-inline')
  Result<Some<T>> wrapValueInSome() => map((e) => Some(e));

  @pragma('vm:prefer-inline')
  Result<Ok<T>> wrapValueInOk() => map((e) => Ok(e));

  @pragma('vm:prefer-inline')
  Result<Resolvable<T>> wrapValueInResolvable() => map((e) => Sync.okValue(e));

  @pragma('vm:prefer-inline')
  Result<Sync<T>> wrapValueInSync() => map((e) => Sync.okValue(e));

  @pragma('vm:prefer-inline')
  Result<Async<T>> wrapValueInAsync() => map((e) => Async.okValue(e));
}

extension WrapOnOkExt<T extends Object> on Ok<T> {
  @pragma('vm:prefer-inline')
  Ok<Some<T>> wrapValueInSome() => map((e) => Some(e));

  @pragma('vm:prefer-inline')
  Ok<Ok<T>> wrapValueInOk() => map((e) => Ok(e));

  @pragma('vm:prefer-inline')
  Ok<Resolvable<T>> wrapValueInResolvable() => map((e) => Sync.okValue(e));

  @pragma('vm:prefer-inline')
  Ok<Sync<T>> wrapValueInSync() => map((e) => Sync.okValue(e));

  @pragma('vm:prefer-inline')
  Ok<Async<T>> wrapValueInAsync() => map((e) => Async.okValue(e));
}

extension WrapOnErrExt<T extends Object> on Err<T> {
  @pragma('vm:prefer-inline')
  Err<Some<T>> wrapValueInSome() => transfErr();

  @pragma('vm:prefer-inline')
  Err<Ok<T>> wrapValueInOk() => transfErr();

  @pragma('vm:prefer-inline')
  Err<Resolvable<T>> wrapValueInResolvable() => transfErr();

  @pragma('vm:prefer-inline')
  Err<Sync<T>> wrapValueInSync() => transfErr();

  @pragma('vm:prefer-inline')
  Err<Async<T>> wrapValueInAsync() => transfErr();
}
