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

import '/_common.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// A class that provides lazy initialization for instances of type [T].
///
/// ### Isolate sendability
///
/// A [Lazy] is sendable through `SendPort` iff:
///
/// 1. The [_constructor] is a top-level function or a static method (enforced
///    by the `@sendable` lint at construction sites).
/// 2. The cached [currentInstance], if present, holds a [Sync] outcome —
///    [Async] outcomes wrap an isolate-local `Future` and are not sendable.
///    A freshly-constructed [Lazy] whose [singleton] has not yet been read
///    holds `None` and is unconditionally sendable.
class Lazy<T extends Object> {
  /// Holds the current singleton instance of type [T] or `null` if no
  /// [singleton] instance was created.
  @protected
  Option<Resolvable<T>> currentInstance = const None();

  /// A constructor function that creates instances of type [T].
  final LazyConstructor<T> _constructor;

  Lazy(@sendable this._constructor);

  /// Returns the singleton instance [currentInstance], or creating it if necessary.
  @pragma('vm:prefer-inline')
  Resolvable<T> get singleton {
    // Cached fast path: skip the `Option.unwrap()` round-trip the previous
    // form did. We pattern-match on `Some` directly and return its value.
    final cached = currentInstance;
    if (cached is Some<Resolvable<T>>) return cached.value;
    final fresh = _constructor();
    currentInstance = Some(fresh);
    return fresh;
  }

  /// Returns a new instance of [T] each time, acting as a factory.
  @pragma('vm:prefer-inline')
  Resolvable<T> get factory => _constructor();

  /// Resets the singleton instance, by setting [currentInstance] back to `null`
  /// allowing it to be re-created via [singleton].
  @pragma('vm:prefer-inline')
  void resetSingleton() => currentInstance = const None();
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

typedef LazyConstructor<T extends Object> = Resolvable<T> Function();
