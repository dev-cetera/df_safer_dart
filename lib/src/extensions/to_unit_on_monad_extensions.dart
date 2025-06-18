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

import '../monads/monad.dart';
import '../utils/unit.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

// Void.

extension ToUnitOnVoidMonad on Monad<void> {
  Monad<Unit> toUnit() => map((_) => Unit.instance);
}

extension ToUnitOnVoidOption on Option<void> {
  Option<Unit> toUnit() => map((_) => Unit.instance);
}

extension ToUnitOnVoidSome on Some<void> {
  Some<Unit> toUnit() => map((_) => Unit.instance);
}

extension ToUnitOnVoidNone on None<void> {
  None<Unit> toUnit() => map((_) => Unit.instance);
}

extension ToUnitOnVoidResolvable on Resolvable<void> {
  Resolvable<Unit> toUnit() => map((_) => Unit.instance);
}

extension ToUnitOnVoidSync on Sync<void> {
  Sync<Unit> toUnit() => map((_) => Unit.instance);
}

extension ToUnitOnVoidAsync on Async<void> {
  Async<Unit> toUnit() => map((_) => Unit.instance);
}

extension ToUnitOnVoidResult on Result<void> {
  Result<Unit> toUnit() => map((_) => Unit.instance);
}

extension ToUnitOnVoidOk on Ok<void> {
  Ok<Unit> toUnit() => map((_) => Unit.instance);
}

extension ToUnitOnVoidErr on Err<void> {
  Err<Unit> toUnit() => map((_) => Unit.instance);
}

// Object.

extension ToUnitOnObjectMonad on Monad<Object> {
  Monad<Unit> toUnit() => map((_) => Unit.instance);
}

extension ToUnitOnObjectOption on Option<Object> {
  Option<Unit> toUnit() => map((_) => Unit.instance);
}

extension ToUnitOnObjectSome on Some<Object> {
  Some<Unit> toUnit() => map((_) => Unit.instance);
}

extension ToUnitOnObjectNone on None<Object> {
  None<Unit> toUnit() => map((_) => Unit.instance);
}

extension ToUnitOnObjectResolvable on Resolvable<Object> {
  Resolvable<Unit> toUnit() => map((_) => Unit.instance);
}

extension ToUnitOnObjectSync on Sync<Object> {
  Sync<Unit> toUnit() => map((_) => Unit.instance);
}

extension ToUnitOnObjectAsync on Async<Object> {
  Async<Unit> toUnit() => map((_) => Unit.instance);
}

extension ToUnitOnObjectResult on Result<Object> {
  Result<Unit> toUnit() => map((_) => Unit.instance);
}

extension ToUnitOnObjectOk on Ok<Object> {
  Ok<Unit> toUnit() => map((_) => Unit.instance);
}

extension ToUnitOnObjectErr on Err<Object> {
  Err<Unit> toUnit() => map((_) => Unit.instance);
}
