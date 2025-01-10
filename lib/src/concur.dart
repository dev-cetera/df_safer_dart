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

import 'dart:async';

import '../df_safer_dart.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

extension ConcurExtension<T> on FutureOr<T> {
  @pragma('vm:prefer-inline')
  Concur<T> get concur => Concur(this);
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

sealed class Concur<T> {
  const Concur._();

  factory Concur(FutureOr<T> value) {
    if (value is Future<T>) {
      return Async(value);
    } else {
      return Sync(value);
    }
  }

  bool get isSync;

  bool get isAsync;

  Sync<T> get sync;

  Async<T> get async;

  Concur<T> ifSync(void Function(T value) fn);

  Concur<T> ifAsync(void Function(Future<T> future) fn);

  FutureOr<B> fold<B>(
      B Function(T value) onSync, Future<B> Function(Future<T> value) onAsync,);
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

final class Sync<T> extends Concur<T> {
  final T value;

  const Sync(this.value) : super._();

  @override
  @pragma('vm:prefer-inline')
  bool get isSync => true;

  @override
  @pragma('vm:prefer-inline')
  bool get isAsync => false;

  @override
  @pragma('vm:prefer-inline')
  Sync<T> get sync => this;

  @override
  @pragma('vm:prefer-inline')
  Async<T> get async => throw Panic('[Sync] Cannot get [async] from Sync.');

  @override
  @pragma('vm:prefer-inline')
  Concur<T> ifSync(void Function(T value) fn) {
    fn(value);
    return this;
  }

  @override
  @pragma('vm:prefer-inline')
  Concur<T> ifAsync(void Function(Future<T> future) fn) => this;

  @override
  FutureOr<B> fold<B>(
      B Function(T value) onSync, Future<B> Function(Future<T> value) onAsync,) {
    return onSync(value);
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

final class Async<T> extends Concur<T> {
  final Future<T> value;

  const Async(this.value) : super._();

  @override
  @pragma('vm:prefer-inline')
  bool get isSync => false;

  @override
  @pragma('vm:prefer-inline')
  bool get isAsync => true;

  @override
  @pragma('vm:prefer-inline')
  Sync<T> get sync => throw Panic('[Async] Cannot get [sync] from Async.');

  @override
  @pragma('vm:prefer-inline')
  Async<T> get async => this;

  @override
  @pragma('vm:prefer-inline')
  Concur<T> ifSync(void Function(T value) fn) => this;

  @override
  @pragma('vm:prefer-inline')
  Concur<T> ifAsync(void Function(Future<T> future) fn) {
    fn(value);
    return this;
  }

  @override
  FutureOr<B> fold<B>(
      B Function(T value) onSync, Future<B> Function(Future<T> value) onAsync,) {
    return onAsync(value);
  }
}
