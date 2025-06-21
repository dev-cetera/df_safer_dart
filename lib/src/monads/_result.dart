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
  /// Combines 2 [Result] monads into 1 containing a tuple of their values if
  /// all are [Ok].
  ///
  /// If any are [Err], applies [onErr] function to combine errors.
  static Result<(T1, T2)> zip2<T1 extends Object, T2 extends Object>(
    Result<T1> r1,
    Result<T2> r2, [
    @noFuturesAllowed Err<(T1, T2)> Function(Result<T1>, Result<T2>)? onErr,
  ]) {
    switch ((r1, r2)) {
      case (Ok(value: final v1), Ok(value: final v2)):
        return Ok((v1, v2));
      default:
        if (onErr != null) {
          return onErr(r1, r2);
        } else {
          return [r1, r2].whereType<Err>().first.transfErr();
        }
    }
  }

  /// Combines 3 [Result] monads into 1 containing a tuple of their values if
  /// all are [Ok].
  ///
  /// If any are [Err], applies [onErr] function to combine errors.
  static Result<(T1, T2, T3)> zip3<T1 extends Object, T2 extends Object, T3 extends Object>(
    Result<T1> r1,
    Result<T2> r2,
    Result<T3> r3, [
    @noFuturesAllowed Err<(T1, T2, T3)> Function(Result<T1>, Result<T2>, Result<T3>)? onErr,
  ]) {
    switch ((r1, r2, r3)) {
      case (Ok(value: final v1), Ok(value: final v2), Ok(value: final v3)):
        return Ok((v1, v2, v3));
      default:
        if (onErr != null) {
          return onErr(r1, r2, r3);
        } else {
          return [r1, r2, r3].whereType<Err>().first.transfErr();
        }
    }
  }

  const Result._(super.value);

  /// Returns `this` as a base [Result] type.
  @pragma('vm:prefer-inline')
  Result<T> asResult() => this;

  /// Returns `true` if this [Result] is an [Ok].
  bool isOk();

  /// Returns `true` if this [Result] is an [Err].
  bool isErr();

  /// Performs a side-effect with the contained value if this is an [Ok].
  Result<T> ifOk(@noFuturesAllowed void Function(Ok<T> ok) noFuturesAllowed);

  /// Performs a side-effect with the contained error if this is an [Err].
  Result<T> ifErr(@noFuturesAllowed void Function(Err<T> err) noFuturesAllowed);

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
  Result<R> flatMap<R extends Object>(
    @noFuturesAllowed Result<R> Function(T value) noFuturesAllowed,
  );

  /// Transforms the inner [Ok] instance if this is an [Ok].
  Result<T> mapOk(@noFuturesAllowed Ok<T> Function(Ok<T> ok) noFuturesAllowed);

  /// Transforms the inner [Err] instance if this is an [Err].
  Result<T> mapErr(
    @noFuturesAllowed Err<T> Function(Err<T> err) noFuturesAllowed,
  );

  /// Folds the two cases of this [Result] into a single new [Result].
  Result<Object> fold(
    @noFuturesAllowed Result<Object>? Function(Ok<T> ok) onOk,
    @noFuturesAllowed Result<Object>? Function(Err<T> err) onErr,
  );

  /// Returns this if it's [Ok], otherwise returns the `other` [Result].
  Result<T> okOr(Result<T> other);

  /// Returns this if it's [Err], otherwise returns the `other` [Result].
  Result<T> errOr(Result<T> other);

  @override
  @unsafeOrError
  T unwrap();

  @override
  T unwrapOr(T fallback);

  @override
  Result<R> map<R extends Object>(
    @noFuturesAllowed R Function(T value) noFuturesAllowed,
  );

  @override
  Result<R> transf<R extends Object>([
    @noFuturesAllowed R Function(T e)? noFuturesAllowed,
  ]);

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
  Sync<Result<T>> wrapSync() => Sync.unsafe(Ok(this));

  @override
  @pragma('vm:prefer-inline')
  Async<Result<T>> wrapAsync() => Async.unsafe(Future.value(Ok(this)));

  @override
  @pragma('vm:prefer-inline')
  Result<void> asVoid() => this;

  @override
  @nonVirtual
  @pragma('vm:prefer-inline')
  void end() {}
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// A [Monad] that represents the success case of a [Result], containing a
/// [value].
final class Ok<T extends Object> extends Result<T> {
  @override
  @pragma('vm:prefer-inline')
  T get value => super.value as T;

  const Ok(T super.value) : super._();

  @override
  @pragma('vm:prefer-inline')
  bool isOk() => true;

  @override
  @pragma('vm:prefer-inline')
  bool isErr() => false;

  @override
  @pragma('vm:prefer-inline')
  Result<T> ifOk(@noFuturesAllowed void Function(Ok<T> ok) noFuturesAllowed) {
    try {
      noFuturesAllowed(this);
      return this;
    } catch (error) {
      return Err(error);
    }
  }

  @override
  @pragma('vm:prefer-inline')
  Ok<T> ifErr(@noFuturesAllowed void Function(Err<T> err) noFuturesAllowed) => this;

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
  Result<R> flatMap<R extends Object>(
    @noFuturesAllowed Result<R> Function(T value) noFuturesAllowed,
  ) {
    return noFuturesAllowed(unwrap());
  }

  @override
  @pragma('vm:prefer-inline')
  Ok<T> mapOk(@noFuturesAllowed Ok<T> Function(Ok<T> ok) noFuturesAllowed) {
    return noFuturesAllowed(this);
  }

  @override
  @pragma('vm:prefer-inline')
  Ok<T> mapErr(@noFuturesAllowed Err<T> Function(Err<T> err) noFuturesAllowed) {
    return this;
  }

  @override
  @pragma('vm:prefer-inline')
  Result<Object> fold(
    @noFuturesAllowed Result<Object>? Function(Ok<T> ok) onOk,
    @noFuturesAllowed Result<Object>? Function(Err<T> err) onErr,
  ) {
    try {
      return onOk(this) ?? this;
    } catch (error) {
      return Err(error);
    }
  }

  @override
  @pragma('vm:prefer-inline')
  Ok<T> okOr(Result<T> other) => this;

  @override
  @pragma('vm:prefer-inline')
  Result<T> errOr(Result<T> other) => other;

  @override
  @pragma('vm:prefer-inline')
  T unwrap() => value;

  @override
  @pragma('vm:prefer-inline')
  T unwrapOr(T fallback) => value;

  @override
  @pragma('vm:prefer-inline')
  Ok<R> map<R extends Object>(
    @noFuturesAllowed R Function(T value) noFuturesAllowed,
  ) {
    return Ok(noFuturesAllowed(value));
  }

  @override
  Result<R> transf<R extends Object>([
    @noFuturesAllowed R Function(T e)? noFuturesAllowed,
  ]) {
    try {
      final a = unwrap();
      final b = noFuturesAllowed?.call(a) ?? a as R;
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
  Sync<Ok<T>> wrapSync() => Sync.unsafe(Ok(this));

  @override
  @pragma('vm:prefer-inline')
  Async<Ok<T>> wrapAsync() => Async.unsafe(Future.value(Ok(this)));

  @override
  @pragma('vm:prefer-inline')
  Ok<void> asVoid() => this;
}

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
  Option<E> matchError<E extends Object>() => value is E ? Some(value as E) : const None();

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
