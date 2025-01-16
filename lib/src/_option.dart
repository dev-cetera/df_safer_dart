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

sealed class Option<T extends Object> extends Monad<T> {
  const Option._();

  factory Option.fromNullable(T? value) {
    if (value != null) {
      return Some(value);
    } else {
      return const None();
    }
  }

  bool isSome();

  bool isNone();

  @visibleForTesting
  Result<Some<T>> some();

  @visibleForTesting
  Result<None<T>> none();

  Option<T> ifSome(void Function(Some<T> some) callback);

  Option<T> ifNone(void Function() callback);

  @visibleForTesting
  T unwrap();

  T unwrapOr(T fallback);

  T unwrapOrElse(T Function() fallback) => unwrapOr(fallback());

  Option<R> map<R extends Object>(R Function(T value) mapper);

  Option<T> filter(bool Function(T value) test);

  Result<T> asResult();

  ResolvableOption<T> fold<R extends Object>(
    ResolvableOption<T> Function(Some<T> some) onSome,
    ResolvableOption<T> Function(None<T> none) onNone,
  );

  Option<(T, R)> and<R extends Object>(Option<R> other);

  Option<Object> or<R extends Object>(Option<R> other);

  Result<Option<R>> cast<R extends Object>();
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

final class Some<T extends Object> extends Option<T> {
  final T value;

  const Some(this.value) : super._();

  @override
  @pragma('vm:prefer-inline')
  bool isSome() => true;

  @override
  @pragma('vm:prefer-inline')
  bool isNone() => false;

  @override
  @pragma('vm:prefer-inline')
  Ok<Some<T>> some() => Ok(this);

  @protected
  @override
  @pragma('vm:prefer-inline')
  Result<None<T>> none() {
    return const Err(
      stack: [Some, 'some'],
      error: 'Cannot get None from Some.',
    );
  }

  @override
  @pragma('vm:prefer-inline')
  Option<T> ifNone(void Function() callback) => this;

  @override
  @pragma('vm:prefer-inline')
  Option<T> ifSome(void Function(Some<T> some) callback) {
    callback(this);
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
  Option<R> map<R extends Object>(R Function(T value) mapper) => Some(mapper(value));

  @override
  @pragma('vm:prefer-inline')
  Option<T> filter(bool Function(T value) test) => test(value) ? this : const None();

  @override
  @pragma('vm:prefer-inline')
  Result<T> asResult() => Ok<T>(value);

  @override
  @pragma('vm:prefer-inline')
  ResolvableOption<T> fold<R extends Object>(
    ResolvableOption<T> Function(Some<T> some) onSome,
    ResolvableOption<T> Function(None<T> none) onNone,
  ) {
    try {
      return onSome(this);
    } catch (e) {
      return SyncSome(
        Err(
          stack: [Some, 'fold'],
          error: e,
        ),
      );
    }
  }

  @override
  @pragma('vm:prefer-inline')
  Option<(T, R)> and<R extends Object>(Option<R> other) {
    if (other.isSome()) {
      return Some((value, other.unwrap()));
    } else {
      return const None();
    }
  }

  @override
  @pragma('vm:prefer-inline')
  Option<Object> or<R extends Object>(Option<R> other) => this;

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
      return Err(
        stack: [Some, 'cast'],
        error: 'Cannot cast ${value.runtimeType} to $R',
      );
    }
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

final class None<T extends Object> extends Option<T> {
  const None() : super._();

  @override
  @pragma('vm:prefer-inline')
  bool isSome() => false;

  @override
  @pragma('vm:prefer-inline')
  bool isNone() => true;

  @protected
  @override
  @pragma('vm:prefer-inline')
  Result<Some<T>> some() {
    return const Err(
      stack: [None, 'some'],
      error: 'Cannot get Some from a None.',
    );
  }

  @override
  @pragma('vm:prefer-inline')
  Option<T> ifNone(void Function() callback) {
    callback();
    return this;
  }

  @override
  @pragma('vm:prefer-inline')
  Option<T> ifSome(void Function(Some<T> some) callback) => this;

  @override
  @pragma('vm:prefer-inline')
  Ok<None<T>> none() => Ok(this);

  @nonVirtual
  @protected
  @override
  @pragma('vm:prefer-inline')
  T unwrap() {
    throw const Err(
      stack: [None, 'unwrap'],
      error: 'Cannot unwrap a None.',
    );
  }

  @override
  @pragma('vm:prefer-inline')
  T unwrapOr(T fallback) => fallback;

  @override
  @pragma('vm:prefer-inline')
  Option<R> map<R extends Object>(R Function(T value) mapper) => None<R>();

  @override
  @pragma('vm:prefer-inline')
  Result<T> asResult() {
    return const Err(
      stack: [None, 'asResult'],
      error: 'Cannot convert a None to a Result.',
    );
  }

  @override
  @pragma('vm:prefer-inline')
  Option<T> filter(bool Function(T value) test) => const None();

  @override
  @pragma('vm:prefer-inline')
  ResolvableOption<T> fold<R extends Object>(
    ResolvableOption<T> Function(Some<T> some) onSome,
    ResolvableOption<T> Function(None<T> none) onNone,
  ) {
    try {
      return onNone(this);
    } catch (e) {
      return SyncSome(
        Err(
          stack: [None, 'fold'],
          error: e,
        ),
      );
    }
  }

  @override
  @pragma('vm:prefer-inline')
  Option<(T, R)> and<R extends Object>(Option<R> other) => const None();

  @override
  @pragma('vm:prefer-inline')
  Option<Object> or<R extends Object>(Option<R> other) => other;

  @override
  @pragma('vm:prefer-inline')
  String toString() => '${None<T>}()';

  @override
  @pragma('vm:prefer-inline')
  Result<Option<R>> cast<R extends Object>() => const Ok(None());
}
