// ignore_for_file: must_use_unsafe_wrapper_or_error
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

import '../monads/monad/monad.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

extension $NoneIfEmptyOnMapExtension<K, V> on Map<K, V> {
  /// Returns this map wrapped in a [Some] if it's not empty,
  /// otherwise returns [None].
  Option<Map<K, V>> get noneIfEmpty {
    return isEmpty ? const None() : Some(this);
  }
}

extension $GetOptionOnMapExtension<K, V extends Object> on Map<K, V> {
  /// Safely gets the value for a given [key], returning an [Option<V>].
  Option<V> getOption(K key) {
    if (containsKey(key)) {
      return Some(this[key]!);
    }
    return const None();
  }
}

extension $NonNoneValuesOnMapExtension<K, V extends Object> on Map<K, Option<V>> {
  /// **Filters.** Returns a new map containing only entries where the value is a [Some].
  Map<K, V> get nonNoneValues => Map.fromEntries(
        entries.where((e) => e.value.isSome()).map(
              (e) => MapEntry(e.key, e.value.unwrap()),
            ),
      );

  /// **Combines.** If all values are [Some], returns a `Some<Map<K, V>>`.
  /// If any value is [None], returns [None].
  Option<Map<K, V>> get nonNoneAll {
    final buffer = <K, V>{};
    for (final entry in entries) {
      if (entry.value.isNone()) return const None();
      buffer[entry.key] = entry.value.unwrap();
    }
    return Some(buffer);
  }
}

extension $NonNoneKeysOnMapExtension<K extends Object, V> on Map<Option<K>, V> {
  /// **Filters.** Returns a new map containing only entries where the key is a [Some].
  Map<K, V> get nonNoneKeys => Map.fromEntries(
        entries.where((e) => e.key.isSome()).map(
              (e) => MapEntry(e.key.unwrap(), e.value),
            ),
      );

  /// **Combines.** If all keys are [Some], returns a `Some<Map<K, V>>`.
  /// If any key is [None], returns [None].
  Option<Map<K, V>> get nonNoneAll {
    final buffer = <K, V>{};
    for (final entry in entries) {
      if (entry.key.isNone()) return const None();
      buffer[entry.key.unwrap()] = entry.value;
    }
    return Some(buffer);
  }
}

extension $NonNoneOnMapExtension<K extends Object, V extends Object> on Map<Option<K>, Option<V>> {
  /// **Filters.** Returns a new map containing only entries where both key and value are [Some].
  Map<K, V> get nonNone => Map.fromEntries(
        entries.where((e) => e.key.isSome() && e.value.isSome()).map(
              (e) => MapEntry(e.key.unwrap(), e.value.unwrap()),
            ),
      );

  /// **Combines.** If all keys and values are [Some], returns a `Some<Map<K, V>>`.
  /// If any key or value is [None], returns [None].
  Option<Map<K, V>> get nonNoneAll {
    final buffer = <K, V>{};
    for (final entry in entries) {
      if (entry.key.isNone() || entry.value.isNone()) return const None();
      buffer[entry.key.unwrap()] = entry.value.unwrap();
    }
    return Some(buffer);
  }
}

extension $NonErrValuesOnMapExtension<K, V extends Object> on Map<K, Result<V>> {
  /// **Filters.** Returns a new map containing only entries where the value is an [Ok].
  Map<K, V> get nonErrValues => Map.fromEntries(
        entries.where((e) => e.value.isOk()).map(
              (e) => MapEntry(e.key, e.value.unwrap()),
            ),
      );

  /// **Combines.** If all values are [Ok], returns a `Result<Map<K, V>>`.
  /// If any value is an [Err], returns the first [Err] found.
  Result<Map<K, V>> get nonErrAll {
    final buffer = <K, V>{};
    for (final entry in entries) {
      if (entry.value.isErr()) return entry.value.err().unwrap().transfErr();
      buffer[entry.key] = entry.value.unwrap();
    }
    return Ok(buffer);
  }
}

extension $NonErrKeysOnMapExtension<K extends Object, V> on Map<Result<K>, V> {
  /// **Filters.** Returns a new map containing only entries where the key is an [Ok].
  Map<K, V> get nonErrKeys => Map.fromEntries(
        entries.where((e) => e.key.isOk()).map(
              (e) => MapEntry(e.key.unwrap(), e.value),
            ),
      );

  /// **Combines.** If all keys are [Ok], returns a `Result<Map<K, V>>`.
  /// If any key is an [Err], returns the first [Err] found.
  Result<Map<K, V>> get nonErrAll {
    final buffer = <K, V>{};
    for (final entry in entries) {
      if (entry.key.isErr()) return entry.key.err().unwrap().transfErr();
      buffer[entry.key.unwrap()] = entry.value;
    }
    return Ok(buffer);
  }
}

extension $NonErrOnMapExtension<K extends Object, V extends Object> on Map<Result<K>, Result<V>> {
  /// **Filters.** Returns a new map containing only entries where both key and value are [Ok].
  Map<K, V> get nonErr => Map.fromEntries(
        entries.where((e) => e.key.isOk() && e.value.isOk()).map(
              (e) => MapEntry(e.key.unwrap(), e.value.unwrap()),
            ),
      );

  /// **Combines.** If all keys and values are [Ok], returns a `Result<Map<K, V>>`.
  /// If any key or value is an [Err], returns the first [Err] found.
  Result<Map<K, V>> get nonErrAll {
    final buffer = <K, V>{};
    for (final entry in entries) {
      if (entry.key.isErr()) return entry.key.err().unwrap().transfErr();
      if (entry.value.isErr()) return entry.value.err().unwrap().transfErr();
      buffer[entry.key.unwrap()] = entry.value.unwrap();
    }
    return Ok(buffer);
  }
}
