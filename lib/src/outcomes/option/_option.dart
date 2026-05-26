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

/// A [Outcome] that represents an optional value: every [Option] is either
/// [Some] and contains a value, or [None] and does not.
sealed class Option<T extends Object> extends Outcome<T>
    implements SyncImpl<T> {
  /// Combines 2 [Option] outcomes into 1 containing a tuple of their values if
  /// all are [Some].
  ///
  /// Returns [None] if any are [None].
  ///
  /// See also: [combineOption].
  static Option<(T1, T2)> combine2<T1 extends Object, T2 extends Object>(
    Option<T1> o1,
    Option<T2> o2,
  ) {
    return combineOption<Object>([o1, o2]).map((l) => (l[0] as T1, l[1] as T2));
  }

  /// Combines 3 [Option] outcomes into 1 containing a tuple of their values if
  /// all are [Some].
  ///
  /// Returns [None] if any are [None].
  ///
  /// See also: [combineOption].
  static Option<(T1, T2, T3)>
      combine3<T1 extends Object, T2 extends Object, T3 extends Object>(
    Option<T1> o1,
    Option<T2> o2,
    Option<T3> o3, //,
  ) {
    return combineOption<Object>([
      o1,
      o2,
      o3,
    ]).map((l) => (l[0] as T1, l[1] as T2, l[2] as T3));
  }

  const Option._(super.value);

  /// Creates an [Option] from a nullable value.
  ///
  /// Returns [Some] if the [value] is not `null`, otherwise returns [None].
  @pragma('vm:prefer-inline')
  factory Option.from(T? value) {
    // This is already safe and idiomatic, no switch needed here.
    if (value != null) {
      return Some(value);
    } else {
      return const None();
    }
  }

  @Deprecated('Use "Option.from(T? value)" instead.')
  @pragma('vm:prefer-inline')
  factory Option.fromNullable(T? value) => Option.from(value);

  /// Returns `this` as a base [Option] type.
  @pragma('vm:prefer-inline')
  Option<T> asOption() => this;

  /// Returns `true` if this [Option] is a [Some].
  bool isSome();

  /// Returns `true` if this [Option] is a [None].
  bool isNone();

  /// Safely gets the [Some] instance.  Returns an [Ok] on [Some], or an [Err]
  /// on [None].
  Result<Some<T>> some();

  /// Safely gets the [None] instance. Returns an [Ok] on [None], or an [Err]
  /// on [Some].
  Result<None<T>> none();

  /// Performs a side-effect with the contained value if this is a [Some].
  Result<Option<T>> ifSome(
    @noFutures void Function(Option<T> self, Some<T> some) noFutures,
  );

  /// Performs a side-effect if this is a [None].
  Result<Option<T>> ifNone(
    @noFutures void Function(Option<T> self, None<T> none) noFutures,
  );

  /// Returns the contained value or `null`.
  T? orNull();

  /// Transforms the inner [Some] instance if this is a [Some].
  Option<T> mapSome(@noFutures Some<T> Function(Some<T> some) noFutures);

  /// Transforms the inner [None] instance if this is a [None].
  ///
  /// All `None<T>` instances are structurally identical (no value), so a
  /// caller-supplied transformer has nothing meaningful to change. Provided
  /// for pair-axis symmetry with [mapSome] and [Result.mapErr] — real code
  /// almost always wants [fold] or [ifNone] instead.
  @visibleForTesting
  Option<T> mapNone(@noFutures None<T> Function(None<T> none) noFutures);

  /// Maps an `Option<T>` to `Option<R>` by applying a function that returns
  /// another [Option].
  ///
  /// ### ⚠️ Callback must not throw
  ///
  /// `Option<R>` has no `Err` variant — there is no slot to record a failure
  /// here. If your transformation can fail, use [fold] or [transf] (both of
  /// which return a [Result] that *can* hold an [Err]), or lift the call via
  /// `Sync(() => f(value))` to land in the safer `Result` world.
  Option<R> flatMap<R extends Object>(
    @noFutures Option<R> Function(T value) noFutures,
  );

  /// Returns [None] if the predicate [noFutures] returns `false`.
  /// Otherwise, returns the original [Option].
  ///
  /// ### ⚠️ Callback must not throw
  ///
  /// `Option<T>` has no `Err` variant. Throwing predicates escape to the
  /// caller. If your predicate can fail, lift it via `Sync(() => p(value))`.
  Option<T> filter(@noFutures bool Function(T value) noFutures);

  /// Folds the two cases of this [Option] into a single [Result].
  ///
  /// The `onSome` and `onNone` functions must return a new [Option].
  Result<Option<Object>> fold(
    @noFutures Option<Object>? Function(Some<T> some) onSome,
    @noFutures Option<Object>? Function(None<T> none) onNone,
  );

  /// Returns this if it's [Some], otherwise returns the `other` [Option].
  Option<T> someOr(Option<T> other);

  /// Returns this if it's [None], otherwise returns the `other` [Option].
  Option<T> noneOr(Option<T> other);

  @override
  @unsafeOrError
  T unwrap();

  @override
  T unwrapOr(T fallback);

  @override
  Option<R> map<R extends Object>(@noFutures R Function(T value) noFutures);

  @override
  Result<Option<R>> transf<R extends Object>([
    @noFutures R Function(T e)? noFutures,
  ]);

  @override
  @nonVirtual
  @pragma('vm:prefer-inline')
  void end() {}
}
