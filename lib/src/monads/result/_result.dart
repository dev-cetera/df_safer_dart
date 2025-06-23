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

/// A [Monad] that represents the result of an operation: every [Result] is
/// either [Ok] and contains a success value, or [Err] and contains an error
/// value.
sealed class Result<T extends Object> extends Monad<T> implements SyncImpl<T> {
  /// Combines 2 [Result] monads into 1 containing a tuple of their values if
  /// all are [Ok].
  ///
  /// If any are [Err], applies [onErr] function to combine errors.
  ///
  /// See also: [combineResult].
  static Result<(T1, T2)> zip2<T1 extends Object, T2 extends Object>(
    Result<T1> r1,
    Result<T2> r2, [
    @noFuturesAllowed Err<(T1, T2)> Function(Result<T1>, Result<T2>)? onErr,
  ]) {
    final combined = combineResult<Object>(
      [r1, r2],
      onErr: onErr == null ? null : (l) => onErr(l[0].transf<T1>(), l[1].transf<T2>()).transfErr(),
    );
    return combined.map((l) => (l[0] as T1, l[1] as T2));
  }

  /// Combines 3 [Result] monads into 1 containing a tuple of their values if
  /// all are [Ok].
  ///
  /// If any are [Err], applies [onErr] function to combine errors.
  ///
  /// See also: [combineResult].
  static Result<(T1, T2, T3)> zip3<T1 extends Object, T2 extends Object, T3 extends Object>(
    Result<T1> r1,
    Result<T2> r2,
    Result<T3> r3, [
    @noFuturesAllowed Err<(T1, T2, T3)> Function(Result<T1>, Result<T2>, Result<T3>)? onErr,
  ]) {
    final combined = combineResult<Object>(
      [r1, r2, r3],
      onErr: onErr == null
          ? null
          : (l) => onErr(
                l[0].transf<T1>(),
                l[1].transf<T2>(),
                l[2].transf<T3>(),
              ).transfErr(),
    );
    return combined.map((l) => (l[0] as T1, l[1] as T2, l[2] as T3));
  }

  const Result._(super.value);

  /// Returns `this` as a base [Result] type.
  @pragma('vm:prefer-inline')
  Result<T> asResult() => this;

  /// Returns `true` if this [Result] is an [Ok].
  bool isOk();

  /// Returns `true` if this [Result] is an [Err].
  bool isErr();

  /// Performs a side-effect with the contained value if this is an [Ok].
  Result<T> ifOk(@noFuturesAllowed void Function(Ok<T> ok) noFuturesAllowed);

  /// Performs a side-effect with the contained error if this is an [Err].
  Result<T> ifErr(@noFuturesAllowed void Function(Err<T> err) noFuturesAllowed);

  /// Safely gets the [Err] instance.
  /// Returns a [Some] on [Err], or a [None] on [Ok].
  Option<Err<T>> err();

  /// Safely gets the [Ok] instance.
  /// Returns a [Some] on [Ok], or a [None] on [Err].
  Option<Ok<T>> ok();

  /// Returns the contained [Ok] value or `null`.
  T? orNull();

  /// Maps a `Result<T>` to `Result<R>` by applying a function that returns
  /// another [Result].
  Result<R> flatMap<R extends Object>(
    @noFuturesAllowed Result<R> Function(T value) noFuturesAllowed,
  );

  /// Transforms the inner [Ok] instance if this is an [Ok].
  Result<T> mapOk(@noFuturesAllowed Ok<T> Function(Ok<T> ok) noFuturesAllowed);

  /// Transforms the inner [Err] instance if this is an [Err].
  Result<T> mapErr(
    @noFuturesAllowed Err<T> Function(Err<T> err) noFuturesAllowed,
  );

  /// Folds the two cases of this [Result] into a single new [Result].
  Result<Object> fold(
    @noFuturesAllowed Result<Object>? Function(Ok<T> ok) onOk,
    @noFuturesAllowed Result<Object>? Function(Err<T> err) onErr,
  );

  /// Returns this if it's [Ok], otherwise returns the `other` [Result].
  Result<T> okOr(Result<T> other);

  /// Returns this if it's [Err], otherwise returns the `other` [Result].
  Result<T> errOr(Result<T> other);

  @override
  @unsafeOrError
  T unwrap();

  @override
  T unwrapOr(T fallback);

  @override
  Result<R> map<R extends Object>(
    @noFuturesAllowed R Function(T value) noFuturesAllowed,
  );

  @override
  Result<R> transf<R extends Object>([
    @noFuturesAllowed R Function(T e)? noFuturesAllowed,
  ]);

  @override
  @pragma('vm:prefer-inline')
  Some<Result<T>> wrapSome() => Some(this);

  @override
  @pragma('vm:prefer-inline')
  Ok<Result<T>> wrapOk() => Ok(this);

  @override
  @pragma('vm:prefer-inline')
  Resolvable<Result<T>> wrapResolvable() => Resolvable(() => this);

  @override
  @pragma('vm:prefer-inline')
  Sync<Result<T>> wrapSync() => Sync.unsafe(Ok(this));

  @override
  @pragma('vm:prefer-inline')
  Async<Result<T>> wrapAsync() => Async.unsafe(Future.value(Ok(this)));

  @override
  @pragma('vm:prefer-inline')
  Result<void> asVoid() => this;

  @override
  @nonVirtual
  @pragma('vm:prefer-inline')
  void end() {}
}
