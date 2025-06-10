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

/// A [Monad] that represents either an [Ok] result or an [Error] result.
sealed class Result<T extends Object> extends Monad<T> {
  const Result._();

  /// Returns this as an [Option].
  @pragma('vm:prefer-inline')
  Result<T> asResult() => this;

  /// Adds to the stack trace level for debugging [Err] types.
  Result<T> addStackLevel([int delta = 1]);

  /// Returns this [Result] as a [Some].
  Some<Result<T>> asSome();

  /// Returns this [Result] as a [None].
  None<Result<T>> asNone();

  /// Converts this [Result] to an [Async] monad.
  @pragma('vm:prefer-inline')
  Async<T> asAsync() => Async.value(Future.value(this));

  /// Converts this [Result] to a [Sync] monad.
  @pragma('vm:prefer-inline')
  Sync<T> asSync() => Sync.value(this);

  /// Returns `true` if this is an [Ok].
  bool isOk();

  /// Returns `true` if this is an [Err].
  bool isErr();

  /// Performs a side-effect if this is an [Ok].
  Result<T> ifOk(void Function(Ok<T> ok) unsafe);

  /// Performs a side-effect if this is an [Err].
  Result<T> ifErr(void Function(Err<T> err) unsafe);

  /// Returns an [Option] containing the [Err] if this is an [Err].
  Option<Err<T>> err();

  /// Returns an [Option] containing the [Ok] if this is an [Ok].
  Option<Ok<T>> ok();

  /// Returns the contained [Ok] value. Throws an [Err] if this is an [Err].
  @override
  T unwrap({int delta = 1});

  /// Returns the contained [Ok] value or a provided fallback.
  @override
  T unwrapOr(T fallback);

  /// Returns the contained [Ok] value or computes it from a function.
  @override
  @pragma('vm:prefer-inline')
  T unwrapOrElse(T Function() unsafe) => unwrapOr(unsafe());

  /// Returns the contained [Ok] value or `null`.
  T? orNull();

  /// Maps a `Result<T, E>` to `Result<R, E>` by applying a function to a contained [Ok] value.
  @override
  Result<R> map<R extends Object>(R Function(T value) mapper);

  /// Maps an `Result<T>` to `Result<R>` by applying the [mapper] function.
  Result<R> flatMap<R extends Object>(Result<R> Function(T value) mapper) {
    if (isOk()) {
      return mapper(unwrap());
    } else {
      return Err('Called flatMap() on Err<$T>.');
    }
  }

  /// Chains [Result] instances by handling [Ok] and [Err] cases.
  Result<Object> fold(
    Result<Object>? Function(Ok<T> ok) onOk,
    Result<Object>? Function(Err<T> err) onErr,
  );

  /// Exhaustively handles [Ok] and [Err] cases, returning a new value.
  R match<R extends Object>(
    R Function(T value) onOk,
    R Function(Err<T> err) onErr,
  );

  /// Combines this [Result] with another, returning a tuple of their values if both are [Ok].
  (Option<T>, Option<R>) and<R extends Object>(Result<R> other);

  /// Returns this if it's [Ok], otherwise returns [other].
  Result<Object> okOr<R extends Object>(Result<R> other);

  /// Returns this if it's [Err], otherwise returns [other].
  Result<Object> errOr<R extends Object>(Result<R> other);

  /// Transforms the [Ok] value's type.
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

/// A [Monad] that represents a [Result] that represents a non-error [value].
final class Ok<T extends Object> extends Result<T> {
  final T value;
  const Ok(this.value) : super._();

  @override
  @pragma('vm:prefer-inline')
  Ok<T> addStackLevel([int delta = 1]) => this;

  @override
  @pragma('vm:prefer-inline')
  Some<Ok<T>> asSome() => Some(this);

  @override
  @pragma('vm:prefer-inline')
  None<Ok<T>> asNone() => const None();

  @override
  @pragma('vm:prefer-inline')
  bool isOk() => true;

  @override
  @pragma('vm:prefer-inline')
  bool isErr() => false;

  @override
  @pragma('vm:prefer-inline')
  Result<T> ifOk(void Function(Ok<T> ok) unsafe) {
    try {
      unsafe(this);
      return this;
    } catch (error) {
      return Err(error);
    }
  }

  @override
  @pragma('vm:prefer-inline')
  Ok<T> ifErr(void Function(Err<T> err) unsafe) => this;

  @override
  @pragma('vm:prefer-inline')
  None<Err<T>> err() => const None();

  @override
  @pragma('vm:prefer-inline')
  Some<Ok<T>> ok() => Some(this);

  @override
  @pragma('vm:prefer-inline')
  T unwrap({int delta = 1}) => value;

  @override
  @pragma('vm:prefer-inline')
  T unwrapOr(T fallback, {int stackLevel = 1}) => value;

  @override
  @pragma('vm:prefer-inline')
  T? orNull() => value;

  @override
  @pragma('vm:prefer-inline')
  Result<R> map<R extends Object>(R Function(T value) mapper) =>
      Ok(mapper(value));

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
    R Function(T value) onOk,
    R Function(Err<T> err) onErr,
  ) {
    return onOk(this.value);
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
  Result<R> transf<R extends Object>([R Function(T e)? transformer]) {
    try {
      final a = unwrap();
      return Ok(transformer?.call(a) ?? a as R);
    } catch (_) {
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

/// A [Monad] that represents a [Result] that represents an error.
final class Err<T extends Object> extends Result<T> implements Exception {
  //
  //
  //

  late final Option<String> location;
  final Object error;
  final Option<int> statusCode;
  final Option<StackTrace> stackTrace;
  final int stackLevel;

  //
  //
  //

  @pragma('vm:prefer-inline')
  factory Err(Object error, {Option<int> statusCode = const None()}) {
    return Err.verbose(
      error: error,
      statusCode: statusCode,
      stackLevel: 4,
      location: const None(),
    );
  }

  //
  //
  //

  Err.verbose({
    required this.error,
    required this.statusCode,
    required this.stackLevel,
    required Option<String> location,
  }) : stackTrace = Some(StackTrace.current),
       location = location.isSome() ? location : Here(stackLevel).location,
       assert(
         () {
           // If this assert was triggered, it means that you're running your
           // app in debug mode, debugAssertErr is true or kDebugAssertErr is
           // true and an Err was somehwere created in your application.

           // We cannot pinpoint the source of this assert message if
           // stackLevel >= 1.
           if (stackLevel < 1) {
             return false;
           }
           // If this flag is available, we use it.
           if (debugAssertErr != null) {
             return !debugAssertErr!;
           } else {
             // Otherwise we use the compile constant.
             return !kDebugAssertErr;
           }
         }(),
         'Err<$T> created at: ${Here(stackLevel - 1)().match((e) => e.location, () => '???')}',
       ),
       super._();

  //
  //
  //

  @pragma('vm:prefer-inline')
  factory Err.fromModel(ErrModel model) {
    final error = model.error;
    if (error == null) {
      return Err('Error is null!');
    }
    return Err(error, statusCode: Option.fromNullable(model.statusCode));
  }

  //
  //
  //

  @override
  @pragma('vm:prefer-inline')
  Err<T> addStackLevel([int delta = 1]) {
    return Err.verbose(
      error: error,
      statusCode: statusCode,
      stackLevel: stackLevel + delta,
      location: location,
    );
  }

  //
  //
  //

  @override
  @pragma('vm:prefer-inline')
  Some<Err<T>> asSome() => Some(this);

  @override
  @pragma('vm:prefer-inline')
  None<Err<T>> asNone() => const None();

  @override
  @pragma('vm:prefer-inline')
  bool isOk() => false;

  @override
  @pragma('vm:prefer-inline')
  bool isErr() => true;

  @override
  @pragma('vm:prefer-inline')
  Err<T> ifOk(void Function(Ok<T> ok) unsafe) => this;

  @override
  @pragma('vm:prefer-inline')
  Err<T> ifErr(void Function(Err<T> err) unsafe) {
    unsafe(this);
    return this;
  }

  @override
  @pragma('vm:prefer-inline')
  Some<Err<T>> err() => Some(this);

  @override
  @pragma('vm:prefer-inline')
  None<Ok<T>> ok() => const None();

  @override
  @pragma('vm:prefer-inline')
  T unwrap({int delta = 1}) {
    throw Err<T>.verbose(
      error: 'Called unwrap() on Err<$T>.',
      statusCode: statusCode,
      stackLevel: stackLevel + delta,
      location: location,
    );
  }

  @override
  @pragma('vm:prefer-inline')
  T unwrapOr(T fallback) => fallback;

  @override
  @pragma('vm:prefer-inline')
  T? orNull() => null;

  @override
  @pragma('vm:prefer-inline')
  Err<R> map<R extends Object>(R Function(T value) mapper) => transfErr<R>();

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
    R Function(T value) onOk,
    R Function(Err<T> err) onErr,
  ) {
    return onErr(this);
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

  /// Checks if the contained [error] matches the type [E].
  @pragma('vm:prefer-inline')
  Option<E> matchError<E extends Object>() =>
      error is E ? Some(error as E) : NONE;

  /// Transforms the type [T] without casting [error].
  @pragma('vm:prefer-inline')
  Err<R> transfErr<R extends Object>() {
    return Err.verbose(
      error: error,
      statusCode: statusCode,
      stackLevel: stackLevel,
      location: location,
    );
  }

  /// Converts this [Err] to an `ErrModel`.
  ErrModel toModel() {
    final type = 'Err<${T.toString()}>';
    final error = _safeToString(this.error);
    return ErrModel(
      type: type,
      location: location.orNull(),
      error: error,
      statusCode: statusCode.orNull(),
    );
  }

  /// Converts this [Err] to a JSON map.
  Map<String, dynamic> toJson() {
    final model = toModel();
    return {
      if (model.type != null) 'type': model.type,
      if (model.location != null) 'location': model.location,
      if (model.error != null) 'error': model.error,
      if (model.statusCode != null) 'statusCode': model.statusCode,
      if (model.stackTrace != null) 'stackTrace': model.stackTrace,
    };
  }

  @override
  @pragma('vm:prefer-inline')
  String toString() {
    final encoder = const JsonEncoder.withIndent('  ');
    return encoder.convert(toJson());
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
  } catch (_) {
    return '${obj.runtimeType}@${obj.hashCode.toRadixString(16)}';
  }
}
