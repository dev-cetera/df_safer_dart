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

import '../df_safer_dart.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

sealed class Option<T> {
  const Option._();

  factory Option(T? value) {
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

  void ifSome(void Function(T value) fn);

  void ifNone(void Function() fn);

  T unwrap();

  T unwrapOr(T fallback);

  T unwrapOrElse(T Function() fallback);

  Option<R> map<R>(R Function(T value) fn);

  Some<R> mapToSome<R>(R Function(Option<T> option) fn);

  Option<R> flatMap<R>(Option<R> Function(T value) fn);

  Option<T> filter(bool Function(T value) test);

  Result<T> get asResult;

  R fold<R>(R Function(T value) onSome, R Function() onNone);

  Option<(T, R)> and<R>(Option<R> other);

  Option<dynamic> or<R>(Option<R> other);
  
  Option<dynamic> xor<R>(Option<R> other);
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

final class Some<T> extends Option<T> with _EqualityMixin<T> {
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
    throw Panic('Cannot get [none] from Some.');
  }

  @override
  @pragma('vm:prefer-inline')
  void ifNone(void Function() fn) {
    // Do nothing.
  }

  @override
  @pragma('vm:prefer-inline')
  void ifSome(void Function(T value) fn) => fn(value);

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
  Option<R> map<R>(R Function(T value) fn) => Some(fn(value));

  @override
  @pragma('vm:prefer-inline')
  Some<R> mapToSome<R>(R Function(Option<T> option) fn) => Some(fn(some));

  @override
  @pragma('vm:prefer-inline')
  Option<R> flatMap<R>(Option<R> Function(T value) fn) => fn(value);

  @override
  @pragma('vm:prefer-inline')
  Option<T> filter(bool Function(T value) test) =>
      test(value) ? this : const None();

  @override
  @pragma('vm:prefer-inline')
  Result<T> get asResult => Ok<T>(value);

  @override
  @pragma('vm:prefer-inline')
  R fold<R>(R Function(T value) onSome, R Function() onNone) => onSome(value);

  @override
  @pragma('vm:prefer-inline')
  Option<(T, R)> and<R>(Option<R> other) {
    if (other.isSome) {
      return Some((value, other.unwrap()));
    } else {
      return const None();
    }
  }

  @override
  @pragma('vm:prefer-inline')
  Option<dynamic> or<R>(Option<R> other) => this;

  @override
  @pragma('vm:prefer-inline')
  Option<dynamic> xor<R>(Option<R> other) {
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
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

final class None<T> extends Option<T> with _EqualityMixin<T> {
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
    throw Panic('Cannot get [some] from a None.');
  }

  @override
  @pragma('vm:prefer-inline')
  void ifNone(void Function() fn) => fn();

  @override
  @pragma('vm:prefer-inline')
  void ifSome(void Function(T value) fn) {
    // Do nothing.
  }

  @override
  @pragma('vm:prefer-inline')
  None<T> get none => this;

  @override
  @pragma('vm:prefer-inline')
  T unwrap() {
    throw Panic('Cannot [unwrap] a None.');
  }

  @override
  @pragma('vm:prefer-inline')
  T unwrapOr(T fallback) => fallback;

  @override
  @pragma('vm:prefer-inline')
  T unwrapOrElse(T Function() fallback) => fallback();

  @override
  @pragma('vm:prefer-inline')
  Option<R> map<R>(R Function(T value) fn) => None<R>();

  @override
  @pragma('vm:prefer-inline')
  Some<R> mapToSome<R>(R Function(Option<T> option) fn) => Some(fn(none));

  @override
  @pragma('vm:prefer-inline')
  Option<R> flatMap<R>(Option<R> Function(T value) fn) => None<R>();

  @override
  @pragma('vm:prefer-inline')
  Result<T> get asResult => Err(None<T>());

  @override
  @pragma('vm:prefer-inline')
  Option<T> filter(bool Function(T value) test) => none;

  @override
  @pragma('vm:prefer-inline')
  R fold<R>(R Function(T value) onSome, R Function() onNone) => onNone();

  @override
  @pragma('vm:prefer-inline')
  Option<(T, R)> and<R>(Option<R> other) => const None();

  @override
  @pragma('vm:prefer-inline')
  Option<dynamic> or<R>(Option<R> other) => other;

  @override
  @pragma('vm:prefer-inline')
  Option<dynamic> xor<R>(Option<R> other) {
    if (other.isSome) {
      return other;
    } else {
      return const None();
    }
  }

  @override
  @pragma('vm:prefer-inline')
  String toString() => '${None<T>}()';
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

mixin _EqualityMixin<T> on Option<T> {
  @override
  @pragma('vm:prefer-inline')
  bool operator ==(Object other) {
    return fold(
      (e) => other is Some && e == other.value,
      () => other is None && none == other.none,
    );
  }

  @override
  @pragma('vm:prefer-inline')
  int get hashCode {
    return fold(
      (e) => e.hashCode,
      () => null.hashCode,
    );
  }
}
