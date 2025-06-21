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

part of '../monad.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// A [Monad] that represents an [Option] that does not contain a value.
final class None<T extends Object> extends Option<T> {
  @override
  @pragma('vm:prefer-inline')
  Unit get value => super.value as Unit;

  const None() : super._(Unit.instance);

  @override
  @pragma('vm:prefer-inline')
  bool isSome() => false;

  @override
  @pragma('vm:prefer-inline')
  bool isNone() => true;

  @override
  @pragma('vm:prefer-inline')
  Err<Some<T>> some() {
    return Err('Called some() on None<$T>.');
  }

  @override
  @pragma('vm:prefer-inline')
  Ok<None<T>> none() => Ok(this);

  @override
  @pragma('vm:prefer-inline')
  Ok<None<T>> ifSome(
    @noFuturesAllowed void Function(Some<T> some) noFuturesAllowed,
  ) {
    return Ok(this);
  }

  @override
  @pragma('vm:prefer-inline')
  Result<None<T>> ifNone(@noFuturesAllowed void Function() noFuturesAllowed) {
    try {
      noFuturesAllowed();
      return Ok(this);
    } catch (error) {
      return Err(error);
    }
  }

  @override
  @pragma('vm:prefer-inline')
  T? orNull() => null;

  @override
  @pragma('vm:prefer-inline')
  None<T> mapSome(
    @noFuturesAllowed Some<T> Function(Some<T> some) noFuturesAllowed,
  ) {
    return this;
  }

  @override
  @pragma('vm:prefer-inline')
  None<R> flatMap<R extends Object>(
    @noFuturesAllowed Option<R> Function(T value) noFuturesAllowed,
  ) {
    return const None();
  }

  @override
  @pragma('vm:prefer-inline')
  None<T> filter(@noFuturesAllowed bool Function(T value) noFuturesAllowed) {
    return const None();
  }

  @override
  @pragma('vm:prefer-inline')
  Result<Option<Object>> fold(
    @noFuturesAllowed Option<Object>? Function(Some<T> some) onSome,
    @noFuturesAllowed Option<Object>? Function(None<T> none) onNone,
  ) {
    try {
      return Ok(onNone(this) ?? this);
    } catch (error) {
      return Err(error);
    }
  }

  @override
  @pragma('vm:prefer-inline')
  Option<T> someOr(Option<T> other) => other;

  @override
  @pragma('vm:prefer-inline')
  None<T> noneOr(Option<T> other) => this;

  @override
  @protected
  @unsafeOrError
  @pragma('vm:prefer-inline')
  T unwrap() {
    throw Err<T>('Called unwrap() on None<$T>.');
  }

  @override
  @protected
  @pragma('vm:prefer-inline')
  T unwrapOr(T fallback) => fallback;

  @override
  @pragma('vm:prefer-inline')
  None<R> map<R extends Object>(
    @noFuturesAllowed R Function(T value) noFuturesAllowed,
  ) {
    return None<R>();
  }

  @override
  @pragma('vm:prefer-inline')
  Ok<None<R>> transf<R extends Object>([
    @noFuturesAllowed R Function(T e)? noFuturesAllowed,
  ]) {
    return const Ok(None());
  }

  @override
  @pragma('vm:prefer-inline')
  Some<None<T>> wrapSome() => Some(this);

  @override
  @pragma('vm:prefer-inline')
  Ok<None<T>> wrapOk() => Ok(this);

  @override
  @pragma('vm:prefer-inline')
  Resolvable<None<T>> wrapResolvable() => Resolvable(() => this);

  @override
  @pragma('vm:prefer-inline')
  Sync<None<T>> wrapSync() => Sync.unsafe(Ok(this));

  @override
  @pragma('vm:prefer-inline')
  Async<None<T>> wrapAsync() => Async.unsafe(Future.value(Ok(this)));

  @override
  @pragma('vm:prefer-inline')
  None<void> asVoid() => this;
}
