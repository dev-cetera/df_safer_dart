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
    return Err(
      'Called none() on Some<$T>.',
    );
  }

  @override
  @pragma('vm:prefer-inline')
  Result<Some<T>> ifSome(
    @noFutures
    void Function(
      Some<T> self,
      Some<T> none,
    ) noFutures,
  ) {
    return Sync(() {
      noFutures(this, this);
      return this;
    }).value;
  }

  @override
  @pragma('vm:prefer-inline')
  Result<Some<T>> ifNone(
    @noFutures
    void Function(
      Some<T> self,
      None<T> none,
    ) noFutures,
  ) {
    return Ok(this);
  }

  @override
  @pragma('vm:prefer-inline')
  T? orNull() => value;

  @override
  @pragma('vm:prefer-inline')
  Some<T> mapSome(
    @noFutures Some<T> Function(Some<T> some) noFutures,
  ) {
    return noFutures(this);
  }

  @override
  @pragma('vm:prefer-inline')
  Option<R> flatMap<R extends Object>(
    @noFutures Option<R> Function(T value) noFutures,
  ) {
    return noFutures(UNSAFE(() => unwrap()));
  }

  @override
  @pragma('vm:prefer-inline')
  Option<T> filter(@noFutures bool Function(T value) noFutures) {
    return noFutures(value) ? this : const None();
  }

  @override
  @pragma('vm:prefer-inline')
  Result<Option<Object>> fold(
    @noFutures Option<Object>? Function(Some<T> some) onSome,
    @noFutures Option<Object>? Function(None<T> none) onNone,
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
    @noFutures R Function(T value) noFutures,
  ) {
    return Some(noFutures(value));
  }

  @override
  Result<Option<R>> transf<R extends Object>([
    @noFutures R Function(T e)? noFutures,
  ]) {
    try {
      UNSAFE:
      final value0 = unwrap();
      final value1 = noFutures?.call(value0) ?? value0 as R;
      return Ok(Option.from(value1));
    } catch (error, stackTrace) {
      assert(false, error);
      return Err(
        'Cannot transform $T to $R',
        stackTrace: stackTrace,
      );
    }
  }

  @override
  @pragma('vm:prefer-inline')
  Some<Some<T>> wrapInSome() => Some(this);

  @override
  @pragma('vm:prefer-inline')
  Ok<Some<T>> wrapInOk() => Ok(this);

  @override
  @pragma('vm:prefer-inline')
  Resolvable<Some<T>> wrapInResolvable() => Resolvable(() => this);

  @override
  @pragma('vm:prefer-inline')
  Sync<Some<T>> wrapInSync() => Sync.okValue(this);

  @override
  @pragma('vm:prefer-inline')
  Async<Some<T>> wrapInAsync() => Async.okValue(this);

  @override
  @pragma('vm:prefer-inline')
  Some<Some<T>> wrapValueInSome() => map((e) => Some(e));

  @override
  @pragma('vm:prefer-inline')
  Some<Ok<T>> wrapValueInOk() => map((e) => Ok(e));

  @override
  @pragma('vm:prefer-inline')
  Some<Resolvable<T>> wrapValueInResolvable() => map((e) => Sync.okValue(e));

  @override
  @pragma('vm:prefer-inline')
  Some<Sync<T>> wrapValueInSync() => map((e) => Sync.okValue(e));

  @override
  @pragma('vm:prefer-inline')
  Some<Async<T>> wrapValyeInAsync() => map((e) => Async.okValue(e));

  @override
  @visibleForTesting
  @pragma('vm:prefer-inline')
  Some<void> asVoid() => this;
}
