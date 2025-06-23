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

extension $SaferString on String {
  // Returns this string wrapped in a [Some] if it's not empty,
  /// otherwise returns [None].
  Option<String> get noneIfEmpty {
    return Option.from(isEmpty ? null : this);
  }

  /// Returns the first character as a [Some], or [None] if the string is empty.
  Option<String> get firstOrNone => isEmpty ? const None() : Some(this[0]);

  /// Returns the last character as a [Some], or [None] if the string is empty.
  Option<String> get lastOrNone => isEmpty ? const None() : Some(this[length - 1]);

  /// Returns the character at the given [index] as a [Some], or [None] if the
  /// index is out of bounds.
  Option<String> elementAtOrNone(int index) {
    if (index < 0 || index >= length) {
      return const None();
    }
    return Some(this[index]);
  }
}
