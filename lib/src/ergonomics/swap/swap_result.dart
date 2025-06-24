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

extension $ResultSyncSwapExtension<T extends Object> on Result<Sync<T>> {
  @pragma('vm:prefer-inline')
  Sync<Result<T>> swap() {
    if (this is Ok<Sync<T>>) {
      return (this as Ok<Sync<T>>).swap();
    }
    return (this as Err<Sync<T>>).swap();
  }
}

extension $ResultAsyncSwapExtension<T extends Object> on Result<Async<T>> {
  @pragma('vm:prefer-inline')
  Async<Result<T>> swap() {
    if (this is Ok<Async<T>>) {
      return (this as Ok<Async<T>>).swap();
    }
    return (this as Err<Async<T>>).swap();
  }
}

extension $ResultResolvableSwapExtension<T extends Object> on Result<Resolvable<T>> {
  @pragma('vm:prefer-inline')
  Resolvable<Result<T>> swap() {
    if (this is Ok<Resolvable<T>>) {
      return (this as Ok<Resolvable<T>>).swap();
    }
    return (this as Err<Resolvable<T>>).swap();
  }
}

extension $ResultOptionSwapExtension<T extends Object> on Result<Option<T>> {
  @pragma('vm:prefer-inline')
  Option<Result<T>> swap() {
    if (this is Ok<Option<T>>) {
      return (this as Ok<Option<T>>).swap();
    }
    return (this as Err<Option<T>>).swap();
  }
}

extension $ResultSomeSwapExtension<T extends Object> on Result<Some<T>> {
  @pragma('vm:prefer-inline')
  Some<Result<T>> swap() {
    if (this is Ok<Some<T>>) {
      return (this as Ok<Some<T>>).swap();
    }
    return (this as Err<Some<T>>).swap();
  }
}

extension $ResultNoneSwapExtension<T extends Object> on Result<None<T>> {
  @pragma('vm:prefer-inline')
  Option<Result<T>> swap() {
    if (this is Ok<None<T>>) {
      return (this as Ok<None<T>>).swap();
    }
    return (this as Err<None<T>>).swap();
  }
}

extension $ResultOkSwapExtension<T extends Object> on Result<Ok<T>> {
  @pragma('vm:prefer-inline')
  Ok<Result<T>> swap() {
    if (this is Ok<Ok<T>>) {
      return this as Ok<Ok<T>>;
    }
    return (this as Err<Ok<T>>).swap();
  }
}

extension $ResultErrSwapExtension<T extends Object> on Result<Err<T>> {
  @pragma('vm:prefer-inline')
  Result<T> swap() {
    if (this is Ok<Err<T>>) {
      return (this as Ok<Err<T>>).unwrap();
    }
    return (this as Err<Err<T>>).transfErr();
  }
}
