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

import 'result.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

sealed class Option<T> {
  const Option();

  Result<T> get asResult => isSome ? Ok<T>(some.value) : Err(None<T>());

  B fold<B>(B Function(T value) onSome, B Function() onNone);
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

final class Some<T> extends Option<T> with _EqualityMixin<T> {
  final T value;
  const Some(this.value);

  @override
  @pragma('vm:prefer-inline')
  B fold<B>(B Function(T value) onSome, B Function() onNone) {
    return onSome(value);
  }

  @override
  @pragma('vm:prefer-inline')
  String toString() {
    return '${Some<T>}($value)';
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

final class None<T> extends Option<T> with _EqualityMixin<T> {
  const None();

  @override
  @pragma('vm:prefer-inline')
  B fold<B>(B Function(T value) onSome, B Function() onNone) {
    return onNone();
  }

  @override
  @pragma('vm:prefer-inline')
  String toString() {
    return '${None<T>}()';
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

mixin _EqualityMixin<T> on Option<T> {
  @override
  @pragma('vm:prefer-inline')
  bool operator ==(Object other) {
    return fold(
      (e) => other is Some && e == other.value,
      () => other is None && none == other.none,
    );
  }

  @override
  @pragma('vm:prefer-inline')
  int get hashCode {
    return fold(
      (e) => e.hashCode,
      () => null.hashCode,
    );
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

extension OptionExtension<T> on Option<T> {
  @pragma('vm:prefer-inline')
  bool get isSome {
    return this is Some<T>;
  }

  @pragma('vm:prefer-inline')
  bool get isNone {
    return this is None<T>;
  }

  @pragma('vm:prefer-inline')
  Some<T> get some {
    assert(isSome, 'This is not a Some: $this');
    return this as Some<T>;
  }

  @pragma('vm:prefer-inline')
  None<T> get none {
    assert(isNone, 'This is not a None: $this');
    return this as None<T>;
  }

  @pragma('vm:prefer-inline')
  T unwrap() {
    return some.value;
  }

  @pragma('vm:prefer-inline')
  T unwrapOr(T defaultValue) {
    return fold((value) => value, () => defaultValue);
  }

  @pragma('vm:prefer-inline')
  Option<R> map<R>(R Function(T value) fn) {
    if (isSome) {
      return Some(fn(some.value));
    }
    return const None();
  }
}
