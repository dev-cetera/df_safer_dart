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

import 'let_or_none.dart';

import '../monads/monad/monad.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

Option<Map<K, Option<V>>> letMapOrNone<K extends Object, V extends Object>(dynamic input) {
  if (input is Monad) {
    return switch (input.rawSync().value) {
      Ok(value: final okValue) => letMapOrNone<K, V>(_NoStackOverflowWrapper(okValue)),
      Err() => const None(),
    };
  }

  return switch (input is _NoStackOverflowWrapper ? input.value : input) {
    final Map<dynamic, dynamic> m => Some(_convertMap<K, V>(m)),
    final String s =>
      jsonDecodeOrNone<Map<dynamic, dynamic>>(s.trim()).map((d) => _convertMap<K, V>(d)),
    final Monad m => switch (m.rawSync().value) {
        Ok(value: final okValue) => letMapOrNone<K, V>(okValue),
        Err() => const None(),
      },
    _ => const None(),
  };
}

class _NoStackOverflowWrapper<T> {
  final T value;
  const _NoStackOverflowWrapper(this.value);
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

Map<K, Option<V>> _convertMap<K extends Object, V extends Object>(Map<dynamic, dynamic> map) {
  final entries = map.entries.map((entry) {
    final rawKey = entry.key is Monad ? (entry.key as Monad).rawSync().value.orNull() : entry.key;
    final rawValue =
        entry.value is Monad ? (entry.value as Monad).rawSync().value.orNull() : entry.value;
    final keyOption = letOrNone<K>(rawKey);
    final valueOption = letOrNone<V>(rawValue);
    if (keyOption.isNone()) {
      return const _EmptySentinel();
    }
    return MapEntry(keyOption.unwrap(), valueOption);
  });
  final filteredEntries =
      entries.where((e) => e != const _EmptySentinel()).cast<MapEntry<K, Option<V>>>();

  return Map.fromEntries(filteredEntries);
}

final class _EmptySentinel {
  const _EmptySentinel();
}
