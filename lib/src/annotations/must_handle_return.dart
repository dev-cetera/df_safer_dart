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

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// An annotation used to mark a function whose return value must be handled.
///
/// When a function is annotated with `@mustHandleReturn`, the Dart static
/// analyzer will issue a warning if the function is called and its return value
/// is not used (i.e., not assigned to a variable, passed to another function,
/// or used in an expression).
///
/// This is particularly useful for functions that return a `Result`, `Option`,
/// or `Resolvable` where ignoring the result can lead to unhandled errors or
/// unexpected behavior.
///
/// ### Example
///
/// ```dart
/// @mustHandleReturn
/// Result<int> safeDivide(int a, int b) {
///   if (b == 0) {
///     return Err('Cannot divide by zero');
///   }
///   return Ok(a ~/ b);
/// }
///
/// void main() {
///   // GOOD: The result is handled.
///   final result = safeDivide(10, 2);
///   result.ifOk((ok) => print('Result: ${ok.value}'));
///
///   // BAD: This will trigger a lint warning because the Result is discarded.
///   safeDivide(10, 0);
/// }
/// ```
const mustHandleReturn = MustHandleReturn();

/// The class that enables the `@mustHandleReturn` annotation.
class MustHandleReturn {
  /// Creates a new `MustHandleReturn` instance.
  const MustHandleReturn();
}
