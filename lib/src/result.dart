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

import 'package:meta/meta.dart';

import 'option.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

sealed class Result<T extends Object> {
  const Result._();

  Option<T> get asOption => isOk ? Some(ok.value) : const None();

  bool get isOk;

  bool get isErr;

  @visibleForTesting
  Ok<T> get ok;

  @visibleForTesting
  Err<T> get err;

  Result<T> ifOk(void Function(T value) fn);

  Result<T> ifErr(void Function(Err<T> error) fn);

  @visibleForTesting
  T unwrap();

  T unwrapOr(T fallback);

  @pragma('vm:prefer-inline')
  T unwrapOrElse(T Function() fallback) => unwrapOr(fallback());

  Result<R> map<R extends Object>(R Function(T value) fn);

  Result<T> mapErr(Object Function(Object error) fn);

  Result<R> fold<R extends Object>(
    Result<R> Function(T value) onOk,
    Result<R> Function(Object error) onErr,
  );

  Result<dynamic> and<R extends Object>(Result<R> other);

  Result<dynamic> or<R extends Object>(Result<R> other);

  Result<Result<R>> cast<R extends Object>();
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

class Ok<T extends Object> extends Result<T> {
  final T value;
  const Ok(this.value) : super._();

  factory Ok.fn(T Function() fn) => Ok(fn());

  @override
  @pragma('vm:prefer-inline')
  bool get isOk => true;

  @override
  @pragma('vm:prefer-inline')
  bool get isErr => false;

  @override
  @pragma('vm:prefer-inline')
  Ok<T> get ok => this;

  @protected
  @override
  @pragma('vm:prefer-inline')
  Err<T> get err => throw const Err('Cannot get err from Ok.');

  @override
  @pragma('vm:prefer-inline')
  Result<T> ifOk(void Function(T value) fn) {
    fn(value);
    return this;
  }

  @override
  @pragma('vm:prefer-inline')
  Result<T> ifErr(void Function(Err<T> error) fn) => this;

  @override
  @pragma('vm:prefer-inline')
  T unwrap() => value;

  @override
  @pragma('vm:prefer-inline')
  T unwrapOr(T fallback) => value;

  @override
  @pragma('vm:prefer-inline')
  Result<R> map<R extends Object>(R Function(T value) fn) => Ok(fn(value));

  @override
  @pragma('vm:prefer-inline')
  Result<T> mapErr(Object Function(Object error) fn) => this;

  @override
  @pragma('vm:prefer-inline')
  Result<R> fold<R extends Object>(
    Result<R> Function(T value) onOk,
    Result<R> Function(Object error) onErr,
  ) {
    return onOk(value);
  }

  @override
  @pragma('vm:prefer-inline')
  Result<dynamic> and<R extends Object>(Result<R> other) {
    if (other.isOk) {
      return Ok((value, other.unwrap()));
    } else {
      return other.err;
    }
  }

  @override
  @pragma('vm:prefer-inline')
  Result<dynamic> or<R extends Object>(Result<R> other) => this;

  @override
  @pragma('vm:prefer-inline')
  String toString() => '${Ok<T>}($value)';

  @override
  Result<Result<R>> cast<R extends Object>() {
    final value = unwrap();
    if (value is R) {
      return Ok(Ok(value));
    } else {
      return Err('Cannot cast ${value.runtimeType} to $R');
    }
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

class Err<T extends Object> extends Result<T> {
  final Object value;
  const Err(this.value) : super._();

  factory Err.fn(T Function() fn) => Err(fn());

  @override
  @pragma('vm:prefer-inline')
  bool get isOk => false;

  @override
  @pragma('vm:prefer-inline')
  bool get isErr => true;

  @protected
  @override
  @pragma('vm:prefer-inline')
  Ok<T> get ok => throw const Err('Cannot get ok from Err.');

  @override
  @pragma('vm:prefer-inline')
  Err<T> get err => this;

  @override
  @pragma('vm:prefer-inline')
  Result<T> ifOk(void Function(T value) fn) => this;

  @override
  @pragma('vm:prefer-inline')
  Result<T> ifErr(void Function(Err<T> error) fn) {
    fn(this);
    return this;
  }

  @protected
  @override
  @pragma('vm:prefer-inline')
  T unwrap() => throw const Err('Cannot unwrap an Err.');

  @override
  @pragma('vm:prefer-inline')
  T unwrapOr(T fallback) => fallback;

  @override
  @pragma('vm:prefer-inline')
  Result<R> map<R extends Object>(R Function(T value) fn) => Err(value);

  @override
  @pragma('vm:prefer-inline')
  Result<T> mapErr(Object Function(Object error) fn) => Err(fn(value));

  @override
  @pragma('vm:prefer-inline')
  Result<R> fold<R extends Object>(
    Result<R> Function(T value) onOk,
    Result<R> Function(Object error) onErr,
  ) {
    return onErr(value);
  }

  @override
  @pragma('vm:prefer-inline')
  Result<dynamic> and<R extends Object>(Result<R> other) => err;

  @override
  @pragma('vm:prefer-inline')
  Result<dynamic> or<R extends Object>(Result<R> other) => other;

  @override
  @pragma('vm:prefer-inline')
  String toString() => '${Err<T>}($value)';

  @override
  @pragma('vm:prefer-inline')
  @override
  Result<Result<R>> cast<R extends Object>() => Err(err.value);
}
