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

extension IterableOptionExtension<T extends Object> on Iterable<Option<T>> {
  Iterable<Some<T>> whereSome() {
    return where((e) => e.isSome()).map((e) => e.some().unwrap());
  }

  Iterable<None<T>> whereNone() {
    return where((e) => e.isSome()).map((e) => e.none().unwrap());
  }
}

extension IterableFutureOptionExtension<T extends Object> on Iterable<Future<Option<T>>> {
  Future<Iterable<Some<T>>> whereSome() {
    return Future.wait(this).then((e) => e.whereSome());
  }

  Future<Iterable<None<T>>> whereNone() {
    return Future.wait(this).then((e) => e.whereNone());
  }
}

extension IterableSomeExtension<T extends Object> on Iterable<Some<T>> {
  Iterable<T> unwrapAll() {
    return whereSome().map((e) => e.value);
  }
}

extension FutureIterableSomeExtension<T extends Object> on Future<Iterable<Some<T>>> {
  Future<Iterable<T>> unwrapAll() {
    return then((e) => e.unwrapAll());
  }
}
