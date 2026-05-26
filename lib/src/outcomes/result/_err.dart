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

part of '../outcome.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// A [Outcome] that represents the failure case of a [Result], containing an
/// error [value].
final class Err<T extends Object> extends Result<T>
    implements SyncImpl<T>, Exception {
  /// An optional HTTP status code associated with the error.
  final Option<int> statusCode;

  /// The stack trace captured when the [Err] was created.
  final Trace stackTrace;

  /// Ordered labels naming the pipeline node(s) that produced this [Err].
  ///
  /// Populated by [`.named(label)`] in the order the chain saw them — the
  /// first entry is the originally-failing step. Empty when no `.named()`
  /// scope has tagged the error.
  ///
  /// Example:
  /// ```dart
  /// final out = fetchUser(id).named('fetch')
  ///   .map(parseJson).named('parse')
  ///   .map(extractCfg).named('extract');
  ///
  /// switch (await out.value) {
  ///   case Err(:final breadcrumbs):
  ///     print('failed at: ${breadcrumbs.join(" → ")}');
  ///   case Ok():
  ///     // ...
  /// }
  /// ```
  final List<String> breadcrumbs;

  @override
  @protected
  @pragma('vm:prefer-inline')
  Object get value => super.value;

  @pragma('vm:prefer-inline')
  Object get error => value;

  /// Creates a new [Err] from [value] and an optional [statusCode].
  Err(
    super.value, {
    int? statusCode,
    StackTrace? stackTrace,
    List<String> breadcrumbs = const [],
  })  : statusCode = Option.from(statusCode),
        // Defensive trace capture. `Trace.from`/`Trace.current` can throw
        // `FormatException` on malformed native stack-trace strings (most
        // visibly on dart2wasm). The whole point of `df_safer_dart` is that
        // error handling never itself throws — so the trace is computed via
        // a safe helper that falls back to an empty `Trace` rather than
        // letting the throw escape every `Err(...)` call site.
        stackTrace = _safeStackTrace(stackTrace),
        // Skip the `List.unmodifiable` allocation when no breadcrumbs were
        // supplied — the default `const []` is already unmodifiable and is
        // the dominant code path.
        breadcrumbs = breadcrumbs.isEmpty
            ? const <String>[]
            : List.unmodifiable(breadcrumbs),
        super._();

  /// Compile-time flag set by dart2wasm. On WASM we cannot use the
  /// `stack_trace` package's `Trace` parsing or formatting — both code paths
  /// reach into the `path` package's `Style.platform` static initializer,
  /// which calls `Uri.base` and hits an unrecoverable SDK assertion (a
  /// WASM-host trap that escapes regular Dart `catch`). The price of touching
  /// any frame's `toString()` is a process crash. Keeping the field type
  /// (`Trace`) stable while substituting an empty `Trace` for the value
  /// preserves the API and means callers can still read `err.stackTrace`
  /// without crashing the isolate — at the cost of no captured frames on
  /// WASM. Stack info there is recoverable via the original `StackTrace`
  /// passed by the caller, if any (we deliberately don't store it on the Err
  /// to keep field shape unchanged).
  static const bool _isDart2Wasm = bool.fromEnvironment('dart.tool.dart2wasm');

  /// Captures a [Trace] from [stackTrace] (or the current call site if null),
  /// falling back to an empty trace if `stack_trace`'s parser throws or if
  /// the host is dart2wasm (see [_isDart2Wasm] for why).
  static Trace _safeStackTrace(StackTrace? stackTrace) {
    if (_isDart2Wasm) return Trace(const []);
    try {
      return stackTrace != null ? Trace.from(stackTrace) : Trace.current();
    } catch (_) {
      return Trace(const []);
    }
  }

  /// Creates an [Err] from an [ErrModel].
  @pragma('vm:prefer-inline')
  factory Err.fromModel(ErrModel model) {
    final error = model.error;
    return Err(
      error ?? 'Error',
      stackTrace: _tryParseStackTrace(model.stackTrace),
      statusCode: model.statusCode,
    );
  }

  static StackTrace? _tryParseStackTrace(List<String>? lines) {
    if (lines == null) return null;
    try {
      return Trace.parse(lines.join('\n')).original;
    } catch (_) {
      return null;
    }
  }

  @override
  @pragma('vm:prefer-inline')
  bool isOk() => false;

  @override
  @pragma('vm:prefer-inline')
  bool isErr() => true;

  @override
  @pragma('vm:prefer-inline')
  Err<T> ifOk(@noFutures void Function(Err<T> self, Ok<T> ok) noFutures) {
    return this;
  }

  @override
  @pragma('vm:prefer-inline')
  Err<T> ifErr(@noFutures void Function(Err<T> self, Err<T> err) noFutures) {
    return Sync(() {
      noFutures(this, this);
      return this;
    }).value.flatten().err().unwrap();
  }

  @override
  @pragma('vm:prefer-inline')
  Some<Err<T>> err() => Some(this);

  @override
  @pragma('vm:prefer-inline')
  None<Ok<T>> ok() => const None();

  @override
  @pragma('vm:prefer-inline')
  T? orNull() => null;

  @override
  @pragma('vm:prefer-inline')
  Result<R> flatMap<R extends Object>(
    @noFutures Result<R> Function(T value) noFutures,
  ) {
    return transfErr();
  }

  @override
  @pragma('vm:prefer-inline')
  Err<T> mapOk(@noFutures Ok<T> Function(Ok<T> ok) noFutures) {
    return this;
  }

  @override
  @pragma('vm:prefer-inline')
  Err<T> mapErr(@noFutures Err<T> Function(Err<T> err) noFutures) {
    // Absorb throws from the user callback so `Err.mapErr` honours the
    // package-wide "no throws outside @unsafeOrError" contract. `on Err
    // catch` preserves a user-thrown `Err` verbatim — statusCode and
    // breadcrumbs survive intact.
    try {
      return noFutures(this);
    } on Err catch (err) {
      return err.transfErr<T>();
    } catch (error, stackTrace) {
      return Err<T>(error, stackTrace: stackTrace);
    }
  }

  @override
  @pragma('vm:prefer-inline')
  Result<Object> fold(
    @noFutures Result<Object>? Function(Ok<T> ok) onOk,
    @noFutures Result<Object>? Function(Err<T> err) onErr,
  ) {
    try {
      return onErr(this) ?? this;
    } on Err catch (err) {
      // Preserve user-thrown Err verbatim — statusCode/breadcrumbs matter.
      return err.transfErr<Object>();
    } catch (error, stackTrace) {
      return Err(error, stackTrace: stackTrace);
    }
  }

  @override
  @pragma('vm:prefer-inline')
  Result<T> okOr(Result<T> other) => other;

  @override
  @pragma('vm:prefer-inline')
  Result<T> errOr(Result<T> other) => this;

  /// Returns an [Option] containing the error if its type matches `E`.
  @pragma('vm:prefer-inline')
  Option<E> matchError<E extends Object>() =>
      value is E ? Some(value as E) : const None();

  /// Transforms the [Err]'s generic type from `T` to `R` while preserving the
  /// contained `error`, original [stackTrace], [statusCode] and [breadcrumbs].
  @pragma('vm:prefer-inline')
  Err<R> transfErr<R extends Object>() {
    return Err(
      value,
      statusCode: statusCode.orNull(),
      stackTrace: stackTrace,
      breadcrumbs: breadcrumbs,
    );
  }

  /// Returns a copy of this [Err] with the given [breadcrumbs] (replacing any
  /// existing breadcrumbs). Used internally by `.named(label)`.
  @pragma('vm:prefer-inline')
  Err<T> withBreadcrumbs(List<String> breadcrumbs) {
    return Err<T>(
      value,
      statusCode: statusCode.orNull(),
      stackTrace: stackTrace,
      breadcrumbs: breadcrumbs,
    );
  }

  /// Converts this [Err] to a data model for serialization.
  ErrModel toModel() {
    final type = 'Err<${T.toString()}>';
    final error = _safeToString(value);
    return ErrModel(
      type: type,
      error: error,
      statusCode: statusCode.orNull(),
      stackTrace: _safeFrameLines(stackTrace),
    );
  }

  /// Converts this [Err] to a JSON map. Includes [breadcrumbs] only when the
  /// list is non-empty so existing consumers see no extra fields.
  Map<String, dynamic> toJson() {
    final model = toModel();
    return {
      if (model.type != null) 'type': model.type,
      if (model.error != null) 'error': model.error,
      if (model.statusCode != null) 'statusCode': model.statusCode,
      if (model.stackTrace != null) 'stackTrace': model.stackTrace,
      if (breadcrumbs.isNotEmpty) 'breadcrumbs': breadcrumbs,
    };
  }

  @override
  @protected
  @unsafeOrError
  @pragma('vm:prefer-inline')
  T unwrap() {
    throw this;
  }

  @override
  @protected
  @pragma('vm:prefer-inline')
  T unwrapOr(T fallback) => fallback;

  @override
  @pragma('vm:prefer-inline')
  Err<R> map<R extends Object>(@noFutures R Function(T value) noFutures) {
    return transfErr();
  }

  @override
  @protected
  @pragma('vm:prefer-inline')
  Err<R> transf<R extends Object>([@noFutures R Function(T e)? noFutures]) {
    return transfErr<R>();
  }

  @override
  @pragma('vm:prefer-inline')
  String toString() {
    try {
      final encoder = const JsonEncoder.withIndent('  ');
      return encoder.convert(toJson());
    } catch (_) {
      // Defensive: on dart2wasm the underlying `Trace.frames` parser can
      // return frames whose `.toString()` itself throws (the WASM-native
      // stack format isn't fully understood by `package:stack_trace`).
      // Fall back to a minimal representation so logging/asserting on an
      // `Err` never crashes the host process — life-critical callers must
      // be able to surface the error, not vanish in a runtime crash.
      return 'Err<$T>(${_safeToString(value)})';
    }
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

String _safeToString(Object? obj) {
  try {
    return obj.toString();
  } catch (_) {
    return '${obj.runtimeType}@${obj.hashCode.toRadixString(16)}';
  }
}

/// Returns one string per frame in [trace], swallowing any per-frame
/// stringification errors. Returns an empty list if the whole `frames`
/// iteration throws — that happens on `dart2wasm` where the native stack
/// format isn't fully parsed by `package:stack_trace`. On dart2wasm we
/// skip iteration entirely, because touching even one `Frame.toString()`
/// can hit a host-level WASM trap (in `path.Style.platform` → `Uri.base`)
/// that escapes ordinary Dart `catch`.
List<String> _safeFrameLines(Trace trace) {
  if (Err._isDart2Wasm) return const [];
  try {
    final out = <String>[];
    for (final f in trace.frames) {
      try {
        out.add(f.toString());
      } catch (_) {
        // Skip the unparseable frame, keep the surrounding ones.
      }
    }
    return out;
  } catch (_) {
    return const [];
  }
}
