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

import '/src/utils/_no_stack_overflow_wrapper.dart' show NoStackOverflowWrapper;

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// Attempts to convert a dynamic [input] to the specified type [T], returning
/// [None] on failure.
///
/// This is a high-level dispatcher that uses more specific `let...OrNone`
/// helpers based on the target type [T].
///
/// Supported types:
///
/// - Any sync [Outcome] chain.
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
Option<T> letOrNone<T extends Object>(dynamic input) {
  assert(
    !(isSubtype<T, List<dynamic>>() && !isSubtype<List<dynamic>, T>()) &&
        !(isSubtype<T, Set<dynamic>>() && !isSubtype<Set<dynamic>, T>()) &&
        !(isSubtype<T, Iterable<dynamic>>() &&
            !isSubtype<Iterable<dynamic>, T>()) &&
        !(isSubtype<T, Map<dynamic, dynamic>>() &&
            !isSubtype<Map<dynamic, dynamic>, T>()),
    'letOrNone<$T> cannot be used with specific collection types due to type safety. '
    'Only generic collection types are supported.',
  );
  // 1. Unwrap any Outcome to get the raw value.
  if (input is Outcome) {
    return switch (input.rawSync().value) {
      Ok(value: final okValue) => letOrNone<T>(NoStackOverflowWrapper(okValue)),
      Err() => const None(),
    };
  }
  final rawInput = input is NoStackOverflowWrapper ? input.value : input;

  // 2. Handle null and direct type matches upfront for performance.
  if (rawInput is T) return Some(rawInput);
  if (rawInput == null) return const None();

  // 3. Dispatch to specific conversion logic based on the target type.
  //    The dispatch is inline (not an IIFE) so the closure allocation that
  //    a `() { ... }()` would force is avoided on the hot path.
  final Object? result;
  if (typeEquality<T, double>() || typeEquality<T, double?>()) {
    result = letDoubleOrNone(rawInput);
  } else if (typeEquality<T, int>() || typeEquality<T, int?>()) {
    result = letIntOrNone(rawInput);
  } else if (typeEquality<T, bool>() || typeEquality<T, bool?>()) {
    result = letBoolOrNone(rawInput);
  } else if (typeEquality<T, DateTime>() || typeEquality<T, DateTime?>()) {
    result = letDateTimeOrNone(rawInput);
  } else if (typeEquality<T, Uri>() || typeEquality<T, Uri?>()) {
    result = letUriOrNone(rawInput);
  } else if (isSubtype<T, List<dynamic>>()) {
    result = letListOrNone<Object>(rawInput);
  } else if (isSubtype<T, Set<dynamic>>()) {
    result = letSetOrNone<Object>(rawInput);
  } else if (isSubtype<T, Iterable<dynamic>>()) {
    result = letIterableOrNone<Object>(rawInput);
  } else if (isSubtype<T, Map<dynamic, dynamic>>()) {
    result = letMapOrNone<Object, Object>(rawInput);
  } else if (typeEquality<T, String>() || typeEquality<T, String?>()) {
    result = letAsStringOrNone(rawInput);
  } else {
    result = rawInput;
  }

  // 4. Perform a final safe cast on the result of the conversion.
  return letAsOrNone<T>(result);
}

/// Casts [input] to type [T], returning [None] on failure.
///
/// Supported types:
///
/// - Any sync [Outcome] chain.
/// - [Object]
Option<T> letAsOrNone<T extends Object>(dynamic input) {
  if (input is Outcome) {
    return switch (input.rawSync().value) {
      Ok(value: final okValue) => letAsOrNone<T>(
          NoStackOverflowWrapper(okValue),
        ),
      Err() => const None(),
    };
  }
  final rawInput = input is NoStackOverflowWrapper ? input.value : input;
  return rawInput is T ? Some(rawInput) : const None();
}

/// Converts [input] to [String], returning [None] on failure.
///
/// Supported types:
///
/// - Any sync [Outcome] chain.
/// - [Object]
Option<String> letAsStringOrNone(dynamic input) {
  if (input is Outcome) {
    return switch (input.rawSync().value) {
      Ok(value: final okValue) => letAsStringOrNone(
          NoStackOverflowWrapper(okValue),
        ),
      Err() => const None(),
    };
  }
  final rawInput = input is NoStackOverflowWrapper ? input.value : input;
  // Treat `null` as absence (None) rather than producing the literal string
  // "null" — `null.toString() == 'null'` is rarely what callers want.
  if (rawInput == null) return const None();

  try {
    return Some(rawInput.toString());
  } catch (_) {
    return const None();
  }
}

/// Parses a JSON [input] into an object of type [T], returning [None] on
/// failure.
///
/// Supported types:
///
/// - Any sync [Outcome] chain.
/// - [Object]
Option<T> jsonDecodeOrNone<T extends Object>(dynamic input) {
  return letAsStringOrNone(input).map((rawInput) {
    try {
      final decoded = const JsonDecoder().convert(rawInput);
      return decoded is T ? Some<T>(decoded) : None<T>();
    } catch (e, _) {
      return None<T>();
    }
  }).flatten();
}

/// Converts [input] to [num], returning [None] on failure.
///
/// Supported types:
///
/// - Any sync [Outcome] chain.
/// - [String]
/// - [num]
/// - [double]
/// - [int]
/// - [String]
Option<num> letNumOrNone(dynamic input) {
  if (input is Outcome) {
    return switch (input.rawSync().value) {
      Ok(value: final okValue) => letNumOrNone(NoStackOverflowWrapper(okValue)),
      Err() => const None(),
    };
  }
  return switch (input is NoStackOverflowWrapper ? input.value : input) {
    final num value => Some(value),
    final String string => Option.from(num.tryParse(string.trim())),
    _ => const None(),
  };
}

/// Converts [input] to [int], returning [None] on failure.
///
/// Returns [None] for `NaN`, `Infinity`, `-Infinity`, and any value outside
/// the signed 64-bit integer range — converting these via `num.toInt()`
/// would throw `UnsupportedError` or silently saturate.
///
/// Supported types:
///
/// - Any sync [Outcome] chain.
/// - [String]
/// - [num]
/// - [double]
/// - [int]
/// - [String]
Option<int> letIntOrNone(dynamic input) {
  return letNumOrNone(input).flatMap((n) {
    if (n is int) {
      // dart2js quirk: every integer-valued double satisfies `is int`,
      // including `double.infinity` and out-of-range doubles. On the VM and
      // WASM the two types are disjoint, but on dart2js they collapse into a
      // single JS-Number — so we apply the same finite + int64-range guards
      // we use on a raw double whenever the runtime additionally reports the
      // value as a double (true only on dart2js).
      if (n is double) {
        if (!n.isFinite) return const None();
        if (n >= 9223372036854775808.0 || n < -9223372036854775808.0) {
          return const None();
        }
      }
      return Some(n);
    }
    final d = n.toDouble();
    if (!d.isFinite) return const None();
    // int64 bounds. 9.223372036854776e18 is the smallest double > int64.max,
    // and -9.223372036854776e18 is the largest double < int64.min, so we
    // reject values at or beyond those magnitudes.
    if (d >= 9223372036854775808.0 || d < -9223372036854775808.0) {
      return const None();
    }
    return Some(d.toInt());
  });
}

/// Converts [input] to [double], returning [None] on failure.
///
/// Supported types:
///
/// - Any sync [Outcome] chain.
/// - [String]
/// - [num]
/// - [double]
/// - [int]
/// - [String]
@pragma('vm:prefer-inline')
Option<double> letDoubleOrNone(dynamic input) {
  return letNumOrNone(input).map((n) => n.toDouble());
}

/// Converts [input] to [bool], returning [None] on failure.
///
/// Supported types:
///
/// - Any sync [Outcome] chain.
/// - [String]
/// - [bool]
Option<bool> letBoolOrNone(dynamic input) {
  if (input is Outcome) {
    return switch (input.rawSync().value) {
      Ok(value: final okValue) => letBoolOrNone(
          NoStackOverflowWrapper(okValue),
        ),
      Err() => const None(),
    };
  }
  return switch (input is NoStackOverflowWrapper ? input.value : input) {
    final bool value => Some(value),
    final String string => Option.from(
        bool.tryParse(string.trim(), caseSensitive: false),
      ),
    _ => const None(),
  };
}

/// Converts [input] to [Uri], returning [None] on failure.
///
/// Supported types:
///
/// - Any sync [Outcome] chain.
/// - [String]
/// - [Uri]
Option<Uri> letUriOrNone(dynamic input) {
  if (input is Outcome) {
    return switch (input.rawSync().value) {
      Ok(value: final okValue) => letUriOrNone(NoStackOverflowWrapper(okValue)),
      Err() => const None(),
    };
  }
  return switch (input is NoStackOverflowWrapper ? input.value : input) {
    final Uri value => Some(value),
    final String string => Option.from(Uri.tryParse(string.trim())),
    _ => const None(),
  };
}

/// Converts [input] to [bool], returning [None] on failure.
///
/// Supported types:
///
/// - Any sync [Outcome] chain.
/// - [String]
/// - [DateTime]
Option<DateTime> letDateTimeOrNone(dynamic input) {
  if (input is Outcome) {
    return switch (input.rawSync().value) {
      Ok(value: final okValue) => letDateTimeOrNone(
          NoStackOverflowWrapper(okValue),
        ),
      Err() => const None(),
    };
  }
  return switch (input is NoStackOverflowWrapper ? input.value : input) {
    final DateTime value => Some(value),
    final String string => Option.from(DateTime.tryParse(string.trim())),
    _ => const None(),
  };
}
