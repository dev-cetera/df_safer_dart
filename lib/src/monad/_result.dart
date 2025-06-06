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

sealed class Result<T extends Object> extends Monad<T> {
  const Result._();

  Some<Result<T>> asSome();

  None<Result<T>> asNone();

  @pragma('vm:prefer-inline')
  Async<T> asAsync() => Async.value(Future.value(this));

  @pragma('vm:prefer-inline')
  Sync<T> asSync() => Sync.value(this);

  bool isOk();

  bool isErr();

  Result<T> ifOk(void Function(Ok<T> ok) unsafe);

  Result<T> ifErr(void Function(Err<T> err) unsafe);

  Option<Err<T>> err();

  Option<Ok<T>> ok();

  T unwrap({int stackLevel = 1});

  T unwrapOr(T fallback);

  @pragma('vm:prefer-inline')
  T unwrapOrElse(T Function() unsafe) => unwrapOr(unsafe());

  T? orNull();

  Result<R> map<R extends Object>(R Function(T value) mapper);

  R mapOr<R extends Object>(R Function(T value) unsafe, R fallback);

  Result<Object> fold(
    Result<Object>? Function(Ok<T> ok) onOk,
    Result<Object>? Function(Err<T> err) onErr,
  );

  R when<R extends Object>({
    required R Function(T value) onOkUnsafe,
    required R Function(Err<T> err) onErrUnsafe,
  });

  (Option<T>, Option<R>) and<R extends Object>(Result<R> other);

  Result<Object> or<R extends Object>(Result<R> other);

  Result<R> transf<R extends Object>([R Function(T e)? transformer]);
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

final class Ok<T extends Object> extends Result<T> {
  final T value;
  const Ok(this.value) : super._();

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
  Some<Ok<T>> ok() => Some(this);

  @protected
  @override
  @pragma('vm:prefer-inline')
  None<Err<T>> err() => const None();

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
  T unwrap({int stackLevel = 1}) => value;

  @protected
  @override
  @pragma('vm:prefer-inline')
  T unwrapOr(T fallback) => value;

  @protected
  @override
  @pragma('vm:prefer-inline')
  T? orNull() => value;

  @override
  @pragma('vm:prefer-inline')
  Result<R> map<R extends Object>(R Function(T value) mapper) => Ok(mapper(value));

  @protected
  @override
  @pragma('vm:prefer-inline')
  R mapOr<R extends Object>(R Function(T value) unsafe, R fallback) => unsafe(value);

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

  @protected
  @override
  R when<R extends Object>({
    required R Function(T value) onOkUnsafe,
    required R Function(Err<T> err) onErrUnsafe,
  }) {
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
  Ok<Object> or<R extends Object>(Result<R> other) => this;

  @override
  @pragma('vm:prefer-inline')
  String toString() => '${Ok<T>}($value)';

  @override
  Result<R> transf<R extends Object>([R Function(T e)? transformer]) {
    try {
      final value0 = unwrap();
      final value1 = transformer?.call(value0) ?? value0 as R;
      return Ok(value1);
    } catch (_) {
      return Err('Cannot transform $T to $R.');
    }
  }

  @override
  List<Object?> get props => [this.value];

  @override
  bool? get stringify => false;
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

final class Err<T extends Object> extends Result<T> implements Exception {
  late final String? debugPath;
  final Object error;
  final int? statusCode;
  final StackTrace? stackTrace;
  final int _initialStackLevel;

  factory Err(Object error, {int? statusCode}) {
    return Err._internal(error, statusCode: statusCode, initialStackLevel: 3);
  }

  Err._internal(
    this.error, {
    this.statusCode,
    @visibleForTesting int initialStackLevel = 3,
  })  : stackTrace = StackTrace.current,
        _initialStackLevel = initialStackLevel,
        super._() {
    this.debugPath = Here(_initialStackLevel).basepath;
  }

  @visibleForTesting
  Err<T> addStackLevel([int delta = 1]) {
    return Err._internal(
      error,
      statusCode: statusCode,
      initialStackLevel: _initialStackLevel + delta + 1,
    );
  }

  factory Err.fromModel(ErrModel model) {
    final error = model.error;
    if (error == null) {
      return Err('Error is null!');
    }
    return Err(error, statusCode: model.statusCode);
  }

  @visibleForTesting
  Err.test() : this._internal('Test error!');

  @pragma('vm:prefer-inline')
  bool isErrorValueType<E extends Object>() => error is E;

  @pragma('vm:prefer-inline')
  Result<E> transErrorValue<E extends Object>() =>
      isErrorValueType<E>() ? Ok(error as E) : Err('Error type is not $E!');

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

  @protected
  @override
  @pragma('vm:prefer-inline')
  None<Ok<T>> ok() => const None();

  @override
  @pragma('vm:prefer-inline')
  Some<Err<T>> err() => Some(this);

  @protected
  @override
  @pragma('vm:prefer-inline')
  Err<T> ifOk(void Function(Ok<T> ok) unsafe) => this;

  @override
  @pragma('vm:prefer-inline')
  Err<T> ifErr(void Function(Err<T> err) unsafe) {
    unsafe(this);
    return this;
  }

  @protected
  @override
  @pragma('vm:prefer-inline')
  T unwrap({int stackLevel = 1}) {
    throw Err<T>(
      'Called unwrap() on Err<$T>.',
      statusCode: statusCode,
    ).addStackLevel(stackLevel);
  }

  @protected
  @override
  @pragma('vm:prefer-inline')
  T unwrapOr(T fallback) => fallback;

  @protected
  @override
  @pragma('vm:prefer-inline')
  T? orNull() => null;

  @override
  @pragma('vm:prefer-inline')
  Err<R> map<R extends Object>(R Function(T value) mapper) => transErr<R>();

  @protected
  @override
  @pragma('vm:prefer-inline')
  R mapOr<R extends Object>(R Function(T value) unsafe, R fallback) => fallback;

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

  @protected
  @override
  R when<R extends Object>({
    required R Function(T value) onOkUnsafe,
    required R Function(Err<T> err) onErrUnsafe,
  }) {
    return onErrUnsafe(this);
  }

  @protected
  @override
  @pragma('vm:prefer-inline')
  (None<T>, None<R>) and<R extends Object>(Result<R> other) {
    return (const None(), const None());
  }

  @override
  @pragma('vm:prefer-inline')
  Result<Object> or<R extends Object>(Result<R> other) => other;

  @override
  @pragma('vm:prefer-inline')
  String toString() {
    final encoder = const JsonEncoder.withIndent('  ');
    return encoder.convert(toJson());
  }

  ErrModel toModel() {
    final type = 'Err<${T.toString()}>';
    final error = _safeToString(this.error);
    // final stackTrace = this
    //         .stackTrace
    //         ?.toString()
    //         .split('\n')
    //         .map((e) => e.trim())
    //         .where((e) => e.isNotEmpty)
    //         .toList();
    return ErrModel(
      type: type,
      debugPath: debugPath,
      error: error,
      statusCode: statusCode,
      //stackTrace: stackTrace,
    );
  }

  @pragma('vm:prefer-inline')
  Map<String, dynamic> toJson() {
    final model = toModel();
    return {
      if (model.type != null) 'type': model.type,
      if (model.debugPath != null) 'debugPath': model.debugPath,
      if (model.error != null) 'error': model.error,
      if (model.statusCode != null) 'statusCode': model.statusCode,
      if (model.stackTrace != null) 'stackTrace': model.stackTrace,
    };
  }

  @protected
  @override
  @pragma('vm:prefer-inline')
  Err<R> transf<R extends Object>([R Function(T e)? transformer]) {
    return transErr<R>();
  }

  @pragma('vm:prefer-inline')
  Err<R> transErr<R extends Object>() {
    return Err(error, statusCode: statusCode);
  }

  @override
  List<Object?> get props => [debugPath, error, statusCode];

  @override
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
