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

  final int level;

  //
  //
  //

  const Here(this.level) : assert(level >= 0);

  /// Returns the [Frame] for the current code location, skipping the initial
  /// stack levels specified by [level].
  ///
  /// Returns `null` if no suitable frame is found.
  Option<Frame> call() {
    final frames = Trace.current(level).frames;
    for (var n = 0; n < frames.length; n++) {
      final frame = frames[n];
      final lineNumber = frame.line;
      final columnNumber = frame.column;
      if (lineNumber != null && columnNumber != null) {
        return Some(frame);
      }
    }
    return const None();
  }

  /// A string representing the basepath location of the call.
  Option<String> get basepath => call().map(
        (e) => [
          p.basenameWithoutExtension(e.library),
          if (e.member != null) e.member,
        ].join('/'),
      );

  /// A string representing the location of the call.
  Option<String> get location => call().map((e) => e.location);
}
