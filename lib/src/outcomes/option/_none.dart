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

part of '../outcome.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// A [Outcome] that represents an [Option] that does not contain a value.
final class None<T extends Object> extends Option<T> implements SyncImpl<T> {
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
  Result<None<T>> ifSome(
    @noFutures void Function(None<T> self, Some<T> some) noFutures,
  ) {
    return Ok(this);
  }

  @override
  @pragma('vm:prefer-inline')
  Result<None<T>> ifNone(
    @noFutures void Function(Option<T> self, None<T> none) noFutures,
  ) {
    return Sync(() {
      noFutures(this, this);
      return this;
    }).value;
  }

  @override
  @pragma('vm:prefer-inline')
  T? orNull() => null;

  @override
  @pragma('vm:prefer-inline')
  None<T> mapSome(@noFutures Some<T> Function(Some<T> some) noFutures) {
    return this;
  }

  @override
  @pragma('vm:prefer-inline')
  None<R> flatMap<R extends Object>(
    @noFutures Option<R> Function(T value) noFutures,
  ) {
    return const None();
  }

  @override
  @pragma('vm:prefer-inline')
  None<T> filter(@noFutures bool Function(T value) noFutures) {
    return const None();
  }

  @override
  @pragma('vm:prefer-inline')
  Result<Option<Object>> fold(
    @noFutures Option<Object>? Function(Some<T> some) onSome,
    @noFutures Option<Object>? Function(None<T> none) onNone,
  ) {
    try {
      return Ok(onNone(this) ?? this);
    } catch (error, stackTrace) {
      return Err(error, stackTrace: stackTrace);
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
  None<R> map<R extends Object>(@noFutures R Function(T value) noFutures) {
    return None<R>();
  }

  @override
  @pragma('vm:prefer-inline')
  Ok<None<R>> transf<R extends Object>([
    @noFutures R Function(T e)? noFutures,
  ]) {
    return const Ok(None());
  }
}
