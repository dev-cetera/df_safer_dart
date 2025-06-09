//.title
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//
// Dart/Flutter (DF) Packages by DevCetra.com & contributors. The use of this
// source code is governed by an MIT-style license described in the LICENSE
// file located in this project's root directory.
//
// See: https://opensource.org/license/mit
//
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//.title~

import 'package:path/path.dart' as p;
import 'package:stack_trace/stack_trace.dart';

import '../_src.g.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// A utility class for capturing the current code location (file, line,
/// column, member).
///
/// This is useful for debugging and logging purposes, especially when dealing
/// with errors or unexpected states.
final class Here {
  //
  //
  //

  final int initialStackLevel;

  //
  //
  //

  const Here(this.initialStackLevel) : assert(initialStackLevel >= 0);

  /// Returns the [Frame] for the current code location, skipping the initial
  /// stack levels specified by [initialStackLevel].
  ///
  /// Returns `null` if no suitable frame is found.
  Option<Frame> call() {
    final frames = Trace.current().frames;
    for (var i = initialStackLevel; i < frames.length; i++) {
      final frame = frames[i];

      final lineNumber = frame.line;
      final columnNumber = frame.column;
      if (lineNumber != null && columnNumber != null) {
        return Some(frame);
      }
    }
    return const None();
  }

  /// The base path of the code location, typically formatted as
  /// `library/member`.
  ///
  /// This is useful for creating concise identifiers for code locations.
  Option<String> get basepath {
    final frameOpt = call();
    if (frameOpt.isNone()) return const None();
    final frame = frameOpt.unwrap();
    final library = p.basenameWithoutExtension(frame.library);
    final member = frame.member;
    return Some([library, if (member != null) member].join('/'));
  }

  /// The URI of the file in which the code is located.
  ///
  /// This URI will usually have the scheme `dart`, `file`, `http`, or `https`.
  static Option<Uri> get uri {
    return const Here(2)().map((e) => e.uri);
  }

  /// The line number on which the code location is located.
  ///
  /// This can be null, indicating that the line number is unknown or
  /// unimportant.
  static Option<int> get line {
    return const Here(2)().map((e) => Option.fromNullable(e.line)).flatten();
  }

  /// The column number of the code location.
  ///
  /// This can be null, indicating that the column number is unknown or
  /// unimportant.
  static Option<int> get column {
    return const Here(2)().map((e) => Option.fromNullable(e.column)).flatten();
  }

  /// The name of the member in which the code location occurs.
  ///
  /// Anonymous closures are represented as `<fn>` in this member string.
  static Option<String> get member {
    return const Here(2)().map((e) => Option.fromNullable(e.member)).flatten();
  }

  /// Returns a human-friendly description of the library that this stack frame
  /// comes from.
  ///
  /// This will usually be the string form of [uri], but a relative URI will be
  /// used if possible. Data URIs will be truncated.
  static Option<String> get library {
    return const Here(2)().map((e) => e.library);
  }

  /// Returns the name of the package this stack frame comes from, or `null` if
  /// this stack frame doesn't come from a `package:` URL.
  static Option<String> get package {
    return const Here(2)().map((e) => Option.fromNullable(e.package)).flatten();
  }

  /// A human-friendly description of the code location.
  static Option<String> get location {
    return const Here(2)().map((e) => e.location);
  }
}
