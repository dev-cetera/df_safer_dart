//.title
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//
// Copyright © dev-cetera.com & contributors.
//
// The use of this source code is governed by an MIT-style license described in
// the LICENSE file located in this project's root directory.
//
// See: https://opensource.org/license/mit
//
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//.title~

part of '../outcome.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// A [Outcome] that represents the success case of a [Result], containing a
/// [value].
final class Ok<T extends Object> extends Result<T> implements SyncImpl<T> {
  @override
  @pragma('vm:prefer-inline')
  T get value => super.value as T;

  const Ok(T super.value) : super._();

  @override
  @pragma('vm:prefer-inline')
  bool isOk() => true;

  @override
  @pragma('vm:prefer-inline')
  bool isErr() => false;

  @override
  @pragma('vm:prefer-inline')
  Result<T> ifOk(@noFutures void Function(Ok<T> self, Ok<T> ok) noFutures) {
    return Sync(() {
      noFutures(this, this);
      return value;
    }).value;
  }

  @override
  @pragma('vm:prefer-inline')
  Result<T> ifErr(@noFutures void Function(Ok<T> self, Err<T> err) noFutures) {
    return this;
  }

  @override
  @pragma('vm:prefer-inline')
  None<Err<T>> err() => const None();

  @override
  @pragma('vm:prefer-inline')
  Some<Ok<T>> ok() => Some(this);

  @override
  @pragma('vm:prefer-inline')
  T? orNull() => value;

  @override
  @pragma('vm:prefer-inline')
  Result<R> flatMap<R extends Object>(
    @noFutures Result<R> Function(T value) noFutures,
  ) {
    return noFutures(unwrap());
  }

  @override
  @pragma('vm:prefer-inline')
  Ok<T> mapOk(@noFutures Ok<T> Function(Ok<T> ok) noFutures) {
    return noFutures(this);
  }

  @override
  @pragma('vm:prefer-inline')
  Ok<T> mapErr(@noFutures Err<T> Function(Err<T> err) noFutures) {
    return this;
  }

  @override
  @pragma('vm:prefer-inline')
  Result<Object> fold(
    @noFutures Result<Object>? Function(Ok<T> ok) onOk,
    @noFutures Result<Object>? Function(Err<T> err) onErr,
  ) {
    try {
      return onOk(this) ?? this;
    } catch (error, stackTrace) {
      assert(false, error);
      return Err(error, stackTrace: stackTrace);
    }
  }

  @override
  @pragma('vm:prefer-inline')
  Ok<T> okOr(Result<T> other) => this;

  @override
  @pragma('vm:prefer-inline')
  Result<T> errOr(Result<T> other) => other;

  @override
  @pragma('vm:prefer-inline')
  T unwrap() => value;

  @override
  @pragma('vm:prefer-inline')
  T unwrapOr(T fallback) => value;

  @override
  @pragma('vm:prefer-inline')
  Ok<R> map<R extends Object>(@noFutures R Function(T value) noFutures) {
    return Ok(noFutures(value));
  }

  @override
  Result<R> transf<R extends Object>([@noFutures R Function(T e)? noFutures]) {
    try {
      final a = value;
      final b = noFutures?.call(a) ?? a as R;
      return Ok(b);
    } catch (error, stackTrace) {
      assert(false, error);
      return Err('Cannot transform $T to $R.', stackTrace: stackTrace);
    }
  }
}
