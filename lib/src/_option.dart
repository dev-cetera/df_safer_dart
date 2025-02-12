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

  Result<Some<T>> some();

  Result<None<T>> none();

  @pragma('vm:prefer-inline')
  Option<T> option() => this;

  Result<Option<T>> ifSome(void Function(Some<T> some) unsafe);

  Result<Option<T>> ifNone(void Function() unsafe);

  T unwrap();

  T unwrapOr(T fallback);

  @pragma('vm:prefer-inline')
  T unwrapOrElse(T Function() unsafe) => unwrapOr(unsafe());

  @visibleForTesting
  T? orNull();

  Option<R> map<R extends Object>(R Function(T value) mapper);

  R mapOr<R extends Object>(R Function(T value) unsafe, R fallback);

  Option<T> filter(bool Function(T value) test);

  Result<T> asResult();

  Result<Option<Object>> fold(
    Option<Object>? Function(Some<T> some) onSome,
    Option<Object>? Function(None<T> none) onNone,
  );

  R when<R extends Object>({
    required R Function(T value) onSomeUnsafe,
    required R Function() onNoneUnsafe,
  });

  (Option<T>, Option<R>) and<R extends Object>(Option<R> other);

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
  Err<None<T>> none() {
    return const Err(stack: ['Some', 'some'], error: 'Called none() on Some.');
  }

  @override
  @pragma('vm:prefer-inline')
  Ok<Some<T>> ifNone(void Function() unsafe) => Ok(this);

  @override
  @pragma('vm:prefer-inline')
  Result<Some<T>> ifSome(void Function(Some<T> some) unsafe) {
    try {
      unsafe(this);
      return Ok(this);
    } catch (e) {
      return Err(stack: ['Some', 'ifSome'], error: e);
    }
  }

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
  Some<R> map<R extends Object>(R Function(T value) mapper) => Some(mapper(value));

  @protected
  @override
  @pragma('vm:prefer-inline')
  R mapOr<R extends Object>(R Function(T value) unsafe, R fallback) => unsafe(value);

  @override
  @pragma('vm:prefer-inline')
  Option<T> filter(bool Function(T value) test) => test(value) ? this : const None();

  @override
  @pragma('vm:prefer-inline')
  Ok<T> asResult() => Ok<T>(value);

  @override
  @pragma('vm:prefer-inline')
  Result<Option<Object>> fold(
    Option<Object>? Function(Some<T> some) onSome,
    Option<Object>? Function(None<T> none) onNone,
  ) {
    try {
      return Ok(onSome(this) ?? this);
    } catch (e) {
      return Err(stack: ['Some', 'fold'], error: e);
    }
  }

  @protected
  @override
  R when<R extends Object>({
    required R Function(T value) onSomeUnsafe,
    required R Function() onNoneUnsafe,
  }) {
    return onSomeUnsafe(this.value);
  }

  @override
  @pragma('vm:prefer-inline')
  (Option<T>, Option<R>) and<R extends Object>(Option<R> other) {
    if (other.isSome()) {
      return (this, other);
    } else {
      return (const None(), const None());
    }
  }

  @override
  @pragma('vm:prefer-inline')
  Some<Object> or<R extends Object>(Option<R> other) => this;

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
        stack: ['Some', 'cast'],
        error: 'Tried casting ${value.runtimeType} to $R',
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
  Err<Some<T>> some() {
    return const Err(stack: ['None', 'some'], error: 'Called some() on None.');
  }

  @override
  @pragma('vm:prefer-inline')
  Result<None<T>> ifNone(void Function() unsafe) {
    try {
      unsafe();
      return Ok(this);
    } catch (e) {
      return Err(stack: ['None', 'ifNone'], error: e);
    }
  }

  @override
  @pragma('vm:prefer-inline')
  Ok<None<T>> ifSome(void Function(Some<T> some) unsafe) => Ok(this);

  @override
  @pragma('vm:prefer-inline')
  Ok<None<T>> none() => Ok(this);

  @protected
  @override
  @pragma('vm:prefer-inline')
  T unwrap() {
    throw const Err(
      stack: ['None', 'unwrap'],
      error: 'Called unwrap() on None.',
    );
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
  None<R> map<R extends Object>(R Function(T value) mapper) => None<R>();

  @protected
  @override
  @pragma('vm:prefer-inline')
  R mapOr<R extends Object>(R Function(T value) unsafe, R fallback) => fallback;

  @override
  @pragma('vm:prefer-inline')
  Err<T> asResult() {
    return const Err(
      stack: ['None', 'asResult'],
      error: 'Tried converting None to Result.',
    );
  }

  @override
  @pragma('vm:prefer-inline')
  None<T> filter(bool Function(T value) test) => const None();

  @override
  @pragma('vm:prefer-inline')
  Result<Option<Object>> fold(
    Option<Object>? Function(Some<T> some) onSome,
    Option<Object>? Function(None<T> none) onNone,
  ) {
    try {
      return Ok(onNone(this) ?? this);
    } catch (e) {
      throw Err(stack: ['Option', 'fold'], error: e);
    }
  }

  @protected
  @override
  R when<R extends Object>({
    required R Function(T value) onSomeUnsafe,
    required R Function() onNoneUnsafe,
  }) {
    return onNoneUnsafe();
  }

  @override
  @pragma('vm:prefer-inline')
  (None<T>, None<R>) and<R extends Object>(Option<R> other) => (
        const None(),
        const None(),
      );

  @override
  @pragma('vm:prefer-inline')
  Option<Object> or<R extends Object>(Option<R> other) => other;

  @override
  @pragma('vm:prefer-inline')
  String toString() => '${None<T>}()';

  @override
  @pragma('vm:prefer-inline')
  Ok<None<R>> cast<R extends Object>() => const Ok(None());
}
