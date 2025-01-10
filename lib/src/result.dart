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

import 'dart:async';

import 'option.dart';
import 'panic.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

sealed class Result<T> {
  const Result._();

  Option<T> get asOption => isOk ? Some(ok.value) : const None();

  factory Result(FutureOr<T> Function() fn) {
    try {
      final value = fn();
      if (value is Future<T>) {
        return FutureResult(value);
      }
      return Ok(value);
    } catch (e) {
      return Err(e);
    }
  }

  @pragma('vm:prefer-inline')
  FutureOr<Result<T>> then() => this;

  bool get isOk;

  bool get isErr;

  Ok<T> get ok;

  Err<T> get err;

  Result<T> ifOk(void Function(T value) fn);

  Result<T> ifErr(void Function(Object error) fn);

  T unwrap();

  T unwrapOr(T fallback);

  T unwrapOrElse(T Function(Object error) fallback);

  Result<R> map<R>(R Function(T value) fn);

  Result<R> flatMap<R>(Result<R> Function(T value) fn);

  Result<T> mapErr(Object Function(Object error) fn);

  FutureOr<R> fold<R>(R Function(T value) onOk, R Function(Object error) onErr);

  Result<dynamic> and<R>(Result<R> other);

  Result<dynamic> or<R>(Result<R> other);
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

final class FutureResult<T> extends Result<T> {
  final FutureOr<dynamic> value;
  const FutureResult(this.value) : super._();

  @override
  FutureOr<R> fold<R>(
    R Function(T value) onOk,
    R Function(Object error) onErr,
  ) {
    if (this is Ok<T>) {
      return onOk((this as Ok<T>).value);
    } else if (this is Err<T>) {
      return onErr((this as Err<T>).value);
    }
    return () async {
      return (await then()).fold(onOk, onErr);
    }();
  }

  @override
  FutureOr<Result<T>> then() {
    if (value is Future<T>) {
      final value1 = value as Future<T>;
      return () async {
        try {
          return Ok<T>(await value1);
        } catch (e) {
          return Err<T>(e);
        }
      }();
    }

    return this;
  }

  @override
  bool get isOk {
    throw Panic(
      '[FutureResult] does not support [isOk]. Use [then] first to get either [Ok] or [Err].',
    );
  }

  @override
  bool get isErr {
    throw Panic(
      '[FutureResult] does not support [isErr]. Use [then] first to get either [Ok] or [Err].',
    );
  }

  @override
  Ok<T> get ok {
    throw Panic(
      '[FutureResult] does not support [ok]. Use [then] first to get either [Ok] or [Err].',
    );
  }

  @override
  Err<T> get err {
    throw Panic(
      '[FutureResult] does not support [err]. Use [then] first to get either [Ok] or [Err].',
    );
  }

  @override
  Result<T> ifOk(void Function(T value) fn) {
    throw Panic(
      '[FutureResult] does not support [ifOk]. Use [then] first to get either [Ok] or [Err].',
    );
  }

  @override
  Result<T> ifErr(void Function(Object error) fn) {
    throw Panic(
      '[FutureResult] does not support [ifErr]. Use [then] first to get either [Ok] or [Err].',
    );
  }

  @override
  T unwrap() {
    throw Panic(
      '[FutureResult] does not support [unwrap]. Use [then] first to get either [Ok] or [Err].',
    );
  }

  @override
  T unwrapOr(T fallback) {
    throw Panic(
      '[FutureResult] does not support [unwrapOr]. Use [then] first to get either [Ok] or [Err].',
    );
  }

  @override
  T unwrapOrElse(T Function(Object error) fallback) {
    throw Panic(
      '[FutureResult] does not support [unwrapOrElse]. Use [then] first to get either [Ok] or [Err].',
    );
  }

  @override
  Result<R> map<R>(R Function(T value) fn) {
    throw Panic(
      '[FutureResult] does not support [map]. Use [then] first to get either [Ok] or [Err].',
    );
  }

  @override
  Result<R> flatMap<R>(Result<R> Function(T value) fn) {
    throw Panic(
      '[FutureResult] does not support [flatMap]. Use [then] first to get either [Ok] or [Err].',
    );
  }

  @override
  Result<T> mapErr(Object Function(Object error) fn) {
    throw Panic(
      '[FutureResult] does not support [mapErr]. Use [then] first to get either [Ok] or [Err].',
    );
  }

  @override
  bool operator ==(Object other) {
    throw Panic(
      '[FutureResult] does not support [==]. Use [then] first to get either [Ok] or [Err].',
    );
  }

  @override
  int get hashCode {
    throw Panic(
      '[FutureResult] does not support [hashCode]. Use [then] first to get either [Ok] or [Err].',
    );
  }

  @override
  Result<dynamic> and<R>(Result<R> other) {
    throw Panic(
      '[FutureResult] does not support [and]. Use [then] first to get either [Ok] or [Err].',
    );
  }

  @override
  Result<dynamic> or<R>(Result<R> other) {
    throw Panic(
      '[FutureResult] does not support [or]. Use [then] first to get either [Ok] or [Err].',
    );
  }

  @override
  @pragma('vm:prefer-inline')
  String toString() {
    return '${FutureResult<T>}($value)';
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

class Ok<T> extends Result<T> with _EqualityMixin<T> {
  final T value;
  const Ok(this.value) : super._();

  @override
  @pragma('vm:prefer-inline')
  bool get isOk => true;

  @override
  @pragma('vm:prefer-inline')
  bool get isErr => false;

  @override
  @pragma('vm:prefer-inline')
  Ok<T> get ok => this;

  @override
  @pragma('vm:prefer-inline')
  Err<T> get err {
    throw Panic('[Ok] Cannot get [err] from Ok.');
  }

  @override
  @pragma('vm:prefer-inline')
  Result<T> ifOk(void Function(T value) fn) {
    fn(value);
    return this;
  }

  @override
  @pragma('vm:prefer-inline')
  Result<T> ifErr(void Function(Object error) fn) {
    return this;
  }

  @override
  @pragma('vm:prefer-inline')
  T unwrap() => value;

  @override
  @pragma('vm:prefer-inline')
  T unwrapOr(T fallback) => value;

  @override
  @pragma('vm:prefer-inline')
  T unwrapOrElse(T Function(Object error) fallback) => value;

  @override
  @pragma('vm:prefer-inline')
  Result<R> map<R>(R Function(T value) fn) => Ok(fn(value));

  @override
  @pragma('vm:prefer-inline')
  Result<R> flatMap<R>(Result<R> Function(T value) fn) => fn(value);

  @override
  @pragma('vm:prefer-inline')
  Result<T> mapErr(Object Function(Object error) fn) => this;

  @override
  @pragma('vm:prefer-inline')
  R fold<R>(
    R Function(T value) onOk,
    R Function(Object error) onErr,
  ) {
    return onOk(value);
  }

  @override
  @pragma('vm:prefer-inline')
  Result<dynamic> and<R>(Result<R> other) {
    if (other.isOk) {
      return Ok((value, other.unwrap()));
    } else {
      return other.err;
    }
  }

  @override
  @pragma('vm:prefer-inline')
  Result<dynamic> or<R>(Result<R> other) => this;

  @override
  @pragma('vm:prefer-inline')
  String toString() {
    return '${Ok<T>}($value)';
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

class Err<T> extends Result<T> with _EqualityMixin<T> {
  final Object value;
  const Err(this.value) : super._();

  Err<R> cast<R>() => Err<R>(err.value);

  @override
  @pragma('vm:prefer-inline')
  bool get isOk => false;

  @override
  @pragma('vm:prefer-inline')
  bool get isErr => true;

  @override
  @pragma('vm:prefer-inline')
  Ok<T> get ok {
    throw Panic('[Err] Cannot get [ok] from Err.');
  }

  @override
  @pragma('vm:prefer-inline')
  Err<T> get err => this;

  @override
  @pragma('vm:prefer-inline')
  Result<T> ifOk(void Function(T value) fn) {
    return this;
  }

  @override
  @pragma('vm:prefer-inline')
  Result<T> ifErr(void Function(Object error) fn) {
    fn(value);
    return this;
  }

  @override
  @pragma('vm:prefer-inline')
  T unwrap() => throw value;

  @override
  @pragma('vm:prefer-inline')
  T unwrapOr(T fallback) => fallback;

  @override
  @pragma('vm:prefer-inline')
  T unwrapOrElse(T Function(Object error) fallback) => fallback(value);

  @override
  @pragma('vm:prefer-inline')
  Result<R> map<R>(R Function(T value) fn) => Err(value);

  @override
  @pragma('vm:prefer-inline')
  Result<R> flatMap<R>(Result<R> Function(T value) fn) => Err(value);

  @override
  @pragma('vm:prefer-inline')
  Result<T> mapErr(Object Function(Object error) fn) => Err(fn(value));

  @override
  @pragma('vm:prefer-inline')
  R fold<R>(
    R Function(T value) onOk,
    R Function(Object error) onErr,
  ) {
    return onErr(value);
  }

  @override
  @pragma('vm:prefer-inline')
  Result<dynamic> and<R>(Result<R> other) => err;

  @override
  @pragma('vm:prefer-inline')
  Result<dynamic> or<R>(Result<R> other) => other;

  @override
  @pragma('vm:prefer-inline')
  String toString() {
    return '${Err<T>}($value)';
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

mixin _EqualityMixin<T> on Result<T> {
  @override
  @pragma('vm:prefer-inline')
  R fold<R>(
    R Function(T value) onOk,
    R Function(Object error) onErr,
  );

  @override
  @pragma('vm:prefer-inline')
  bool operator ==(Object other) {
    return this.fold(
      (e) => other is Ok<T> && e == other.value,
      (e) => other is Err<T> && e == other.value,
    );
  }

  @override
  @pragma('vm:prefer-inline')
  int get hashCode {
    return fold(
      (e) => e.hashCode,
      (e) => e.hashCode,
    );
  }
}
