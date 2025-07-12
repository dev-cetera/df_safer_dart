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

extension ToVoidOnOutcomeExt<T extends Object> on Outcome<T> {
  @visibleForTesting
  @pragma('vm:prefer-inline')
  Outcome<void> toVoid() => this;
}

extension ToVoidOnResolvableExt<T extends Object> on Resolvable<T> {
  @visibleForTesting
  @pragma('vm:prefer-inline')
  Resolvable<void> toVoid() => this;
}

extension ToVoidOnSyncExt<T extends Object> on Sync<T> {
  @visibleForTesting
  @pragma('vm:prefer-inline')
  Sync<void> toVoid() => this;
}

extension ToVoidOnAsyncExt<T extends Object> on Async<T> {
  @visibleForTesting
  @pragma('vm:prefer-inline')
  Async<void> toVoid() => this;
}

extension ToVoidOnOptionExt<T extends Object> on Option<T> {
  @visibleForTesting
  @pragma('vm:prefer-inline')
  Option<void> toVoid() => this;
}

extension ToVoidOnSomeExt<T extends Object> on Some<T> {
  @visibleForTesting
  @pragma('vm:prefer-inline')
  Some<void> toVoid() => this;
}

extension ToVoidOnNoneExt<T extends Object> on None<T> {
  @visibleForTesting
  @pragma('vm:prefer-inline')
  None<void> toVoid() => this;
}

extension ToVoidOnResultExt<T extends Object> on Result<T> {
  @visibleForTesting
  @pragma('vm:prefer-inline')
  Result<void> toVoid() => this;
}

extension ToVoidOnOkExt<T extends Object> on Ok<T> {
  @visibleForTesting
  @pragma('vm:prefer-inline')
  Ok<void> toVoid() => this;
}

extension ToVoidOnErrExt<T extends Object> on Err<T> {
  @visibleForTesting
  @pragma('vm:prefer-inline')
  Err<void> toVoid() => this;
}
