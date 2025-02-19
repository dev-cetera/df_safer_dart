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

  Option<T> asOption() => isOk() ? Some(ok().unwrap()) : const None();

  bool isOk();

  bool isErr();

  Result<T> ok();

  Err<T> err();

  @pragma('vm:prefer-inline')
  Result<T> asResult() => this;

  Result<T> ifOk(void Function(Ok<T> ok) unsafe);

  Result<T> ifErr(void Function(Err<T> err) unsafe);

  T unwrap();

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

  Result<R> trans<R extends Object>([R Function(T e)? transformer]);

  static Result<T> combine<T extends Object>(Result<Result<T>> result) {
    if (result.isOk()) {
      final innerResult = result.unwrap();
      if (innerResult.isOk()) {
        return innerResult.ok();
      } else {
        return innerResult.err();
      }
    }

    return result.err().transErr();
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

final class Ok<T extends Object> extends Result<T> {
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
  Ok<T> ok() => this;

  @protected
  @override
  @pragma('vm:prefer-inline')
  Err<T> err() => Err(debugPath: ['Ok', 'err'], error: 'Called err() on Ok.');

  @override
  @pragma('vm:prefer-inline')
  Result<T> ifOk(void Function(Ok<T> ok) unsafe) {
    try {
      unsafe(this);
      return this;
    } catch (error) {
      return Err(debugPath: ['Ok', 'ifOk'], error: error);
    }
  }

  @override
  @pragma('vm:prefer-inline')
  Ok<T> ifErr(void Function(Err<T> err) unsafe) => this;

  @override
  @pragma('vm:prefer-inline')
  T unwrap() => value;

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
      return Err(debugPath: ['Ok', 'fold'], error: error);
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
  Result<R> trans<R extends Object>([R Function(T e)? transformer]) {
    try {
      final value0 = unwrap();
      final value1 = transformer?.call(value0) ?? value0 as R;
      return Ok(value1);
    } catch (_) {
      return Err(
        debugPath: ['Ok', 'trans'],
        error: 'Cannot transform $T to $R.',
      );
    }
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

final class Err<T extends Object> extends Result<T> {
  final List<Object> debugPath;
  final Object error;
  final int? statusCode;
  final StackTrace? stack;
  Err({required this.debugPath, required this.error, this.statusCode})
      : stack = StackTrace.current,
        super._();

  @pragma('vm:prefer-inline')
  bool isErrorValueType<E extends Object>() => error is E;

  @pragma('vm:prefer-inline')
  Result<E> transErrorValue<E extends Object>() => isErrorValueType<E>()
      ? Ok(error as E)
      : Err(debugPath: ['Err', 'getError'], error: 'Error type is not $E!');

  @override
  @pragma('vm:prefer-inline')
  bool isOk() => false;

  @override
  @pragma('vm:prefer-inline')
  bool isErr() => true;

  @protected
  @override
  @pragma('vm:prefer-inline')
  Err<T> ok() {
    return Err(debugPath: ['Ok', 'ok'], error: 'Called ok() on Err.');
  }

  @override
  @pragma('vm:prefer-inline')
  Err<T> err() => this;

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
  T unwrap() {
    throw Err(debugPath: ['Err', 'unwrap'], error: 'Called unwrap() on Err.');
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
      return Err(debugPath: ['Err', 'fold'], error: error);
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
    return encoder.convert(this.toJson());
  }

  Map<String, dynamic> toJson() {
    final type = T.toString();
    final debugPath = this.debugPath.map((e) => _safeToString(e));
    final error = _safeToString(this.error);
    final stack =
        this.stack?.toString().split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty) ??
            const [];
    return {
      'type': type,
      if (debugPath.isNotEmpty) 'debugPath': debugPath,
      if (error.isNotEmpty) 'error': error,
      if (statusCode != null) 'statusCode': statusCode,
      if (stack.isNotEmpty) 'stack': stack,
    };
  }

  @protected
  @override
  @pragma('vm:prefer-inline')
  Err<R> trans<R extends Object>([R Function(T e)? transformer]) {
    return transErr<R>();
  }

  @pragma('vm:prefer-inline')
  Err<R> transErr<R extends Object>() {
    return Err(debugPath: debugPath, error: error);
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

String _safeToString(Object? obj) {
  try {
    return obj.toString();
  } catch (e) {
    return '${obj.runtimeType}@${obj.hashCode.toRadixString(16)}';
  }
}
