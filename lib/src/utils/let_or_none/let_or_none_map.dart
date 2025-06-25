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

import '/_common.dart';

import '/src/utils/_no_stack_overflow_wrapper.dart' show NoStackOverflowWrapper;

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// Converts [input] to `Map<K, Option<V>>`, returning [None] on failure.
///
/// Supported types:
///
/// - Any sync [Monad] chain.
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
Option<Map<K, Option<V>>> letMapOrNone<K extends Object, V extends Object>(
  dynamic input,
) {
  if (input is Monad) {
    return switch (input.rawSync().value) {
      Ok(value: final okValue) => letMapOrNone<K, V>(
        NoStackOverflowWrapper(okValue),
      ),
      Err() => const None(),
    };
  }

  return switch (input is NoStackOverflowWrapper ? input.value : input) {
    final Map<dynamic, dynamic> m => _convertMapOrNone<K, V>(m),
    final String s => jsonDecodeOrNone<Map<dynamic, dynamic>>(
      s.trim(),
    ).map((d) => _convertMapOrNone<K, V>(d)).flatten(),
    final Monad m => switch (m.rawSync().value) {
      Ok(value: final okValue) => letMapOrNone<K, V>(okValue),
      Err() => const None(),
    },
    _ => const None(),
  };
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

Option<Map<K, Option<V>>> _convertMapOrNone<K extends Object, V extends Object>(
  Map<dynamic, dynamic> map,
) {
  final buffer = <K, Option<V>>{};
  for (final entry in map.entries) {
    final keyOption = letOrNone<K>(entry.key);
    if (keyOption.isNone()) {
      return const None();
    }
    final valueOption = letOrNone<V>(entry.value);
    buffer[keyOption.unwrap()] = valueOption;
  }
  return Some(buffer);
}
