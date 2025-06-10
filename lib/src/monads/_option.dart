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

/// A [Monad] that represents either [Some] value or [None], the absense of a
/// value.
sealed class Option<T extends Object> extends Monad<T> {
  const Option._();

  /// Creates an [Option] from a nullable value.
  factory Option.fromNullable(T? value) {
    if (value != null) {
      return Some(value);
    } else {
      return const None();
    }
  }

  /// Returns this as an [Option].
  @pragma('vm:prefer-inline')
  Option<T> asOption() => this;

  /// Returns this [Option] as an [Ok].
  Ok<Option<T>> asOk();

  /// Converts this [Option] to an [Async] monad.
  @pragma('vm:prefer-inline')
  Async<Option<T>> asAsync() => Async.value(Future.value(Ok(this)));

  /// Converts this [Option] to a [Sync] monad.
  @pragma('vm:prefer-inline')
  Sync<Option<T>> asSync() => Sync.value(Ok(this));

  /// Returns `true` if this is a [Some].
  bool isSome();

  /// Returns `true` if this is a [None].
  bool isNone();

  /// Returns a [Result] containing this instance if it's a [Some].
  Result<Some<T>> some();

  /// Returns a [Result] containing this instance if it's a [None].
  Result<None<T>> none();

  /// Performs a side-effect if this is a [Some].
  Result<Option<T>> ifSome(void Function(Some<T> some) unsafe);

  /// Performs a side-effect if this is a [None].
  Result<Option<T>> ifNone(void Function() unsafe);

  /// Returns the contained value. Throws if this is a [None].
  @override
  T unwrap({int delta = 1});

  /// Returns the contained value or a provided fallback.
  @override
  T unwrapOr(T fallback);

  /// Returns the contained value or computes it from a function.
  @override
  @pragma('vm:prefer-inline')
  FutureOr<T> unwrapOrElse(T Function() unsafe) => unwrapOr(unsafe());

  /// Returns the contained value or `null`.
  T? orNull();

  /// Maps an `Option<T>` to `Option<R>` by applying the [mapper] function.
  @override
  Option<R> map<R extends Object>(R Function(T value) mapper);

  /// Maps an `Option<T>` to `Option<R>` by applying the [mapper] function.
  Option<R> flatMap<R extends Object>(Option<R> Function(T value) mapper) {
    if (isSome()) {
      return mapper(unwrap());
    } else {
      return const None();
    }
  }

  /// Returns [None] if the [Option] is [None], or if the predicate returns `false`.
  Option<T> filter(bool Function(T value) test);

  /// Chains [Option] instances by handling [Some] and [None] cases.
  Result<Option<Object>> fold(
    Option<Object>? Function(Some<T> some) onSome,
    Option<Object>? Function(None<T> none) onNone,
  );

  /// Exhaustively handles [Some] and [None] cases, returning a new value.
  R match<R extends Object>(R Function(T value) onSome, R Function() onNone);

  /// Returns this if it's [Some], otherwise returns [other].
  Option<Object> someOr<R extends Object>(Option<R> other);

  /// Returns this if it's [None], otherwise returns [other].
  Option<Object> noneOr<R extends Object>(Option<R> other);

  /// Transforms the [Some] value's type.
  @override
  Result<Option<R>> transf<R extends Object>([R Function(T e)? transformer]);

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
  Sync<Option<T>> wrapSync() => Sync.value(Ok(this));

  @override
  @pragma('vm:prefer-inline')
  Async<Option<T>> wrapAsync() => Async.value(Future.value(Ok(this)));
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// A [Monad] that represents an [Option] that contains a [value].
final class Some<T extends Object> extends Option<T> {
  final T value;

  const Some(this.value) : super._();

  @override
  @pragma('vm:prefer-inline')
  Ok<Some<T>> asOk() => Ok(this);

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
  Result<Some<T>> ifSome(void Function(Some<T> some) unsafe) {
    try {
      unsafe(this);
      return Ok(this);
    } catch (error) {
      return Err(error);
    }
  }

  @override
  @pragma('vm:prefer-inline')
  Ok<Some<T>> ifNone(void Function() unsafe) => Ok(this);

  @override
  @pragma('vm:prefer-inline')
  T unwrap({int delta = 1}) => value;

  @override
  @pragma('vm:prefer-inline')
  T unwrapOr(T fallback) => value;

  @override
  @pragma('vm:prefer-inline')
  T? orNull() => value;

  @override
  @pragma('vm:prefer-inline')
  Some<R> map<R extends Object>(R Function(T value) mapper) =>
      Some(mapper(value));

  @override
  @pragma('vm:prefer-inline')
  Option<T> filter(bool Function(T value) test) =>
      test(value) ? this : const None();

  @override
  @pragma('vm:prefer-inline')
  Result<Option<Object>> fold(
    Option<Object>? Function(Some<T> some) onSome,
    Option<Object>? Function(None<T> none) onNone,
  ) {
    try {
      return Ok(onSome(this) ?? this);
    } catch (error) {
      return Err(error);
    }
  }

  @override
  @pragma('vm:prefer-inline')
  R match<R extends Object>(R Function(T value) onSome, R Function() onNone) {
    return onSome(this.value);
  }

  @override
  @pragma('vm:prefer-inline')
  Some<T> someOr<R extends Object>(Option<R> other) => this;

  @override
  @pragma('vm:prefer-inline')
  Option<R> noneOr<R extends Object>(Option<R> other) => other;

  @override
  Result<Option<R>> transf<R extends Object>([R Function(T e)? transformer]) {
    try {
      final value0 = unwrap();
      final value1 = transformer?.call(value0) ?? value0 as R;
      return Ok(Option.fromNullable(value1));
    } catch (_) {
      return Err('Cannot transform $T to $R');
    }
  }

  @pragma('vm:prefer-inline')
  None<T> asNone() => const None();

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
  Sync<Some<T>> wrapSync() => Sync.value(Ok(this));

  @override
  @pragma('vm:prefer-inline')
  Async<Some<T>> wrapAsync() => Async.value(Future.value(Ok(this)));

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
  Ok<None<T>> asOk() => Ok(this);

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
  Ok<None<T>> ifSome(void Function(Some<T> some) unsafe) => Ok(this);

  @override
  @pragma('vm:prefer-inline')
  Result<None<T>> ifNone(void Function() unsafe) {
    try {
      unsafe();
      return Ok(this);
    } catch (error) {
      return Err(error);
    }
  }

  @override
  @pragma('vm:prefer-inline')
  T unwrap({int delta = 1}) {
    throw Err<T>('Called unwrap() on None<$T>.').addStackLevel(delta);
  }

  @override
  @pragma('vm:prefer-inline')
  T unwrapOr(T fallback) => fallback;

  @override
  @pragma('vm:prefer-inline')
  T? orNull() => null;

  @override
  @pragma('vm:prefer-inline')
  None<R> map<R extends Object>(R Function(T value) mapper) => None<R>();

  @override
  @pragma('vm:prefer-inline')
  None<T> filter(bool Function(T value) test) => const None();

  @override
  @pragma('vm:prefer-inline')
  Result<Option<Object>> fold(
    Option<Object>? Function(Some<T> some) onSome,
    Option<Object>? Function(None<T> none) onNone,
  ) {
    try {
      return Ok(onNone(this) ?? this);
    } catch (error) {
      return Err(error);
    }
  }

  @override
  @pragma('vm:prefer-inline')
  R match<R extends Object>(R Function(T value) onSome, R Function() onNone) {
    return onNone();
  }

  @override
  @pragma('vm:prefer-inline')
  Option<Object> someOr<R extends Object>(Option<R> other) => other;

  @override
  @pragma('vm:prefer-inline')
  None<T> noneOr<R extends Object>(Option<R> other) => this;

  @override
  @pragma('vm:prefer-inline')
  Ok<None<R>> transf<R extends Object>([R Function(T e)? transformer]) {
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
  Sync<None<T>> wrapSync() => Sync.value(Ok(this));

  @override
  @pragma('vm:prefer-inline')
  Async<None<T>> wrapAsync() => Async.value(Future.value(Ok(this)));

  @override
  @pragma('vm:prefer-inline')
  List<Object?> get props => [];

  @override
  @pragma('vm:prefer-inline')
  bool? get stringify => false;
}
