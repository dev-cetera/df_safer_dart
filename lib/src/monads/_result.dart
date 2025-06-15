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

part of 'monad.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// A [Monad] that represents the result of an operation: every [Result] is
/// either [Ok] and contains a success value, or [Err] and contains an error
/// value.
sealed class Result<T extends Object> extends Monad<T> {
  const Result._();

  /// Returns `this` as a base [Result] type.
  @pragma('vm:prefer-inline')
  Result<T> asResult() => this;

  /// Returns `true` if this [Result] is an [Ok].
  bool isOk();

  /// Returns `true` if this [Result] is an [Err].
  bool isErr();

  /// Performs a side-effect with the contained value if this is an [Ok].
  Result<T> ifOk(void Function(Ok<T> ok) noFuturesInHere);

  /// Performs a side-effect with the contained error if this is an [Err].
  Result<T> ifErr(void Function(Err<T> err) noFuturesInHere);

  /// Safely gets the [Err] instance.
  /// Returns a [Some] on [Err], or a [None] on [Ok].
  Option<Err<T>> err();

  /// Safely gets the [Ok] instance.
  /// Returns a [Some] on [Ok], or a [None] on [Err].
  Option<Ok<T>> ok();

  /// Returns the contained [Ok] value or `null`.
  T? orNull();

  /// Maps a `Result<T>` to `Result<R>` by applying a function that returns
  /// another [Result].
  Result<R> flatMap<R extends Object>(Result<R> Function(T value) mapper);

  /// Transforms the inner [Ok] instance if this is an [Ok].
  Result<T> mapOk(Ok<T> Function(Ok<T> ok) mapper);

  /// Transforms the inner [Err] instance if this is an [Err].
  Result<T> mapErr(Err<T> Function(Err<T> err) mapper);

  /// Folds the two cases of this [Result] into a single new [Result].
  Result<Object> fold(
    Result<Object>? Function(Ok<T> ok) onOk,
    Result<Object>? Function(Err<T> err) onErr,
  );

  /// Exhaustively handles both [Ok] and [Err] cases, returning a value `R`.
  R match<R extends Object>(
    R Function(T value) onOkUnsafe,
    R Function(Err<T> err) onErrUnsafe,
  );

  /// Combines two [Result] instances.
  /// If both are [Ok], returns a tuple of their values, otherwise returns `None`.
  (Option<T>, Option<R>) and<R extends Object>(Result<R> other);

  /// Returns this if it's [Ok], otherwise returns the `other` [Result].
  Result<Object> okOr<R extends Object>(Result<R> other);

  /// Returns this if it's [Err], otherwise returns the `other` [Result].
  Result<Object> errOr<R extends Object>(Result<R> other);

  @override
  T unwrap();

  @override
  T unwrapOr(T fallback);

  @override
  @pragma('vm:prefer-inline')
  T unwrapOrElse(T Function() unsafe) => unwrapOr(unsafe());

  @override
  Result<R> map<R extends Object>(R Function(T value) mapper);

  @override
  Result<R> transf<R extends Object>([R Function(T e)? transformer]);

  @override
  @pragma('vm:prefer-inline')
  Some<Result<T>> wrapSome() => Some(this);

  @override
  @pragma('vm:prefer-inline')
  Ok<Result<T>> wrapOk() => Ok(this);

  @override
  @pragma('vm:prefer-inline')
  Resolvable<Result<T>> wrapResolvable() => Resolvable(() => this);

  @override
  @pragma('vm:prefer-inline')
  Sync<Result<T>> wrapSync() => Sync.value(Ok(this));

  @override
  @pragma('vm:prefer-inline')
  Async<Result<T>> wrapAsync() => Async.value(Future.value(Ok(this)));
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// A [Monad] that represents the success case of a [Result], containing a
/// [value].
final class Ok<T extends Object> extends Result<T> {
  /// The contained value.
  final T value;

  const Ok(this.value) : super._();

  @override
  @pragma('vm:prefer-inline')
  bool isOk() => true;

  @override
  @pragma('vm:prefer-inline')
  bool isErr() => false;

  @override
  @pragma('vm:prefer-inline')
  Result<T> ifOk(void Function(Ok<T> ok) noFuturesInHere) {
    try {
      noFuturesInHere(this);
      return this;
    } catch (error) {
      return Err(error);
    }
  }

  @override
  @pragma('vm:prefer-inline')
  Ok<T> ifErr(void Function(Err<T> err) noFuturesInHere) => this;

  @override
  @pragma('vm:prefer-inline')
  None<Err<T>> err() => const None();

  @override
  @pragma('vm:prefer-inline')
  Some<Ok<T>> ok() => Some(this);

  @override
  @pragma('vm:prefer-inline')
  T? orNull() => value;

  @override
  @pragma('vm:prefer-inline')
  Result<R> flatMap<R extends Object>(Result<R> Function(T value) mapper) {
    return mapper(unwrap());
  }

  @override
  @pragma('vm:prefer-inline')
  Ok<T> mapOk(Ok<T> Function(Ok<T> ok) mapper) => mapper(this);

  @override
  @pragma('vm:prefer-inline')
  Ok<T> mapErr(Err<T> Function(Err<T> err) mapper) => this;

  @override
  @pragma('vm:prefer-inline')
  Result<Object> fold(
    Result<Object>? Function(Ok<T> ok) onOk,
    Result<Object>? Function(Err<T> err) onErr,
  ) {
    try {
      return onOk(this) ?? this;
    } catch (error) {
      return Err(error);
    }
  }

  @override
  @pragma('vm:prefer-inline')
  R match<R extends Object>(
    R Function(T value) onOkUnsafe,
    R Function(Err<T> err) onErrUnsafe,
  ) {
    return onOkUnsafe(this.value);
  }

  @override
  @pragma('vm:prefer-inline')
  (Option<T>, Option<R>) and<R extends Object>(Result<R> other) {
    if (other.isOk()) {
      return (Some(this.unwrap()), Some(other.unwrap()));
    } else {
      return (const None(), const None());
    }
  }

  @override
  @pragma('vm:prefer-inline')
  Ok<T> okOr<R extends Object>(Result<R> other) => this;

  @override
  @pragma('vm:prefer-inline')
  Result<R> errOr<R extends Object>(Result<R> other) => other;

  @override
  @pragma('vm:prefer-inline')
  T unwrap() => value;

  @override
  @pragma('vm:prefer-inline')
  T unwrapOr(T fallback) => value;

  @override
  @pragma('vm:prefer-inline')
  Result<R> map<R extends Object>(R Function(T value) mapper) =>
      Ok(mapper(value));

  @override
  Result<R> transf<R extends Object>([R Function(T e)? transformer]) {
    try {
      final a = unwrap();
      final b = transformer?.call(a) ?? a as R;
      return Ok(b);
    } catch (e) {
      assert(false, e);
      return Err('Cannot transform $T to $R.');
    }
  }

  @override
  @pragma('vm:prefer-inline')
  Some<Ok<T>> wrapSome() => Some(this);

  @override
  @pragma('vm:prefer-inline')
  Ok<Ok<T>> wrapOk() => Ok(this);

  @override
  @pragma('vm:prefer-inline')
  Resolvable<Ok<T>> wrapResolvable() => Resolvable(() => this);

  @override
  @pragma('vm:prefer-inline')
  Sync<Ok<T>> wrapSync() => Sync.value(Ok(this));

  @override
  @pragma('vm:prefer-inline')
  Async<Ok<T>> wrapAsync() => Async.value(Future.value(Ok(this)));

  @override
  @pragma('vm:prefer-inline')
  List<Object?> get props => [this.value];

  @override
  @pragma('vm:prefer-inline')
  bool? get stringify => false;
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// A [Monad] that represents the failure case of a [Result], containing an
/// [error].
final class Err<T extends Object> extends Result<T> implements Exception {
  /// The contained error object.
  final Object error;

  /// An optional HTTP status code associated with the error.
  final Option<int> statusCode;

  /// The stack trace captured when the [Err] was created.
  final Trace stackTrace;

  /// Creates a new [Err] from [error] and an optional [statusCode].
  Err(this.error, {int? statusCode})
    : statusCode = Option.fromNullable(statusCode),
      stackTrace = Trace.current(),
      super._();

  /// Creates an [Err] from an [ErrModel].
  @pragma('vm:prefer-inline')
  factory Err.fromModel(ErrModel model) {
    final error = model.error;
    if (error == null) {
      return Err('Error is null!');
    }
    return Err(error, statusCode: model.statusCode);
  }

  @override
  @pragma('vm:prefer-inline')
  bool isOk() => false;

  @override
  @pragma('vm:prefer-inline')
  bool isErr() => true;

  @override
  @pragma('vm:prefer-inline')
  Err<T> ifOk(void Function(Ok<T> ok) noFuturesInHere) => this;

  @override
  @pragma('vm:prefer-inline')
  Err<T> ifErr(void Function(Err<T> err) noFuturesInHere) {
    try {
      noFuturesInHere(this);
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
  Result<R> flatMap<R extends Object>(Result<R> Function(T value) mapper) {
    return transfErr();
  }

  @override
  @pragma('vm:prefer-inline')
  Err<T> mapOk(Ok<T> Function(Ok<T> ok) mapper) => this;

  @override
  @pragma('vm:prefer-inline')
  Err<T> mapErr(Err<T> Function(Err<T> err) mapper) => mapper(this);

  @override
  @pragma('vm:prefer-inline')
  Result<Object> fold(
    Result<Object>? Function(Ok<T> ok) onOk,
    Result<Object>? Function(Err<T> err) onErr,
  ) {
    try {
      return onErr(this) ?? this;
    } catch (error) {
      return Err(error);
    }
  }

  @override
  @pragma('vm:prefer-inline')
  R match<R extends Object>(
    R Function(T value) onUnsafeOk,
    R Function(Err<T> err) onUnsafeErr,
  ) {
    return onUnsafeErr(this);
  }

  @override
  @pragma('vm:prefer-inline')
  (None<T>, None<R>) and<R extends Object>(Result<R> other) {
    return (const None(), const None());
  }

  @override
  @pragma('vm:prefer-inline')
  Result<R> okOr<R extends Object>(Result<R> other) => other;

  @override
  @pragma('vm:prefer-inline')
  Result<T> errOr<R extends Object>(Result<R> other) => this;

  /// Returns an [Option] containing the error if its type matches `E`.
  @pragma('vm:prefer-inline')
  Option<E> matchError<E extends Object>() =>
      error is E ? Some(error as E) : NONE;

  /// Transforms the `Err`'s generic type from `T` to `R` while preserving the
  /// contained `error`.
  @pragma('vm:prefer-inline')
  Err<R> transfErr<R extends Object>() {
    return Err(error, statusCode: statusCode.orNull());
  }

  /// Converts this [Err] to a data model for serialization.
  ErrModel toModel() {
    final type = 'Err<${T.toString()}>';
    final error = _safeToString(this.error);
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
  @pragma('vm:prefer-inline')
  T unwrap() {
    throw this;
  }

  @override
  @pragma('vm:prefer-inline')
  T unwrapOr(T fallback) => fallback;

  @override
  @pragma('vm:prefer-inline')
  Err<R> map<R extends Object>(R Function(T value) mapper) {
    return transfErr();
  }

  @override
  @pragma('vm:prefer-inline')
  Err<R> transf<R extends Object>([R Function(T e)? transformer]) {
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
  Sync<Err<T>> wrapSync() => Sync.value(Ok(this));

  @override
  @pragma('vm:prefer-inline')
  Async<Err<T>> wrapAsync() => Async.value(Future.value(Ok(this)));

  @override
  @pragma('vm:prefer-inline')
  String toString() {
    try {
      final encoder = const JsonEncoder.withIndent('  ');
      return encoder.convert(toJson());
    } catch (e) {
      // This should never happen!
      assert(false, e);
      return '{}';
    }
  }

  @override
  @pragma('vm:prefer-inline')
  List<Object?> get props => [error, statusCode];

  @override
  @pragma('vm:prefer-inline')
  bool? get stringify => false;
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
