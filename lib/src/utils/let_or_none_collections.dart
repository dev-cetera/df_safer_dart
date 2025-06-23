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

import '../_src.g.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

Option<Iterable<Option<T>>> letIterableOrNone<T extends Object>(dynamic input) {
  if (input is Monad) {
    return switch (input.rawSync().value) {
      Ok(value: final okValue) => letIterableOrNone(_NoStackOverflowWrapper(okValue)),
      Err() => const None(),
    };
  }
  return switch (input is _NoStackOverflowWrapper ? input.value : input) {
    final Iterable<T> i => Some(i.map((e) => Some(e))),
    final Iterable<dynamic> i => Some(i.map((e) => letOrNone<T>(e))),
    final String s => jsonDecodeOrNone<Iterable<dynamic>>(s)
        .map((iterable) => iterable.map((item) => letOrNone<T>(item))),
    _ => const None(),
  };
}

class _NoStackOverflowWrapper<T> {
  final T value;
  const _NoStackOverflowWrapper(this.value);
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

Option<List<Option<T>>> letListOrNone<T extends Object>(dynamic input) {
  return letIterableOrNone<T>(input).map((e) => List.from(e));
}

Option<Set<Option<T>>> letSetOrNone<T extends Object>(dynamic input) {
  return letIterableOrNone<T>(input).map((e) => Set.from(e));
}
