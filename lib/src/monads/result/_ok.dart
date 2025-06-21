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

/// A [Monad] that represents the success case of a [Result], containing a
/// [value].
final class Ok<T extends Object> extends Result<T> {
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
  Result<T> ifOk(@noFuturesAllowed void Function(Ok<T> ok) noFuturesAllowed) {
    try {
      noFuturesAllowed(this);
      return this;
    } catch (error) {
      return Err(error);
    }
  }

  @override
  @pragma('vm:prefer-inline')
  Ok<T> ifErr(@noFuturesAllowed void Function(Err<T> err) noFuturesAllowed) => this;

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
    } catch (error) {
      return Err(error);
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
    } catch (e) {
      assert(false, e);
      return Err('Cannot transform $T to $R.');
    }
  }

  @override
  @pragma('vm:prefer-inline')
  Some<Ok<T>> wrapSome() => Some(this);

  @override
  @pragma('vm:prefer-inline')
  Ok<Ok<T>> wrapOk() => Ok(this);

  @override
  @pragma('vm:prefer-inline')
  Resolvable<Ok<T>> wrapResolvable() => Resolvable(() => this);

  @override
  @pragma('vm:prefer-inline')
  Sync<Ok<T>> wrapSync() => Sync.unsafe(Ok(this));

  @override
  @pragma('vm:prefer-inline')
  Async<Ok<T>> wrapAsync() => Async.unsafe(Future.value(Ok(this)));

  @override
  @pragma('vm:prefer-inline')
  Ok<void> asVoid() => this;
}
