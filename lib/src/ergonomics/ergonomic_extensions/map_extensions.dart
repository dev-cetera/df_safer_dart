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

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
//
// General Map Extensions
//
// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

extension $MapGeneralExtensions<K, V extends Object> on Map<K, V> {
  /// Returns this map wrapped in a [Some] if it's not empty,
  /// otherwise returns [None].
  Option<Map<K, V>> get noneIfEmpty {
    return isEmpty ? const None() : Some(this);
  }

  /// Safely gets the value for a given [key], returning an [Option].
  Option<V> getOption(K key) {
    // V does not need to extend Object here because this[key] can be null.
    // Option.from() correctly handles creating a Some<V> or a None<V>.
    return Option.from(this[key]);
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
//
// Monadic Map Extensions
//
// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

extension $MapOfOptionsExtensions<K, V extends Object> on Map<K, Option<V>> {
  /// Creates a new map containing only the entries where the value is a [Some].
  /// The values in the new map are instances of [Some<V>].
  Map<K, Some<V>> whereSome() => Map.fromEntries(
        entries.where((e) => e.value.isSome()).map((e) => MapEntry(e.key, e.value.some().unwrap())),
      );

  /// Creates a new map containing only the entries where the value is a [None].
  Map<K, None<V>> whereNone() => Map.fromEntries(
        entries.where((e) => e.value.isNone()).map((e) => MapEntry(e.key, e.value.none().unwrap())),
      );

  /// Returns a new map containing only the unwrapped values from [Some] entries.
  Map<K, V> get someValues => Map.fromEntries(
        entries.where((e) => e.value.isSome()).map(
              (e) => MapEntry(e.key, e.value.unwrap()),
            ),
      );

  /// Turns a `Map<K, Option<V>>` into an `Option<Map<K, V>>`.
  /// If all values are [Some], it returns a `Some<Map<K, V>>`. If any value
  /// is a [None], it returns [None].
  Option<Map<K, V>> sequence() {
    final buffer = <K, V>{};
    for (final entry in entries) {
      switch (entry.value) {
        case Some(value: final v):
          buffer[entry.key] = v;
        case None():
          return const None();
      }
    }
    return Some(buffer);
  }

  /// Partitions the map into a record containing two maps: one for [Some]
  /// values and one for [None] values.
  MapOptionPartition<K, V> partition() {
    final someParts = <K, V>{};
    final noneKeys = <K>[];
    for (final entry in entries) {
      switch (entry.value) {
        case Some(value: final v):
          someParts[entry.key] = v;
        case None():
          noneKeys.add(entry.key);
      }
    }
    return (someParts: someParts, noneKeys: noneKeys);
  }
}

extension $MapOfResultsExtensions<K, V extends Object> on Map<K, Result<V>> {
  /// Creates a new map containing only the entries where the value is an [Ok].
  /// The values in the new map are instances of [Ok<V>].
  Map<K, Ok<V>> whereOk() => Map.fromEntries(
        entries.where((e) => e.value.isOk()).map((e) => MapEntry(e.key, e.value.ok().unwrap())),
      );

  /// Creates a new map containing only the entries where the value is an [Err].
  /// The values in the new map are instances of [Err<V>].
  Map<K, Err<V>> whereErr() => Map.fromEntries(
        entries.where((e) => e.value.isErr()).map((e) => MapEntry(e.key, e.value.err().unwrap())),
      );

  /// Returns a new map containing only the unwrapped values from [Ok] entries.
  Map<K, V> get okValues => Map.fromEntries(
        entries.where((e) => e.value.isOk()).map(
              (e) => MapEntry(e.key, e.value.unwrap()),
            ),
      );

  /// Turns a `Map<K, Result<V>>` into a `Result<Map<K, V>>`.
  /// If all values are [Ok], it returns an `Ok<Map<K, V>>`. If any value
  /// is an [Err], it returns the first [Err] encountered.
  Result<Map<K, V>> sequence() {
    final buffer = <K, V>{};
    for (final entry in entries) {
      switch (entry.value) {
        case Ok(value: final v):
          buffer[entry.key] = v;
        case Err err:
          return err.transfErr();
      }
    }
    return Ok(buffer);
  }

  /// Partitions the map into a record containing two maps: one for [Ok]
  /// values and one for [Err] values.
  MapResultPartition<K, V> partition() {
    final okParts = <K, V>{};
    final errParts = <K, Err<V>>{};
    for (final entry in entries) {
      switch (entry.value) {
        case Ok(value: final v):
          okParts[entry.key] = v;
        case Err err:
          errParts[entry.key] = err.transfErr();
      }
    }
    return (okParts: okParts, errParts: errParts);
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
//
// Partition Typedefs
//
// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// The result of partitioning a `Map<K, Option<V>>`.
typedef MapOptionPartition<K, V extends Object> = ({
  Map<K, V> someParts,
  List<K> noneKeys,
});

/// The result of partitioning a `Map<K, Result<V>>`.
typedef MapResultPartition<K, V extends Object> = ({
  Map<K, V> okParts,
  Map<K, Err<V>> errParts,
});
