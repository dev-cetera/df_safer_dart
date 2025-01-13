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

  // ignore: invalid_use_of_visible_for_testing_member
  Option<T> get asOption => isOk() ? Some(ok().unwrap().value) : const None();

  bool isOk();

  bool isErr();

  @visibleForTesting
  Option<Ok<T>> ok();

  @visibleForTesting
  Option<Err<T>> err();

  Result<T> ifOk(void Function(Ok<T> ok) callback);

  Result<T> ifErr(void Function(Err<T> err) callback);

  @visibleForTesting
  T unwrap();

  T unwrapOr(T fallback);

  @pragma('vm:prefer-inline')
  T unwrapOrElse(T Function() fallback) => unwrapOr(fallback());

  Result<R> map<R extends Object>(R Function(T value) mapper);

  Result<R> fold<R extends Object>(
    Result<R> Function(T value) onOk,
    Result<R> Function(Object error) onErr,
  );

  Result<dynamic> and<R extends Object>(Result<R> other);

  Result<dynamic> or<R extends Object>(Result<R> other);

  Result<Result<R>> cast<R extends Object>();

  static Result<T> reduce<T extends Object>(Result<Result<T>> result) {
    if (result.isOk()) {
      final innerResult = result.unwrap();
      if (innerResult.isOk()) {
        // ignore: invalid_use_of_visible_for_testing_member
        return innerResult.ok().unwrap();
      } else {
        // ignore: invalid_use_of_visible_for_testing_member
        return innerResult.err().unwrap().castErr();
      }
    }
    // ignore: invalid_use_of_visible_for_testing_member
    return result.err().unwrap().castErr();
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
  Some<Ok<T>> ok() => Some(this);

  @protected
  @override
  @pragma('vm:prefer-inline')
  None<Err<T>> err() => const None();

  @override
  @pragma('vm:prefer-inline')
  Result<T> ifOk(void Function(Ok<T> ok) callback) {
    callback(this);
    return this;
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
  Result<R> map<R extends Object>(R Function(T value) mapper) => Ok(mapper(value));

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
    if (other.isOk()) {
      return Ok((value, other.unwrap()));
    } else {
      // ignore: invalid_use_of_visible_for_testing_member
      return other.err().unwrap();
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
      return Err(
        stack: [Err<T>, cast],
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
  None<Ok<T>> ok() => const None();

  @override
  @pragma('vm:prefer-inline')
  Some<Err<T>> err() => Some(this);

  @override
  @pragma('vm:prefer-inline')
  Result<T> ifOk(void Function(Ok<T> ok) callback) => this;

  @override
  @pragma('vm:prefer-inline')
  Result<T> ifErr(void Function(Err<T> err) callback) {
    callback(this);
    return this;
  }

  @protected
  @override
  @pragma('vm:prefer-inline')
  T unwrap() {
    throw Err(
      stack: [Err<T>, unwrap],
      error: 'Cannot unwrap an Err.',
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
  Result<R> fold<R extends Object>(
    Result<R> Function(T value) onOk,
    Result<R> Function(Object error) onErr,
  ) {
    return onErr(error);
  }

  @protected
  @override
  @pragma('vm:prefer-inline')
  Result<dynamic> and<R extends Object>(Result<R> other) => err().unwrap();

  @override
  @pragma('vm:prefer-inline')
  Result<dynamic> or<R extends Object>(Result<R> other) => other;

  @override
  @pragma('vm:prefer-inline')
  String toString() => '${Err<T>}($error)';

  @protected
  @override
  @pragma('vm:prefer-inline')
  Result<Result<R>> cast<R extends Object>() => castErr();

  @pragma('vm:prefer-inline')
  Err<R> castErr<R extends Object>() => Err(stack: stack, error: error);
}
