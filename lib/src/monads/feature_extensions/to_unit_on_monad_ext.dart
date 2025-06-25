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

// Void.

extension ToUnitOnVoidMonad on Monad<void> {
  @visibleForTesting
  @pragma('vm:prefer-inline')
  Monad<Unit> toUnit() => map((_) => Unit());
}

extension ToUnitOnVoidOption on Option<void> {
  @visibleForTesting
  @pragma('vm:prefer-inline')
  Option<Unit> toUnit() => map((_) => Unit());
}

extension ToUnitOnVoidSome on Some<void> {
  @visibleForTesting
  @pragma('vm:prefer-inline')
  Some<Unit> toUnit() => map((_) => Unit());
}

extension ToUnitOnVoidNone on None<void> {
  @visibleForTesting
  @pragma('vm:prefer-inline')
  None<Unit> toUnit() => map((_) => Unit());
}

extension ToUnitOnVoidResolvable on Resolvable<void> {
  @visibleForTesting
  @pragma('vm:prefer-inline')
  Resolvable<Unit> toUnit() => then((_) => Unit());
}

extension ToUnitOnVoidSync on Sync<void> {
  @visibleForTesting
  @pragma('vm:prefer-inline')
  Sync<Unit> toUnit() => map((_) => Unit());
}

extension ToUnitOnVoidAsync on Async<void> {
  @visibleForTesting
  @pragma('vm:prefer-inline')
  Async<Unit> toUnit() => map((_) => Unit());
}

extension ToUnitOnVoidResult on Result<void> {
  @visibleForTesting
  @pragma('vm:prefer-inline')
  Result<Unit> toUnit() => map((_) => Unit());
}

extension ToUnitOnVoidOk on Ok<void> {
  @visibleForTesting
  @pragma('vm:prefer-inline')
  Ok<Unit> toUnit() => map((_) => Unit());
}

extension ToUnitOnVoidErr on Err<void> {
  @visibleForTesting
  @pragma('vm:prefer-inline')
  Err<Unit> toUnit() => map((_) => Unit());
}

// Object.

extension ToUnitOnObjectMonad on Monad<Object> {
  @pragma('vm:prefer-inline')
  Monad<Unit> toUnit() => map((_) => Unit());
}

extension ToUnitOnObjectOption on Option<Object> {
  @pragma('vm:prefer-inline')
  Option<Unit> toUnit() => map((_) => Unit());
}

extension ToUnitOnObjectSome on Some<Object> {
  @pragma('vm:prefer-inline')
  Some<Unit> toUnit() => map((_) => Unit());
}

extension ToUnitOnObjectNone on None<Object> {
  @pragma('vm:prefer-inline')
  None<Unit> toUnit() => map((_) => Unit());
}

extension ToUnitOnObjectResolvable on Resolvable<Object> {
  @pragma('vm:prefer-inline')
  Resolvable<Unit> toUnit() => then((_) => Unit());
}

extension ToUnitOnObjectSync on Sync<Object> {
  @pragma('vm:prefer-inline')
  Sync<Unit> toUnit() => map((_) => Unit());
}

extension ToUnitOnObjectAsync on Async<Object> {
  @pragma('vm:prefer-inline')
  Async<Unit> toUnit() => map((_) => Unit());
}

extension ToUnitOnObjectResult on Result<Object> {
  @pragma('vm:prefer-inline')
  Result<Unit> toUnit() => map((_) => Unit());
}

extension ToUnitOnObjectOk on Ok<Object> {
  @pragma('vm:prefer-inline')
  Ok<Unit> toUnit() => map((_) => Unit());
}

extension ToUnitOnObjectErr on Err<Object> {
  @pragma('vm:prefer-inline')
  Err<Unit> toUnit() => map((_) => Unit());
}
