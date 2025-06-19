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

// ignore_for_file: must_use_unsafe_wrapper_or_error

import '../monads/monad.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

extension IterableResultExtension<T extends Object> on Iterable<Result<T>> {
  Iterable<Ok<T>> whereOk() {
    return where((e) => e.isOk()).map((e) => e.ok().unwrap());
  }

  Iterable<Err<T>> whereErr() {
    return where((e) => e.isOk()).map((e) => e.err().unwrap());
  }
}

extension IterableFutureResultExtension<T extends Object>
    on Iterable<Future<Result<T>>> {
  Future<Iterable<Ok<T>>> whereOk() {
    return Future.wait(this).then((e) => e.whereOk());
  }

  Future<Iterable<Err<T>>> whereErr() {
    return Future.wait(this).then((e) => e.whereErr());
  }
}

extension IterableOkExtension<T extends Object> on Iterable<Ok<T>> {
  Iterable<T> unwrapAll() {
    return whereOk().map((e) => e.value);
  }
}

extension FutureIterableOkExtension<T extends Object>
    on Future<Iterable<Ok<T>>> {
  Future<Iterable<T>> unwrapAll() {
    return then((e) => e.unwrapAll());
  }
}
