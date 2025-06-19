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

part of 'monad.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// A [Monad] that represents an optional value: every [Option] is either
/// [Some] and contains a value, or [None] and does not.
sealed class Option<T extends Object> extends Monad<T> {
  /// Combines 2 [Option] monads into 1 containing a tuple of their values if
  /// all are [Some].
  ///
  /// Returns [None] if any are [None].
  static Option<(T1, T2)> zip2<T1 extends Object, T2 extends Object>(
    Option<T1> o1,
    Option<T2> o2,
  ) {
    switch ((o1, o2)) {
      case (Some(value: final v1), Some(value: final v2)):
        return Some((v1, v2));
      default:
        return const None();
    }
  }

  /// Combines 3 [Option] monads into 1 containing a tuple of their values if
  /// all are [Some].
  ///
  /// Returns [None] if any are [None]
  static Option<(T1, T2, T3)> zip3<
    T1 extends Object,
    T2 extends Object,
    T3 extends Object
  >(Option<T1> o1, Option<T2> o2, Option<T3> o3) {
    switch ((o1, o2, o3)) {
      case (
        Some(value: final v1),
        Some(value: final v2),
        Some(value: final v3),
      ):
        return Some((v1, v2, v3));
      default:
        return const None();
    }
  }

  const Option._();

  /// Creates an [Option] from a nullable value.
  ///
  /// Returns [Some] if the [value] is not `null`, otherwise returns [None].
  factory Option.from(T? value) {
    // This is already safe and idiomatic, no switch needed here.
    if (value != null) {
      return Some(value);
    } else {
      return const None();
    }
  }

  @Deprecated('Use "Option.from(T? value)" instead.')
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
    @noFuturesAllowed void Function(Some<T> some) noFuturesAllowed,
  );

  /// Performs a side-effect if this is a [None].
  Result<Option<T>> ifNone(@noFuturesAllowed void Function() noFuturesAllowed);

  /// Returns the contained value or `null`.
  T? orNull();

  /// Transforms the inner [Some] instance if this is a [Some].
  Option<T> mapSome(
    @noFuturesAllowed Some<T> Function(Some<T> some) noFuturesAllowed,
  );

  /// Maps an `Option<T>` to `Option<R>` by applying a function that returns
  /// another [Option].
  Option<R> flatMap<R extends Object>(
    @noFuturesAllowed Option<R> Function(T value) noFuturesAllowed,
  );

  /// Returns [None] if the predicate [noFuturesAllowed] returns `false`.
  /// Otherwise, returns the original [Option].
  Option<T> filter(@noFuturesAllowed bool Function(T value) noFuturesAllowed);

  /// Folds the two cases of this [Option] into a single [Result].
  ///
  /// The `onSome` and `onNone` functions must return a new [Option].
  Result<Option<Object>> fold(
    @noFuturesAllowed Option<Object>? Function(Some<T> some) onSome,
    @noFuturesAllowed Option<Object>? Function(None<T> none) onNone,
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
  Option<R> map<R extends Object>(
    @noFuturesAllowed R Function(T value) noFuturesAllowed,
  );

  @override
  Result<Option<R>> transf<R extends Object>([
    @noFuturesAllowed R Function(T e)? noFuturesAllowed,
  ]);

  @override
  @pragma('vm:prefer-inline')
  Some<Option<T>> wrapSome() => Some(this);

  @override
  @pragma('vm:prefer-inline')
  Ok<Option<T>> wrapOk() => Ok(this);

  @override
  @pragma('vm:prefer-inline')
  Resolvable<Option<T>> wrapResolvable() => Resolvable(() => this);

  @override
  @pragma('vm:prefer-inline')
  Sync<Option<T>> wrapSync() => Sync.unsafe(Ok(this));

  @override
  @pragma('vm:prefer-inline')
  Async<Option<T>> wrapAsync() => Async.unsafe(Future.value(Ok(this)));

  @override
  @pragma('vm:prefer-inline')
  Option<void> asVoid() => this;
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// A [Monad] that represents an [Option] that contains a [value].
final class Some<T extends Object> extends Option<T> {
  /// The contained value.
  final T value;

  const Some(this.value) : super._();

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
      final value0 = UNSAFE(() => unwrap());
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

  @pragma('vm:prefer-inline')
  @override
  List<Object?> get props => [this.value];

  @pragma('vm:prefer-inline')
  @override
  bool? get stringify => false;
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// A [Monad] that represents an [Option] that does not contain a value.
final class None<T extends Object> extends Option<T> {
  const None() : super._();

  @override
  @pragma('vm:prefer-inline')
  bool isSome() => false;

  @override
  @pragma('vm:prefer-inline')
  bool isNone() => true;

  @override
  @pragma('vm:prefer-inline')
  Err<Some<T>> some() {
    return Err('Called some() on None<$T>.');
  }

  @override
  @pragma('vm:prefer-inline')
  Ok<None<T>> none() => Ok(this);

  @override
  @pragma('vm:prefer-inline')
  Ok<None<T>> ifSome(
    @noFuturesAllowed void Function(Some<T> some) noFuturesAllowed,
  ) {
    return Ok(this);
  }

  @override
  @pragma('vm:prefer-inline')
  Result<None<T>> ifNone(@noFuturesAllowed void Function() noFuturesAllowed) {
    try {
      noFuturesAllowed();
      return Ok(this);
    } catch (error) {
      return Err(error);
    }
  }

  @override
  @pragma('vm:prefer-inline')
  T? orNull() => null;

  @override
  @pragma('vm:prefer-inline')
  None<T> mapSome(
    @noFuturesAllowed Some<T> Function(Some<T> some) noFuturesAllowed,
  ) {
    return this;
  }

  @override
  @pragma('vm:prefer-inline')
  None<R> flatMap<R extends Object>(
    @noFuturesAllowed Option<R> Function(T value) noFuturesAllowed,
  ) {
    return const None();
  }

  @override
  @pragma('vm:prefer-inline')
  None<T> filter(@noFuturesAllowed bool Function(T value) noFuturesAllowed) {
    return const None();
  }

  @override
  @pragma('vm:prefer-inline')
  Result<Option<Object>> fold(
    @noFuturesAllowed Option<Object>? Function(Some<T> some) onSome,
    @noFuturesAllowed Option<Object>? Function(None<T> none) onNone,
  ) {
    try {
      return Ok(onNone(this) ?? this);
    } catch (error) {
      return Err(error);
    }
  }

  @override
  @pragma('vm:prefer-inline')
  Option<T> someOr(Option<T> other) => other;

  @override
  @pragma('vm:prefer-inline')
  None<T> noneOr(Option<T> other) => this;

  @override
  @protected
  @unsafeOrError
  @pragma('vm:prefer-inline')
  T unwrap() {
    throw Err<T>('Called unwrap() on None<$T>.');
  }

  @override
  @pragma('vm:prefer-inline')
  T unwrapOr(T fallback) => fallback;

  @override
  @pragma('vm:prefer-inline')
  None<R> map<R extends Object>(
    @noFuturesAllowed R Function(T value) noFuturesAllowed,
  ) {
    return None<R>();
  }

  @override
  @pragma('vm:prefer-inline')
  Ok<None<R>> transf<R extends Object>([
    @noFuturesAllowed R Function(T e)? noFuturesAllowed,
  ]) {
    return const Ok(None());
  }

  @override
  @pragma('vm:prefer-inline')
  Some<None<T>> wrapSome() => Some(this);

  @override
  @pragma('vm:prefer-inline')
  Ok<None<T>> wrapOk() => Ok(this);

  @override
  @pragma('vm:prefer-inline')
  Resolvable<None<T>> wrapResolvable() => Resolvable(() => this);

  @override
  @pragma('vm:prefer-inline')
  Sync<None<T>> wrapSync() => Sync.unsafe(Ok(this));

  @override
  @pragma('vm:prefer-inline')
  Async<None<T>> wrapAsync() => Async.unsafe(Future.value(Ok(this)));

  @override
  @pragma('vm:prefer-inline')
  None<void> asVoid() => this;

  @override
  @pragma('vm:prefer-inline')
  List<Object?> get props => [];

  @override
  @pragma('vm:prefer-inline')
  bool? get stringify => false;
}
