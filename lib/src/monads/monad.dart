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

// ignore_for_file: must_use_unsafe_wrapper_or_error

import 'dart:async' show FutureOr;
import 'dart:convert' show JsonEncoder;
import 'package:equatable/equatable.dart' show Equatable;
import 'package:meta/meta.dart';
import 'package:stack_trace/stack_trace.dart';

import 'package:df_safer_dart_annotations/df_safer_dart_annotations.dart';

import '../_src.g.dart';

part '_option.dart';
part '_result.dart';
part '_resolvable.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// The foundational sealed class for all monadic types like [Option], [Result],
/// and [Resolvable].
sealed class Monad<T extends Object> implements Equatable {
  final Object value;

  const Monad(this.value);

  /// Reduces the monad to a [Resolvable] of an [Option] of type [R].
  Resolvable<Option<R>> reduce<R extends Object>() {
    switch (this) {
      case Sync<T> sync:
        final value = sync.value;
        return value.reduce();
      case Async<T> async:
        return _resolveAsync<R>(async);
      case Some<T> some:
        return _resolveValue(some.value);
      case None<T> _:
        return const Sync.unsafe(Ok(None()));
      case Ok<T> ok:
        return _resolveValue(ok.value);
      case Err<T> err:
        return Sync(() => throw err);
    }
  }

  @pragma('vm:prefer-inline')
  Resolvable<Option<R>> _resolveAsync<R extends Object>(Async<T> async) {
    return Async(() async {
      final test = await async.value.then((e) {
        final test = e.reduce();
        return test.value;
      });
      if (test.isErr()) {
        throw test;
      }
      try {
        return test.unwrap().transf<R>().unwrap();
      } catch (e) {
        assert(false, e);
        throw Err<T>('Cannot resolve $T to $R.');
      }
    });
  }

  @pragma('vm:prefer-inline')
  Resolvable<Option<R>> _resolveValue<R extends Object>(T value) {
    if (value is Monad) {
      return value.reduce();
    } else {
      return Resolvable(() {
        try {
          return Some(value as R);
        } catch (e) {
          assert(false, e);
          throw Err<T>('Cannot resolve $T to $R.');
        }
      });
    }
  }

  /// Unsafely returns the contained value. Throws [Err] the `Monad` is an
  /// [Err] or [None].
  @unsafeOrError
  FutureOr<T> unwrap();

  /// Returns the contained value, or the `fallback` if the [Monad] is in an
  /// [Err] or [None] state.
  FutureOr<T> unwrapOr(T fallback);

  /// Transforms the contained value using the mapper function
  /// [noFuturesAllowed] while preserving the [Monad]'s structure.
  Monad<R> map<R extends Object>(
    @noFuturesAllowed R Function(T value) noFuturesAllowed,
  );

  /// Transforms the [Monad]'s generic type from `T` to `R`.
  ///
  /// Uses the transformer function [noFuturesAllowed] if provided, otherwise
  /// attempts a direct cast.
  Monad transf<R extends Object>([
    @noFuturesAllowed R Function(T e)? noFuturesAllowed,
  ]);

  /// Wraps this [Monad] in a [Some].
  Some<Monad<T>> wrapSome();

  /// Wraps this [Monad] in an [Ok].
  Ok<Monad<T>> wrapOk();

  /// Wraps this [Monad] in a [Resolvable].
  Resolvable<Monad<T>> wrapResolvable();

  /// Wraps this [Monad] in a [Sync].
  Sync<Monad<T>> wrapSync();

  /// Wraps this [Monad] in an [Async].
  Async<Monad<T>> wrapAsync();

  /// Transforms the contained value to `void`.
  Monad<void> asVoid();

  /// Suppresses the linter error `must_use_monad`.
  FutureOr<void> end();

  @override
  @pragma('vm:prefer-inline')
  List<Object?> get props => [value];

  @override
  @pragma('vm:prefer-inline')
  bool? get stringify => false;
}
