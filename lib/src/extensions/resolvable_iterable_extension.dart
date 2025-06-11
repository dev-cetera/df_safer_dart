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

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

extension IterableResolvableExtension<T extends Object>
    on Iterable<Resolvable<T>> {
  Iterable<Sync<T>> whereSync() {
    return where((e) => e.isSync()).map((e) => e.sync().unwrap());
  }

  Iterable<Async<T>> whereAsync() {
    return where((e) => e.isAsync()).map((e) => e.async().unwrap());
  }

  Iterable<Async<T>> mapToAsync() {
    return map((e) => e.toAsync());
  }
}

extension IterableSyncExtension<T extends Object> on Iterable<Sync<T>> {
  Iterable<Result<T>> mapToResults() {
    return whereSync().map((e) => e.value);
  }
}

extension IterableAsyncExtension<T extends Object> on Iterable<Async<T>> {
  Iterable<Future<Result<T>>> mapToResults() {
    return whereAsync().map((e) => e.value);
  }
}
