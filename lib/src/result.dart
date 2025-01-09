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

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

sealed class Result<T> {
  const Result._();

  Option<T> get asOption => isOk ? Some(ok.value) : const None();

  factory Result(FutureOr<T> Function() fn) {
    return tryCatch(fn, (e) => e);
  }

  @pragma('vm:prefer-inline')
  FutureOr<Result<T>> then() => this;

  FutureOr<B> fold<B>(
    B Function(T value) onOk,
    B Function(Object error) onErr,
  );

  @pragma('vm:prefer-inline')
  static Result<T> tryCatch<T, E extends Object>(
    FutureOr<T> Function() fn,
    E Function(Object e) onError,
  ) {
    try {
      final value = fn();
      if (value is Future<T>) {
        return FutureResult(value);
      }
      return Ok(value);
    } catch (e) {
      return Err(onError(e));
    }
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

final class FutureResult<T> extends Result<T> {
  final FutureOr<dynamic> value;
  const FutureResult(this.value) : super._();

  @override
  FutureOr<B> fold<B>(
    B Function(T value) onOk,
    B Function(Object error) onErr,
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
  @pragma('vm:prefer-inline')
  bool operator ==(Object other) {
    throw UnsupportedError(
      'FutureTry does not support == operator',
    );
  }

  @override
  @pragma('vm:prefer-inline')
  int get hashCode {
    throw UnsupportedError(
      'FutureTry does not support hashCode',
    );
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

final class Ok<T> extends Result<T> with _EqualityMixin<T> {
  final T value;
  const Ok(this.value) : super._();

  @override
  @pragma('vm:prefer-inline')
  B fold<B>(
    B Function(T successValue) onOk,
    B Function(Object failureValue) onErr,
  ) {
    return onOk(value);
  }

  @override
  @pragma('vm:prefer-inline')
  String toString() {
    return '${Ok<T>}($value)';
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

final class Err<T> extends Result<T> with _EqualityMixin<T> {
  final Object value;
  const Err(this.value) : super._();

  @override
  @pragma('vm:prefer-inline')
  B fold<B>(
    B Function(T successValue) onOk,
    B Function(Object failureValue) onErr,
  ) {
    return onErr(value);
  }

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
  B fold<B>(
    B Function(T successValue) onOk,
    B Function(Object failureValue) onErr,
  );

  @override
  @pragma('vm:prefer-inline')
  bool operator ==(Object other) {
    return this.fold(
      (e) => other is Ok && e == other.value,
      (e) => other is Err && e == other.value,
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

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

extension TryExtension<T> on Result<T> {
  @pragma('vm:prefer-inline')
  bool get isOk {
    return this is Ok<T>;
  }

  @pragma('vm:prefer-inline')
  bool get isErr {
    return this is Err<T>;
  }

  @pragma('vm:prefer-inline')
  Ok<T> get ok {
    assert(isOk, 'This is not a Success: $this');
    return this as Ok<T>;
  }

  @pragma('vm:prefer-inline')
  Err<T> get err {
    assert(isErr, 'This is not a Failure: $this');
    return this as Err<T>;
  }

  @pragma('vm:prefer-inline')
  Ok<T> unwrap() {
    return ok;
  }

  @pragma('vm:prefer-inline')
  Err<T> unwrapErr() {
    return err;
  }

  @pragma('vm:prefer-inline')
  T unwrapOr(T defaultValue) {
    if (isOk) {
      return ok.value;
    }
    return defaultValue;
  }

  @pragma('vm:prefer-inline')
  Result<U> map<U>(U Function(T value) fn) {
    if (isOk) {
      return Ok(fn(ok.value));
    }
    return Err(err.value);
  }
}
