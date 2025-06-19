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

import 'package:df_safer_dart_annotations/df_safer_dart_annotations.dart';

import '/df_safer_dart.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// Executes a block of code that is considered UNSAFE, allowing the use of
/// methods like `unwrap()`. This function provides no actual safety guarantees;
/// it only serves as a marker for linter rules and to signal to developers
/// that the contained code can throw exceptions from monad operations.
///
/// Use this to explicitly acknowledge that you are handling a potentially
/// failing operation outside the monadic context.
T UNSAFE<T>(@mustBeAnonymous @noFuturesAllowed T Function() block) {
  assert(!_isSubtype<T, Future<Object>>(), '$T must never be a Future.');
  try {
    return block();
  } catch (e) {
    const Here(2).call().ifSome((e) {
      final location = e.value.location;
      assert(false, 'UNSAFE throw at: $location');
    }).end();
    rethrow;
  }
}

@pragma('vm:prefer-inline')
bool _isSubtype<TChild, TParent>() => <TChild>[] is List<TParent>;
