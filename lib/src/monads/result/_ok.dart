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

part of '../monad/monad.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// A [Monad] that represents the success case of a [Result], containing a
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
  Result<T> ifOk(
    @noFuturesAllowed void Function(Ok<T> self, Ok<T> ok) noFuturesAllowed,
  ) {
    return Sync(() {
      noFuturesAllowed(this, this);
      return value;
    }).value;
  }

  @override
  @pragma('vm:prefer-inline')
  Result<T> ifErr(
    @noFuturesAllowed void Function(Ok<T> self, Err<T> err) noFuturesAllowed,
  ) {
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
    @noFuturesAllowed Result<R> Function(T value) noFuturesAllowed,
  ) {
    return noFuturesAllowed(unwrap());
  }

  @override
  @pragma('vm:prefer-inline')
  Ok<T> mapOk(@noFuturesAllowed Ok<T> Function(Ok<T> ok) noFuturesAllowed) {
    return noFuturesAllowed(this);
  }

  @override
  @pragma('vm:prefer-inline')
  Ok<T> mapErr(@noFuturesAllowed Err<T> Function(Err<T> err) noFuturesAllowed) {
    return this;
  }

  @override
  @pragma('vm:prefer-inline')
  Result<Object> fold(
    @noFuturesAllowed Result<Object>? Function(Ok<T> ok) onOk,
    @noFuturesAllowed Result<Object>? Function(Err<T> err) onErr,
  ) {
    try {
      return onOk(this) ?? this;
    } catch (error, stackTrace) {
      return Err(
        error,
        stackTrace: stackTrace,
      );
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
  Ok<R> map<R extends Object>(
    @noFuturesAllowed R Function(T value) noFuturesAllowed,
  ) {
    return Ok(noFuturesAllowed(value));
  }

  @override
  Result<R> transf<R extends Object>([
    @noFuturesAllowed R Function(T e)? noFuturesAllowed,
  ]) {
    try {
      final a = unwrap();
      final b = noFuturesAllowed?.call(a) ?? a as R;
      return Ok(b);
    } catch (error, stackTrace) {
      assert(false, error);
      return Err(
        'Cannot transform $T to $R.',
        stackTrace: stackTrace,
      );
    }
  }

  @override
  @pragma('vm:prefer-inline')
  Some<Ok<T>> wrapInSome() => Some(this);

  @override
  @pragma('vm:prefer-inline')
  Ok<Ok<T>> wrapInOk() => Ok(this);

  @override
  @pragma('vm:prefer-inline')
  Resolvable<Ok<T>> wrapInResolvable() => Resolvable(() => this);

  @override
  @pragma('vm:prefer-inline')
  Sync<Ok<T>> wrapInSync() => Sync.okValue(this);

  @override
  @pragma('vm:prefer-inline')
  Async<Ok<T>> wrapInAsync() => Async.okValue(this);

  @override
  @pragma('vm:prefer-inline')
  Ok<Some<T>> wrapValueInSome() => map((e) => Some(e));

  @override
  @pragma('vm:prefer-inline')
  Ok<Ok<T>> wrapValueInOk() => map((e) => Ok(e));

  @override
  @pragma('vm:prefer-inline')
  Ok<Resolvable<T>> wrapValueInResolvable() => map((e) => Sync.okValue(e));

  @override
  @pragma('vm:prefer-inline')
  Ok<Sync<T>> wrapValueInSync() => map((e) => Sync.okValue(e));

  @override
  @pragma('vm:prefer-inline')
  Ok<Async<T>> wrapValyeInAsync() => map((e) => Async.okValue(e));

  @override
  @visibleForTesting
  @pragma('vm:prefer-inline')
  Ok<void> asVoid() => this;
}
