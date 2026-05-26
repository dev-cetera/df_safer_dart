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

  /// Returns `noFutures(value)`, absorbing any throw from the callback into an
  /// [Err]. The return type is widened from `Ok<R>` to `Result<R>` so the
  /// absorbed error has a place to live.
  @override
  @pragma('vm:prefer-inline')
  Result<R> flatMap<R extends Object>(
    @noFutures Result<R> Function(T value) noFutures,
  ) {
    try {
      return noFutures(unwrap());
    } on Err catch (err) {
      // Preserve a user-thrown Err's statusCode/breadcrumbs verbatim — the
      // package contract is that thrown Err values propagate without being
      // re-wrapped.
      return err.transfErr<R>();
    } catch (error, stackTrace) {
      return Err<R>(error, stackTrace: stackTrace);
    }
  }

  /// Absorbs any throw from the callback into an [Err]. Widened from `Ok<T>`
  /// to `Result<T>` to make room for the absorbed error.
  @override
  @pragma('vm:prefer-inline')
  Result<T> mapOk(@noFutures Ok<T> Function(Ok<T> ok) noFutures) {
    try {
      return noFutures(this);
    } on Err catch (err) {
      return err.transfErr<T>();
    } catch (error, stackTrace) {
      return Err<T>(error, stackTrace: stackTrace);
    }
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
    } on Err catch (err) {
      return err.transfErr<Object>();
    } catch (error, stackTrace) {
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

  /// Applies [noFutures] to the contained value and wraps the result in [Ok].
  /// Any throw from the callback becomes an [Err]. Widened from `Ok<R>` to
  /// `Result<R>` so the absorbed error has a place to live.
  @override
  @pragma('vm:prefer-inline')
  Result<R> map<R extends Object>(@noFutures R Function(T value) noFutures) {
    try {
      return Ok(noFutures(value));
    } on Err catch (err) {
      return err.transfErr<R>();
    } catch (error, stackTrace) {
      return Err<R>(error, stackTrace: stackTrace);
    }
  }

  @override
  Result<R> transf<R extends Object>([@noFutures R Function(T e)? noFutures]) {
    try {
      final a = value;
      final b = noFutures?.call(a) ?? a as R;
      return Ok(b);
    } on Err catch (err) {
      // If the user-supplied transformer throws an `Err`, preserve it
      // verbatim — wrapping it as a string in another Err would discard the
      // statusCode/breadcrumbs that life-critical callers may rely on.
      return err.transfErr<R>();
    } catch (error, stackTrace) {
      return Err(
        'Cannot transform $T to $R: $error',
        stackTrace: stackTrace,
      );
    }
  }
}
