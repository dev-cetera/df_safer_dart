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

import 'panic.dart';
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

  Some<T> get some;

  None<T> get none;

  Option<T> ifSome(void Function(T value) fn);

  Option<T> ifNone(void Function() fn);

  T unwrap();

  T unwrapOr(T fallback);

  T unwrapOrElse(T Function() fallback);

  Option<R> map<R extends Object>(R Function(T value) fn);

  Some<R> mapToSome<R extends Object>(R Function(Option<T> option) fn);

  Option<R> flatMap<R extends Object>(Option<R> Function(T value) fn);

  Option<T> filter(bool Function(T value) test);

  Result<T> get asResult;

  Option<R> fold<R extends Object>(
    Option<R> Function(T value) onSome,
    Option<R> Function() onNone,
  );

  Option<(T, R)> and<R extends Object>(Option<R> other);

  Option<dynamic> or<R extends Object>(Option<R> other);

  Option<dynamic> xor<R extends Object>(Option<R> other);

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
  Some<T> get some {
    return this;
  }

  @override
  @pragma('vm:prefer-inline')
  None<T> get none {
    throw Panic('[Some] Cannot get [none] from Some.');
  }

  @override
  @pragma('vm:prefer-inline')
  Option<T> ifNone(void Function() fn) {
    return this;
  }

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
  T unwrapOrElse(T Function() fallback) => value;

  @override
  @pragma('vm:prefer-inline')
  Option<R> map<R extends Object>(R Function(T value) fn) => Some(fn(value));

  @override
  @pragma('vm:prefer-inline')
  Some<R> mapToSome<R extends Object>(R Function(Option<T> option) fn) => Some(fn(some));

  @override
  @pragma('vm:prefer-inline')
  Option<R> flatMap<R extends Object>(Option<R> Function(T value) fn) => fn(value);

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

  @override
  @pragma('vm:prefer-inline')
  Option<dynamic> xor<R extends Object>(Option<R> other) {
    if (other.isNone) {
      return this;
    } else {
      return const None();
    }
  }

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

  @override
  @pragma('vm:prefer-inline')
  Some<T> get some {
    throw Panic('[None] Cannot get [some] from a None.');
  }

  @override
  @pragma('vm:prefer-inline')
  Option<T> ifNone(void Function() fn) {
    fn();
    return this;
  }

  @override
  @pragma('vm:prefer-inline')
  Option<T> ifSome(void Function(T value) fn) {
    return this;
  }

  @override
  @pragma('vm:prefer-inline')
  None<T> get none => this;

  @override
  @pragma('vm:prefer-inline')
  T unwrap() {
    throw Panic('[None] Cannot [unwrap] a None.');
  }

  @override
  @pragma('vm:prefer-inline')
  T unwrapOr(T fallback) => fallback;

  @override
  @pragma('vm:prefer-inline')
  T unwrapOrElse(T Function() fallback) => fallback();

  @override
  @pragma('vm:prefer-inline')
  Option<R> map<R extends Object>(R Function(T value) fn) => None<R>();

  @override
  @pragma('vm:prefer-inline')
  Some<R> mapToSome<R extends Object>(R Function(Option<T> option) fn) => Some(fn(none));

  @override
  @pragma('vm:prefer-inline')
  Option<R> flatMap<R extends Object>(Option<R> Function(T value) fn) => None<R>();

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
  Option<dynamic> xor<R extends Object>(Option<R> other) {
    if (other.isSome) {
      return other;
    } else {
      return const None();
    }
  }

  @override
  @pragma('vm:prefer-inline')
  String toString() => '${None<T>}()';

  @override
  @pragma('vm:prefer-inline')
  Result<Option<R>> cast<R extends Object>() => const Ok(None());
}
