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

import 'package:meta/meta.dart';

import 'monad.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// A class that provides lazy initialization for instances of type [T].
class Lazy<T extends Object> {
  /// Holds the current singleton instance of type [T] or `null` if no
  /// [singleton] instance was created.
  @protected
  Option<Resolvable<T>> currentInstance = const None();

  /// A constructor function that creates instances of type [T].
  final TConstructor<T> _constructor;

  Lazy(this._constructor);

  /// Returns the singleton instance [currentInstance], or creating it if necessary.
  @pragma('vm:prefer-inline')
  Resolvable<T> get singleton {
    return (currentInstance.isNone() ? currentInstance = Some(_constructor()) : currentInstance)
        .unwrap();
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

typedef TConstructor<T extends Object> = Resolvable<T> Function();
