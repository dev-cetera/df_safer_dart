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

final class _Single<T extends Object> extends Monad<T> {
  @override
  @pragma('vm:prefer-inline')
  T get value => super.value as T;

  const _Single._(T super.value);

  @protected
  @override
  _Single<R> map<R extends Object>(R Function(T value) noFuturesAllowed) {
    return _Single._(noFuturesAllowed(value));
  }

  @override
  Result<_Single<R>> transf<R extends Object>([
    R Function(T e)? noFuturesAllowed,
  ]) {
    try {
      return Ok(_Single._(value as R));
    } catch (e) {
      assert(false, e);
      return Err('Cannot transform $T to $R');
    }
  }

  @protected
  @override
  T unwrap() => value;

  @protected
  @override
  FutureOr<T> unwrapOr(T fallback) => value;

  @override
  @pragma('vm:prefer-inline')
  Some<_Single<T>> wrapSome() => Some(this);

  @override
  @pragma('vm:prefer-inline')
  Ok<_Single<T>> wrapOk() => Ok(this);

  @override
  @pragma('vm:prefer-inline')
  Resolvable<_Single<T>> wrapResolvable() => Resolvable(() => this);

  @override
  @pragma('vm:prefer-inline')
  Sync<_Single<T>> wrapSync() => Sync.unsafe(Ok(this));

  @override
  @pragma('vm:prefer-inline')
  Async<_Single<T>> wrapAsync() => Async.unsafe(Future.value(Ok(this)));

  @override
  @pragma('vm:prefer-inline')
  _Single<void> asVoid() => this;

  @override
  FutureOr<void> end() {}
}
