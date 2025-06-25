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
  Monad<Unit> toUnit() => map((_) => Unit());
}

extension ToUnitOnVoidOption on Option<void> {
  Option<Unit> toUnit() => map((_) => Unit());
}

extension ToUnitOnVoidSome on Some<void> {
  Some<Unit> toUnit() => map((_) => Unit());
}

extension ToUnitOnVoidNone on None<void> {
  None<Unit> toUnit() => map((_) => Unit());
}

extension ToUnitOnVoidResolvable on Resolvable<void> {
  Resolvable<Unit> toUnit() => then((_) => Unit());
}

extension ToUnitOnVoidSync on Sync<void> {
  Sync<Unit> toUnit() => map((_) => Unit());
}

extension ToUnitOnVoidAsync on Async<void> {
  Async<Unit> toUnit() => map((_) => Unit());
}

extension ToUnitOnVoidResult on Result<void> {
  Result<Unit> toUnit() => map((_) => Unit());
}

extension ToUnitOnVoidOk on Ok<void> {
  Ok<Unit> toUnit() => map((_) => Unit());
}

extension ToUnitOnVoidErr on Err<void> {
  Err<Unit> toUnit() => map((_) => Unit());
}

// Object.

extension ToUnitOnObjectMonad on Monad<Object> {
  Monad<Unit> toUnit() => map((_) => Unit());
}

extension ToUnitOnObjectOption on Option<Object> {
  Option<Unit> toUnit() => map((_) => Unit());
}

extension ToUnitOnObjectSome on Some<Object> {
  Some<Unit> toUnit() => map((_) => Unit());
}

extension ToUnitOnObjectNone on None<Object> {
  None<Unit> toUnit() => map((_) => Unit());
}

extension ToUnitOnObjectResolvable on Resolvable<Object> {
  Resolvable<Unit> toUnit() => then((_) => Unit());
}

extension ToUnitOnObjectSync on Sync<Object> {
  Sync<Unit> toUnit() => map((_) => Unit());
}

extension ToUnitOnObjectAsync on Async<Object> {
  Async<Unit> toUnit() => map((_) => Unit());
}

extension ToUnitOnObjectResult on Result<Object> {
  Result<Unit> toUnit() => map((_) => Unit());
}

extension ToUnitOnObjectOk on Ok<Object> {
  Ok<Unit> toUnit() => map((_) => Unit());
}

extension ToUnitOnObjectErr on Err<Object> {
  Err<Unit> toUnit() => map((_) => Unit());
}
