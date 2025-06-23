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

/// A [Monad] that represents an [Option] that contains a [value].
final class Some<T extends Object> extends Option<T> implements SyncImpl<T> {
  @override
  @pragma('vm:prefer-inline')
  T get value => super.value as T;

  const Some(T super.value) : super._();

  @override
  @pragma('vm:prefer-inline')
  bool isSome() => true;

  @override
  @pragma('vm:prefer-inline')
  bool isNone() => false;

  @override
  @pragma('vm:prefer-inline')
  Ok<Some<T>> some() => Ok(this);

  @override
  @pragma('vm:prefer-inline')
  Err<None<T>> none() {
    return Err('Called none() on Some<$T>.');
  }

  @override
  @pragma('vm:prefer-inline')
  Result<Some<T>> ifSome(
    @noFuturesAllowed void Function(Some<T> some) noFuturesAllowed,
  ) {
    try {
      noFuturesAllowed(this);
      return Ok(this);
    } catch (error) {
      return Err(error);
    }
  }

  @override
  @pragma('vm:prefer-inline')
  Ok<Some<T>> ifNone(@noFuturesAllowed void Function() noFuturesAllowed) {
    return Ok(this);
  }

  @override
  @pragma('vm:prefer-inline')
  T? orNull() => value;

  @override
  @pragma('vm:prefer-inline')
  Some<T> mapSome(
    @noFuturesAllowed Some<T> Function(Some<T> some) noFuturesAllowed,
  ) {
    return noFuturesAllowed(this);
  }

  @override
  @pragma('vm:prefer-inline')
  Option<R> flatMap<R extends Object>(
    @noFuturesAllowed Option<R> Function(T value) noFuturesAllowed,
  ) {
    return noFuturesAllowed(UNSAFE(() => unwrap()));
  }

  @override
  @pragma('vm:prefer-inline')
  Option<T> filter(@noFuturesAllowed bool Function(T value) noFuturesAllowed) {
    return noFuturesAllowed(value) ? this : const None();
  }

  @override
  @pragma('vm:prefer-inline')
  Result<Option<Object>> fold(
    @noFuturesAllowed Option<Object>? Function(Some<T> some) onSome,
    @noFuturesAllowed Option<Object>? Function(None<T> none) onNone,
  ) {
    try {
      return Ok(onSome(this) ?? this);
    } catch (error) {
      return Err(error);
    }
  }

  @override
  @pragma('vm:prefer-inline')
  Some<T> someOr(Option<T> other) => this;

  @override
  @pragma('vm:prefer-inline')
  Option<T> noneOr(Option<T> other) => other;

  @override
  @unsafeOrError
  @pragma('vm:prefer-inline')
  T unwrap() => value;

  @override
  @pragma('vm:prefer-inline')
  T unwrapOr(T fallback) => value;

  @override
  @pragma('vm:prefer-inline')
  Some<R> map<R extends Object>(
    @noFuturesAllowed R Function(T value) noFuturesAllowed,
  ) {
    return Some(noFuturesAllowed(value));
  }

  @override
  Result<Option<R>> transf<R extends Object>([
    @noFuturesAllowed R Function(T e)? noFuturesAllowed,
  ]) {
    try {
      UNSAFE:
      final value0 = unwrap();
      final value1 = noFuturesAllowed?.call(value0) ?? value0 as R;
      return Ok(Option.from(value1));
    } catch (e) {
      assert(false, e);
      return Err('Cannot transform $T to $R');
    }
  }

  @override
  @pragma('vm:prefer-inline')
  Some<Some<T>> wrapSome() => Some(this);

  @override
  @pragma('vm:prefer-inline')
  Ok<Some<T>> wrapOk() => Ok(this);

  @override
  @pragma('vm:prefer-inline')
  Resolvable<Some<T>> wrapResolvable() => Resolvable(() => this);

  @override
  @pragma('vm:prefer-inline')
  Sync<Some<T>> wrapSync() => Sync.unsafe(Ok(this));

  @override
  @pragma('vm:prefer-inline')
  Async<Some<T>> wrapAsync() => Async.unsafe(Future.value(Ok(this)));

  @override
  @pragma('vm:prefer-inline')
  Some<void> asVoid() => this;
}
