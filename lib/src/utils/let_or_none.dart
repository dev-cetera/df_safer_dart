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

import 'dart:convert' show jsonDecode;

import 'package:df_type/df_type.dart';

import '../_src.g.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

Option<T> letOrNone<T extends Object>(dynamic input) {
  if (input is Some<T>) return input;
  if (input is T) return Some(input);
  if (input == null) return const None();
  if (input is Monad) {
    return switch (input.rawSync().value) {
      Ok(value: final okValue) => letOrNone<T>(_NoStackOverflowWrapper(okValue)),
      Err() => const None(),
    };
  }
  final unwrapped = input is _NoStackOverflowWrapper ? input.value : input;
  return letAsOrNone<T>(() {
    if (typeEquality<T, double>() || typeEquality<T, double?>()) {
      return letDoubleOrNone(unwrapped);
    } else if (typeEquality<T, int>() || typeEquality<T, int?>()) {
      return letIntOrNone(unwrapped);
    } else if (typeEquality<T, bool>() || typeEquality<T, bool?>()) {
      return letBoolOrNone(unwrapped);
    } else if (typeEquality<T, DateTime>() || typeEquality<T, DateTime?>()) {
      return letDateTimeOrNone(unwrapped);
    } else if (typeEquality<T, Uri>() || typeEquality<T, Uri?>()) {
      return letUriOrNone(unwrapped);
    } else if (isSubtype<T, List<dynamic>>()) {
      return letListOrNone<Object>(unwrapped);
    } else if (isSubtype<T, Set<dynamic>>()) {
      return letSetOrNone<Object>(unwrapped);
    } else if (isSubtype<T, Iterable<dynamic>>()) {
      return letIterableOrNone<Object>(unwrapped);
    } else if (isSubtype<T, Map<dynamic, dynamic>>()) {
      return letMapOrNone<Object, Object>(unwrapped);
    } else if (typeEquality<T, String>() || typeEquality<T, String?>()) {
      return letAsStringOrNone(unwrapped);
    }
    return unwrapped;
  }());
}

Option<T> letAsOrNone<T extends Object>(dynamic input) {
  if (input is Monad) {
    return switch (input.rawSync().value) {
      Ok(value: final okValue) => letAsOrNone<T>(_NoStackOverflowWrapper(okValue)),
      Err() => const None(),
    };
  }

  final rawInput = input is _NoStackOverflowWrapper ? input.value : input;
  return rawInput is T ? Some(rawInput) : const None();
}

Option<String> letAsStringOrNone(dynamic input) {
  try {
    return Some(input.toString());
  } catch (_) {
    return const None();
  }
}

Option<T> jsonDecodeOrNone<T extends Object>(String input) {
  try {
    final decoded = jsonDecode(input);
    return decoded is T ? Some(decoded) : const None();
  } catch (e) {
    return const None();
  }
}

Option<num> letNumOrNone(dynamic input) {
  if (input is Monad) {
    return switch (input.rawSync().value) {
      Ok(value: final okValue) => letNumOrNone(_NoStackOverflowWrapper(okValue)),
      Err() => const None(),
    };
  }

  return switch (input is _NoStackOverflowWrapper ? input.value : input) {
    final num value => Some(value),
    final String string => Option.from(num.tryParse(string.trim())),
    _ => const None(),
  };
}

@pragma('vm:prefer-inline')
Option<int> letIntOrNone(dynamic input) {
  return letNumOrNone(input).map((n) => n.toInt());
}

@pragma('vm:prefer-inline')
Option<double> letDoubleOrNone(dynamic input) {
  return letNumOrNone(input).map((n) => n.toDouble());
}

Option<bool> letBoolOrNone(dynamic input) {
  if (input is Monad) {
    return switch (input.rawSync().value) {
      Ok(value: final okValue) => letBoolOrNone(_NoStackOverflowWrapper(okValue)),
      Err() => const None(),
    };
  }

  return switch (input is _NoStackOverflowWrapper ? input.value : input) {
    final bool value => Some(value),
    final String string => Option.from(bool.tryParse(string.trim(), caseSensitive: false)),
    _ => const None(),
  };
}

Option<Uri> letUriOrNone(dynamic input) {
  if (input is Monad) {
    return switch (input.rawSync().value) {
      Ok(value: final okValue) => letUriOrNone(_NoStackOverflowWrapper(okValue)),
      Err() => const None(),
    };
  }

  return switch (input is _NoStackOverflowWrapper ? input.value : input) {
    final Uri value => Some(value),
    final String string => Option.from(Uri.tryParse(string.trim())),
    _ => const None(),
  };
}

Option<DateTime> letDateTimeOrNone(dynamic input) {
  if (input is Monad) {
    return switch (input.rawSync().value) {
      Ok(value: final okValue) => letDateTimeOrNone(_NoStackOverflowWrapper(okValue)),
      Err() => const None(),
    };
  }

  return switch (input is _NoStackOverflowWrapper ? input.value : input) {
    final DateTime value => Some(value),
    final String string => Option.from(DateTime.tryParse(string.trim())),
    _ => const None(),
  };
}

class _NoStackOverflowWrapper<T> {
  final T value;
  const _NoStackOverflowWrapper(this.value);
}
