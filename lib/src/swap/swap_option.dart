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

extension $OptionSyncSwapX<T extends Object> on Option<Sync<T>> {
  @pragma('vm:prefer-inline')
  Sync<Option<T>> swap() {
    if (this is Some<Sync<T>>) {
      return (this as Some<Sync<T>>).swap();
    }
    return (this as None<Sync<T>>).swap();
  }
}

extension $OptionAsyncSwapX<T extends Object> on Option<Async<T>> {
  @pragma('vm:prefer-inline')
  Async<Option<T>> swap() {
    if (this is Some<Async<T>>) {
      return (this as Some<Async<T>>).swap();
    }
    return (this as None<Async<T>>).swap();
  }
}

extension $OptionResolvableSwapX<T extends Object> on Option<Resolvable<T>> {
  @pragma('vm:prefer-inline')
  Resolvable<Option<T>> swap() {
    if (this is Some<Resolvable<T>>) {
      return (this as Some<Resolvable<T>>).swap();
    }
    return (this as None<Resolvable<T>>).swap();
  }
}

extension $OptionSomeSwapX<T extends Object> on Option<Some<T>> {
  @pragma('vm:prefer-inline')
  Some<Option<T>> swap() {
    if (this is Some<Some<T>>) {
      return this as Some<Some<T>>;
    }
    return (this as None<Some<T>>).swap();
  }
}

extension $OptionNoneSwapX<T extends Object> on Option<None<T>> {
  @pragma('vm:prefer-inline')
  None<Option<T>> swap() {
    return const None();
  }
}

extension $OptionResultSwapX<T extends Object> on Option<Result<T>> {
  @pragma('vm:prefer-inline')
  Result<Option<T>> swap() {
    if (this is Some<Result<T>>) {
      return (this as Some<Result<T>>).swap();
    }
    return (this as None<Result<T>>).swap();
  }
}

extension $OptionOkSwapX<T extends Object> on Option<Ok<T>> {
  @pragma('vm:prefer-inline')
  Ok<Option<T>> swap() {
    if (this is Some<Result<T>>) {
      return (this as Some<Ok<T>>).swap();
    }
    return (this as None<Ok<T>>).swap();
  }
}

extension $OptionErrSwapX<T extends Object> on Option<Err<T>> {
  @pragma('vm:prefer-inline')
  Err<Option<T>> swap() {
    if (this is Some<Result<T>>) {
      return (this as Some<Err<T>>).swap();
    }
    return (this as None<Err<T>>).swap();
  }
}
