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

import '/src/utils/_no_stack_overflow_wrapper.dart' show NoStackOverflowWrapper;

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// Converts [input] to `Iterable<Option<T>>`, returning [None] on failure.
///
/// Supported types:
///
/// - Any sync [Outcome] chain.
/// - [bool]
/// - [num]
/// - [double]
/// - [int]
/// - [String]
/// - [DateTime]
/// - [Uri],
/// - [Iterable] (dynamic)
/// - [List]  (dynamic)
/// - [Set] (dynamic)
/// - [Map] (dynamic, dynamic)
Option<Iterable<Option<T>>> letIterableOrNone<T extends Object>(dynamic input) {
  if (input is Outcome) {
    return switch (input.rawSync().value) {
      Ok(value: final okValue) => letIterableOrNone(
        NoStackOverflowWrapper(okValue),
      ),
      Err() => const None(),
    };
  }
  return switch (input is NoStackOverflowWrapper ? input.value : input) {
    final Iterable<dynamic> i => Some(i.map((e) => letOrNone<T>(e))),
    final String s => jsonDecodeOrNone<Iterable<dynamic>>(
      s,
    ).map((i) => i.map((e) => letOrNone<T>(e))),
    _ => const None(),
  };
}

// Converts [input] to `List<Option<T>>`, returning [None] on failure.
///
/// Supported types:
///
/// - Any sync [Outcome] chain.
/// - [bool]
/// - [num]
/// - [double]
/// - [int]
/// - [String]
/// - [DateTime]
/// - [Uri],
/// - [Iterable] (dynamic)
/// - [List]  (dynamic)
/// - [Set] (dynamic)
/// - [Map] (dynamic, dynamic)
Option<List<Option<T>>> letListOrNone<T extends Object>(dynamic input) {
  return letIterableOrNone<T>(input).map((e) => List.from(e));
}

// Converts [input] to `Set<Option<T>>`, returning [None] on failure.
///
/// Supported types:
///
/// - Any sync [Outcome] chain.
/// - [bool]
/// - [num]
/// - [double]
/// - [int]
/// - [String]
/// - [DateTime]
/// - [Uri],
/// - [Iterable] (dynamic)
/// - [List]  (dynamic)
/// - [Set] (dynamic)
/// - [Map] (dynamic, dynamic)
Option<Set<Option<T>>> letSetOrNone<T extends Object>(dynamic input) {
  return letIterableOrNone<T>(input).map((e) => Set.from(e));
}
