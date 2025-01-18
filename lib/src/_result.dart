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

  Option<T> get asOption => isOk() ? Some(ok().unwrap()) : const None();

  bool isOk();

  bool isErr();

  Result<T> ok();

  Err<T> err();

  Result<T> ifOk(void Function(Ok<T> ok) callback);

  Result<T> ifErr(void Function(Err<T> err) callback);

  T unwrap();

  T unwrapOr(T fallback);

  @pragma('vm:prefer-inline')
  T unwrapOrElse(T Function() fallback) => unwrapOr(fallback());

  Result<R> map<R extends Object>(R Function(T value) mapper);

  Result<Object> fold(
    Result<Object>? Function(Ok<T> ok) onOk,
    Result<Object>? Function(Err<T> err) onErr,
  );

  (Option<T>, Option<R>) and<R extends Object>(Result<R> other);

  Result<Object> or<R extends Object>(Result<R> other);

  Result<R> cast<R extends Object>();

  static Result<T> combine<T extends Object>(Result<Result<T>> result) {
    if (result.isOk()) {
      final innerResult = result.unwrap();
      if (innerResult.isOk()) {
        return innerResult.ok();
      } else {
        return innerResult.err();
      }
    }

    return result.err().castErr();
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

class Ok<T extends Object> extends Result<T> {
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
  Err<T> err() {
    return Err(
      stack: ['Ok', 'err'],
      error: 'Called err() on Ok.',
    );
  }

  @override
  @pragma('vm:prefer-inline')
  Result<T> ifOk(void Function(Ok<T> ok) callback) {
    try {
      callback(this);
      return this;
    } catch (e) {
      return Err(
        stack: ['Ok', 'ifOk'],
        error: e,
      );
    }
  }

  @override
  @pragma('vm:prefer-inline')
  Result<T> ifErr(void Function(Err<T> err) callback) => this;

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
  @pragma('vm:prefer-inline')
  Result<Object> fold(
    Result<Object>? Function(Ok<T> ok) onOk,
    Result<Object>? Function(Err<T> err) onErr,
  ) {
    try {
      return onOk(this) ?? this;
    } catch (e) {
      return Err(
        stack: ['Ok', 'fold'],
        error: e,
      );
    }
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
  Result<Object> or<R extends Object>(Result<R> other) => this;

  @override
  @pragma('vm:prefer-inline')
  String toString() => '${Ok<T>}($value)';

  @override
  @pragma('vm:prefer-inline')
  Result<R> cast<R extends Object>() {
    final value = unwrap();
    if (value is R) {
      return Result.combine(Ok(Ok(value)));
    } else {
      return Err(
        stack: ['Err', 'cast'],
        error: 'Cannot cast ${value.runtimeType} to $R',
      );
    }
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

class Err<T extends Object> extends Result<T> {
  final List<Object> stack;
  final Object error;
  const Err({
    required this.stack,
    required this.error,
  }) : super._();

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
    return Err(
      stack: ['Ok', 'ok'],
      error: 'Called ok() on Err.',
    );
  }

  @override
  @pragma('vm:prefer-inline')
  Err<T> err() => this;

  @override
  @pragma('vm:prefer-inline')
  Result<T> ifOk(void Function(Ok<T> ok) callback) => this;

  @override
  @pragma('vm:prefer-inline')
  Result<T> ifErr(void Function(Err<T> err) callback) {
    callback(this);
    return this;
  }

  @nonVirtual
  @protected
  @override
  @pragma('vm:prefer-inline')
  T unwrap() {
    throw const Err(
      stack: ['Err', 'unwrap'],
      error: 'Called unwrap() on Err.',
    );
  }

  @override
  @pragma('vm:prefer-inline')
  T unwrapOr(T fallback) => fallback;

  @override
  @pragma('vm:prefer-inline')
  Result<R> map<R extends Object>(R Function(T value) mapper) => castErr<R>();

  @override
  @pragma('vm:prefer-inline')
  Result<Object> fold(
    Result<Object>? Function(Ok<T> ok) onOk,
    Result<Object>? Function(Err<T> err) onErr,
  ) {
    try {
      return onErr(this) ?? this;
    } catch (e) {
      return Err(
        stack: ['Err', 'fold'],
        error: e,
      );
    }
  }

  @protected
  @override
  @pragma('vm:prefer-inline')
  (Option<T>, Option<R>) and<R extends Object>(Result<R> other) {
    return (const None(), const None());
  }

  @override
  @pragma('vm:prefer-inline')
  Result<Object> or<R extends Object>(Result<R> other) => other;

  @override
  @pragma('vm:prefer-inline')
  String toString() => '${Err<T>}(stack: [${stack.join(', ')}], error: $error)';

  @protected
  @override
  @pragma('vm:prefer-inline')
  Result<R> cast<R extends Object>() => castErr();

  @pragma('vm:prefer-inline')
  Err<R> castErr<R extends Object>() => Err(stack: stack, error: error);
}
