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

/// Executes a block of code that is considered UNSAFE, allowing the use of
/// methods like [Outcome.unwrap]. This function provides **no actual safety
/// guarantees**; it only serves as a marker for the
/// `must_use_unsafe_wrapper` / `_or_error` lint and as a signal to developers
/// that the contained code can throw.
///
/// Use it to explicitly acknowledge that you are handling a potentially
/// failing operation *outside* the [Outcome] type system.
///
/// ### Two invocation forms
///
/// **1. Function-call form** — the common one. Returns the block's value:
///
/// ```dart
/// final value = UNSAFE(() => Ok(1).unwrap());
/// ```
///
/// **2. Labeled-statement form** — zero runtime cost (a label in Dart is
/// purely lexical when nothing `break`s out of it). Suitable when you don't
/// need a return value and you're inside a hot path:
///
/// ```dart
/// UNSAFE: {
///   for (final r in results) {
///     someSink.add(r.unwrap());
///   }
/// }
/// ```
///
/// Both forms are recognised by the lint rule.
// ignore: non_constant_identifier_names
T UNSAFE<T>(@mustBeAnonymous @noFutures T Function() block) {
  assert(isSubtype<T, Never>() || !isSubtype<T, Future<Object>>(),
      '$T must never be a Future.');
  return block();
}
