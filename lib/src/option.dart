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

import 'result.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

sealed class Option<T extends Object> {
  const Option._();

  factory Option.fromNullable(T? value) {
    if (value != null) {
      return Some(value);
    } else {
      return const None();
    }
  }

  bool get isSome;

  bool get isNone;

  @visibleForTesting
  Some<T> get some;

  @visibleForTesting
  None<T> get none;

  Option<T> ifSome(void Function(T value) fn);

  Option<T> ifNone(void Function() fn);

  @visibleForTesting
  T unwrap();

  T unwrapOr(T fallback);

  T unwrapOrElse(T Function() fallback) => unwrapOr(fallback());

  Option<R> map<R extends Object>(R Function(T value) fn);

  Option<T> filter(bool Function(T value) test);

  Result<T> get asResult;

  Option<R> fold<R extends Object>(
    Option<R> Function(T value) onSome,
    Option<R> Function() onNone,
  );

  Option<(T, R)> and<R extends Object>(Option<R> other);

  Option<dynamic> or<R extends Object>(Option<R> other);

  Result<Option<R>> cast<R extends Object>();
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

final class Some<T extends Object> extends Option<T> {
  final T value;

  const Some(this.value) : super._();

  @override
  @pragma('vm:prefer-inline')
  bool get isSome => true;

  @override
  @pragma('vm:prefer-inline')
  bool get isNone => false;

  @override
  @pragma('vm:prefer-inline')
  Some<T> get some => this;

  @protected
  @override
  @pragma('vm:prefer-inline')
  None<T> get none => throw const Err('Cannot get none from Some.');

  @override
  @pragma('vm:prefer-inline')
  Option<T> ifNone(void Function() fn) => this;

  @override
  @pragma('vm:prefer-inline')
  Option<T> ifSome(void Function(T value) fn) {
    fn(value);
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
  Option<R> map<R extends Object>(R Function(T value) fn) => Some(fn(value));

  @override
  @pragma('vm:prefer-inline')
  Option<T> filter(bool Function(T value) test) => test(value) ? this : const None();

  @override
  @pragma('vm:prefer-inline')
  Result<T> get asResult => Ok<T>(value);

  @override
  @pragma('vm:prefer-inline')
  Option<R> fold<R extends Object>(
    Option<R> Function(T value) onSome,
    Option<R> Function() onNone,
  ) {
    return onSome(value);
  }

  @override
  @pragma('vm:prefer-inline')
  Option<(T, R)> and<R extends Object>(Option<R> other) {
    if (other.isSome) {
      return Some((value, other.unwrap()));
    } else {
      return const None();
    }
  }

  @override
  @pragma('vm:prefer-inline')
  Option<dynamic> or<R extends Object>(Option<R> other) => this;

  @pragma('vm:prefer-inline')
  None<T> toNone() => const None();

  @override
  @pragma('vm:prefer-inline')
  String toString() => '${Some<T>}($value)';

  @override
  Result<Option<R>> cast<R extends Object>() {
    final value = unwrap();
    if (value is R) {
      return Ok(Option.fromNullable(value));
    } else {
      return Err('Cannot cast ${value.runtimeType} to $R');
    }
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

final class None<T extends Object> extends Option<T> {
  const None() : super._();

  @override
  @pragma('vm:prefer-inline')
  bool get isSome => false;

  @override
  @pragma('vm:prefer-inline')
  bool get isNone => true;

  @protected
  @override
  @pragma('vm:prefer-inline')
  Some<T> get some => throw const Err('Cannot get some from a None.');

  @override
  @pragma('vm:prefer-inline')
  Option<T> ifNone(void Function() fn) {
    fn();
    return this;
  }

  @override
  @pragma('vm:prefer-inline')
  Option<T> ifSome(void Function(T value) fn) => this;

  @override
  @pragma('vm:prefer-inline')
  None<T> get none => this;

  @protected
  @override
  @pragma('vm:prefer-inline')
  T unwrap() => throw const Err('Cannot unwrap a None.');

  @override
  @pragma('vm:prefer-inline')
  T unwrapOr(T fallback) => fallback;

  @override
  @pragma('vm:prefer-inline')
  Option<R> map<R extends Object>(R Function(T value) fn) => None<R>();

  @override
  @pragma('vm:prefer-inline')
  Result<T> get asResult => Err(None<T>());

  @override
  @pragma('vm:prefer-inline')
  Option<T> filter(bool Function(T value) test) => none;

  @override
  @pragma('vm:prefer-inline')
  Option<R> fold<R extends Object>(
    Option<R> Function(T value) onSome,
    Option<R> Function() onNone,
  ) {
    return onNone();
  }

  @override
  @pragma('vm:prefer-inline')
  Option<(T, R)> and<R extends Object>(Option<R> other) => const None();

  @override
  @pragma('vm:prefer-inline')
  Option<dynamic> or<R extends Object>(Option<R> other) => other;

  @override
  @pragma('vm:prefer-inline')
  String toString() => '${None<T>}()';

  @override
  @pragma('vm:prefer-inline')
  Result<Option<R>> cast<R extends Object>() => const Ok(None());
}
