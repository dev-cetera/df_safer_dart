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

extension SwapResolvableSomeExt<T extends Object> on Resolvable<Some<T>> {
  @pragma('vm:prefer-inline')
  Some<Resolvable<T>> swap() {
    if (this is Sync<Some<T>>) {
      return (this as Sync<Some<T>>).swap();
    }
    return (this as Async<Some<T>>).swap();
  }
}

extension SwapResolvableNoneExt<T extends Object> on Resolvable<None<T>> {
  @pragma('vm:prefer-inline')
  None<Resolvable<T>> swap() => const None();
}

extension SwapResolvableOkExt<T extends Object> on Resolvable<Ok<T>> {
  @pragma('vm:prefer-inline')
  Ok<Resolvable<T>> swap() {
    return Ok(then((e) => e.unwrap()));
  }
}
