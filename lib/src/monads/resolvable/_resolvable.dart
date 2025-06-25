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

// ignore_for_file: no_future_monads

part of '../monad.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// A [Monad] that represents a value which can be resolved either synchronously
/// [Sync] or asynchronously [Async].
///
/// The [value] of a [Sync] is never a [Future] while the value of an [Async]
/// is always a [Future].
sealed class Resolvable<T extends Object> extends Monad<T> {
  @override
  @pragma('vm:prefer-inline')
  FutureOr<Result<T>> get value => super.value as FutureOr<Result<T>>;

  @protected
  @unsafeOrError
  const Resolvable.result(FutureOr<Result<T>> super.value);

  @protected
  @unsafeOrError
  const Resolvable.ok(FutureOr<Ok<T>> super.value);

  @protected
  @unsafeOrError
  const Resolvable.err(FutureOr<Err<T>> super.value);

  /// Combines 2 [Resolvable] monads into 1 containing a tuple of their values
  /// if all resolve to [Ok].
  ///
  /// If any resolve to [Err], applies [onErr] function to combine errors.
  ///
  /// See also: [combineResolvable].
  static Resolvable<(T1, T2)> combine2<T1 extends Object, T2 extends Object>(
    Resolvable<T1> r1,
    Resolvable<T2> r2, [
    @noFutures Err<(T1, T2)> Function(Result<T1>, Result<T2>)? onErr,
  ]) {
    final combined = combineResolvable<Object>(
      [r1, r2],
      onErr: onErr == null
          ? null
          : (l) => onErr(l[0].transf<T1>(), l[1].transf<T2>()).transfErr(),
    );
    return combined.map((l) => (l[0] as T1, l[1] as T2));
  }

  /// Combines 3 [Resolvable] monads into 1 containing a tuple of their values
  /// if all resolve to [Ok].
  ///
  /// If any resolve to [Err], applies [onErr] function to combine errors.
  ///
  /// See also: [combineResolvable].
  static Resolvable<(T1, T2, T3)>
  combine3<T1 extends Object, T2 extends Object, T3 extends Object>(
    Resolvable<T1> r1,
    Resolvable<T2> r2,
    Resolvable<T3> r3, [
    @noFutures
    Err<(T1, T2, T3)> Function(Result<T1>, Result<T2>, Result<T3>)? onErr,
  ]) {
    final combined = combineResolvable<Object>(
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

  /// Creates a [Sync] or [Async] depending on the return type of
  /// [mustAwaitAllFutures].
  ///
  /// # IMPORTANT:
  ///
  /// Always all futures witin [mustAwaitAllFutures] to ensure errors are be
  /// caught and propagated.
  factory Resolvable(
    @mustBeAnonymous
    @mustAwaitAllFutures
    FutureOr<T> Function() mustAwaitAllFutures, {
    @noFutures TOnErrorCallback<T>? onError,
    @noFutures TVoidCallback? onFinalize,
  }) {
    final result = mustAwaitAllFutures();
    if (result is Future<T>) {
      return Async(() => result, onError: onError, onFinalize: onFinalize);
    } else {
      return Sync(() => result, onError: onError, onFinalize: onFinalize);
    }
  }

  /// Returns `this` as a base [Resolvable] type.
  @pragma('vm:prefer-inline')
  Resolvable<T> asResolvable() => this;

  /// Returns `true` if this is a [Sync] instance.
  bool isSync();

  /// Returns `true` if this is an [Async] instance.
  bool isAsync();

  /// Safely gets the [Sync] instance.
  /// Returns an [Ok] on [Sync], or an [Err] on [Async].
  Result<Sync<T>> sync();

  /// Safely gets the [Async] instance.
  /// Returns an [Ok] on [Async], or an [Err] on [Sync].
  Result<Async<T>> async();

  /// Performs a side-effect if this is [Sync].
  Resolvable<T> ifSync(
    @noFutures void Function(Resolvable<T> self, Sync<T> sync) noFutures,
  );

  /// Performs a side-effect if this is [Async].
  Resolvable<T> ifAsync(
    @noFutures void Function(Resolvable<T> self, Async<T> async) noFutures,
  );

  /// Performs a side-effect if this is [Ok].
  Resolvable<T> ifOk(
    @noFutures void Function(Resolvable<T> self, Ok<T> ok) noFutures,
  );

  /// Performs a side-effect if this is [Err].
  Resolvable<T> ifErr(
    @noFutures void Function(Resolvable<T> self, Err<T> err) noFutures,
  );

  /// Maps the inner [Result] of this [Resolvable] using `mapper`.
  Resolvable<R> resultMap<R extends Object>(
    @noFutures Result<R> Function(Result<T> value) noFutures,
  );

  /// Maps the contained [Ok] value using a function that returns a `FutureOr`.
  Resolvable<R> mapFutureOr<R extends Object>(
    FutureOr<R> Function(T value) mapper,
  );

  /// Handles [Sync] and [Async] cases to produce a new [Resolvable].
  Resolvable<Object> fold(
    @noFutures Resolvable<Object>? Function(Sync<T> sync) onSync,
    @noFutures Resolvable<Object>? Function(Async<T> async) onAsync,
  );

  /// Exhaustively handles the inner [Ok] and [Err] cases, returning a new
  /// [Resolvable].
  Resolvable<Object> foldResult(
    @noFutures Result<Object>? Function(Ok<T> ok) onOk,
    @noFutures Result<Object>? Function(Err<T> err) onErr,
  );

  /// Ensures that resolving this value takes at least a specified [duration].
  /// If [duration] is null, this method returns the original value immediately.
  Resolvable<T> withMinDuration(Duration? duration) {
    if (duration == null) {
      return this;
    }
    return Async<Result<T>>(() async {
      return _withMinDuration(value, duration);
    }).flatten();
  }

  FutureOr<R> _withMinDuration<R extends Object>(
    FutureOr<R> input,
    Duration? duration,
  ) {
    if (duration == null) {
      return input;
    }
    return Future.wait([
      Future.value(input),
      Future<void>.delayed(duration),
    ]).then((e) => e.first as R);
  }

  /// Unsafely converts this [Resolvable] to a [Sync]. Throws if it's an [Async].
  Sync<T> toSync();

  /// Converts this [Resolvable] to an [Async].
  Async<T> toAsync();

  /// Returns the contained [Ok] value or `null`, resolving any [Future].
  Future<T?> orNull();

  /// Returns this if it's [Sync], otherwise returns `other`.
  Resolvable<T> syncOr(Resolvable<T> other);

  /// Returns this if it's [Async], otherwise returns `other`.
  Resolvable<T> asyncOr(Resolvable<T> other);

  /// Returns this if it contains an [Ok], otherwise returns `other`.
  Resolvable<T> okOr(Resolvable<T> other);

  /// Returns this if it contains an [Err], otherwise returns `other`.
  Resolvable<T> errOr(Resolvable<T> other);

  /// Safely gets the [Ok] instance, resolving any [Future].
  FutureOr<Option<Ok<T>>> ok();

  /// Safely gets the [Err] instance, resolving any [Future].
  FutureOr<Option<Err<T>>> err();

  @override
  @unsafeOrError
  FutureOr<T> unwrap();

  @override
  FutureOr<T> unwrapOr(T fallback);

  /// Prefer using [then] for [Resolvable].
  @protected
  @override
  Resolvable<R> map<R extends Object>(@noFutures R Function(T value) noFutures);

  Resolvable<R> then<R extends Object>(
    @noFutures R Function(T value) noFutures,
  );

  Resolvable<R> whenComplete<R extends Object>(
    @noFutures Resolvable<R> Function(Sync<T> resolved) noFutures,
  );

  @override
  Resolvable<R> transf<R extends Object>([
    @noFutures R Function(T e)? noFutures,
  ]);
}
