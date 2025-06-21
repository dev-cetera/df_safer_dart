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

part of '../monad.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// A [Monad] that represents the failure case of a [Result], containing an
/// error [value].
final class Err<T extends Object> extends Result<T> implements Exception {
  /// An optional HTTP status code associated with the error.
  final Option<int> statusCode;

  /// The stack trace captured when the [Err] was created.
  final Trace stackTrace;

  @override
  @protected
  @pragma('vm:prefer-inline')
  Object get value => super.value;

  @pragma('vm:prefer-inline')
  Object get error => value;

  /// Creates a new [Err] from [value] and an optional [statusCode].
  Err(super.value, {int? statusCode})
    : statusCode = Option.from(statusCode),
      stackTrace = Trace.current(),
      super._();

  /// Creates an [Err] from an [ErrModel].
  @pragma('vm:prefer-inline')
  factory Err.fromModel(ErrModel model) {
    final error = model.error;
    return Err(error ?? 'Unknown error!', statusCode: model.statusCode);
  }

  @override
  @pragma('vm:prefer-inline')
  bool isOk() => false;

  @override
  @pragma('vm:prefer-inline')
  bool isErr() => true;

  @override
  @pragma('vm:prefer-inline')
  Err<T> ifOk(@noFuturesAllowed void Function(Ok<T> ok) noFuturesAllowed) {
    return this;
  }

  @override
  @pragma('vm:prefer-inline')
  Err<T> ifErr(@noFuturesAllowed void Function(Err<T> err) noFuturesAllowed) {
    try {
      noFuturesAllowed(this);
      return this;
    } catch (error) {
      return Err(error);
    }
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
    @noFuturesAllowed Result<R> Function(T value) noFuturesAllowed,
  ) {
    return transfErr();
  }

  @override
  @pragma('vm:prefer-inline')
  Err<T> mapOk(@noFuturesAllowed Ok<T> Function(Ok<T> ok) noFuturesAllowed) {
    return this;
  }

  @override
  @pragma('vm:prefer-inline')
  Err<T> mapErr(
    @noFuturesAllowed Err<T> Function(Err<T> err) noFuturesAllowed,
  ) {
    return noFuturesAllowed(this);
  }

  @override
  @pragma('vm:prefer-inline')
  Result<Object> fold(
    @noFuturesAllowed Result<Object>? Function(Ok<T> ok) onOk,
    @noFuturesAllowed Result<Object>? Function(Err<T> err) onErr,
  ) {
    try {
      return onErr(this) ?? this;
    } catch (error) {
      return Err(error);
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

  /// Transforms the `Err`'s generic type from `T` to `R` while preserving the
  /// contained `error`.
  @pragma('vm:prefer-inline')
  Err<R> transfErr<R extends Object>() {
    return Err(value, statusCode: statusCode.orNull());
  }

  /// Converts this [Err] to a data model for serialization.
  ErrModel toModel() {
    final type = 'Err<${T.toString()}>';
    final error = _safeToString(value);
    return ErrModel(
      type: type,
      error: error,
      statusCode: statusCode.orNull(),
      stackTrace: stackTrace.frames.map((e) => e.toString()).toList(),
    );
  }

  /// Converts this [Err] to a JSON map.
  Map<String, dynamic> toJson() {
    final model = toModel();
    return {
      if (model.type != null) 'type': model.type,
      if (model.error != null) 'error': model.error,
      if (model.statusCode != null) 'statusCode': model.statusCode,
      if (model.stackTrace != null) 'stackTrace': model.stackTrace,
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
  Err<R> map<R extends Object>(
    @noFuturesAllowed R Function(T value) noFuturesAllowed,
  ) {
    return transfErr();
  }

  @override
  @protected
  @pragma('vm:prefer-inline')
  Err<R> transf<R extends Object>([
    @noFuturesAllowed R Function(T e)? noFuturesAllowed,
  ]) {
    return transfErr<R>();
  }

  @override
  @pragma('vm:prefer-inline')
  Some<Err<T>> wrapSome() => Some(this);

  @override
  @pragma('vm:prefer-inline')
  Ok<Err<T>> wrapOk() => Ok(this);

  @override
  @pragma('vm:prefer-inline')
  Resolvable<Err<T>> wrapResolvable() => Resolvable(() => this);

  @override
  @pragma('vm:prefer-inline')
  Sync<Err<T>> wrapSync() => Sync.unsafe(Ok(this));

  @override
  @pragma('vm:prefer-inline')
  Async<Err<T>> wrapAsync() => Async.unsafe(Future.value(Ok(this)));

  @override
  @pragma('vm:prefer-inline')
  Err<void> asVoid() => this;

  @override
  @unsafeOrError
  @pragma('vm:prefer-inline')
  String toString() {
    final encoder = const JsonEncoder.withIndent('  ');
    return encoder.convert(toJson());
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

String _safeToString(Object? obj) {
  try {
    return obj.toString();
  } catch (e) {
    assert(false, e);
    return '${obj.runtimeType}@${obj.hashCode.toRadixString(16)}';
  }
}
