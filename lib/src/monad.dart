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

import 'dart:async' show FutureOr;

part '_option.dart';
part '_result.dart';
part '_resolvable.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

sealed class Monad<T extends Object> {
  const Monad();

  ResolvableOption<R> reduce<R extends Object>() {
    switch (this) {
      case Sync<T> sync:
        final value = sync.value;
        return value.reduce();
      case Async<T> async:
        return _resolveAsync<R>(async);
      case Some<T> some:
        return _resolveValue(some.value);
      case None<T> _:
        return const Sync(Ok(None()));
      case Ok<T> ok:
        return _resolveValue(ok.value);
      case Err<T> err:
        return Sync.unsafe(() => throw err);
    }
  }

  @pragma('vm:prefer-inline')
  ResolvableOption<R> _resolveAsync<R extends Object>(Async<T> async) {
    return Async.unsafe(() async {
      final test = await async.value.then((e) {
        final test = e.reduce();
        return test.value;
      });
      if (test.isErr()) {
        throw test;
      }
      try {
        return test.unwrap().map((e) => e as R);
      } catch (e) {
        throw _castError<R>();
      }
    });
  }

  @pragma('vm:prefer-inline')
  ResolvableOption<R> _resolveValue<R extends Object>(T value) {
    if (value is Monad) {
      return value.reduce();
    } else {
      return Resolvable.unsafe(() {
        try {
          return Some(value as R);
        } catch (e) {
          throw _castError<R>();
        }
      });
    }
  }

  @pragma('vm:prefer-inline')
  Err _castError<R extends Object>() {
    return Err(
      stack: [Monad, 'reduce'],
      error: 'Failed to cast $T to $R.',
    );
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

extension UnwrapOnResolvableOptionX<T extends Object> on ResolvableOption<T> {
  @pragma('vm:prefer-inline')
  FutureOr<T> unwrap() {
    if (isSync()) {
      return unwrapSync();
    } else {
      return unwrapAsync();
    }
  }

  @pragma('vm:prefer-inline')
  T unwrapSync() => sync().unwrap().value.unwrap().unwrap();

  @pragma('vm:prefer-inline')
  Future<T> unwrapAsync() => async().unwrap().value.then((e) => e.unwrap().unwrap());
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

typedef ResolvableOption<T extends Object> = Resolvable<Option<T>>;

typedef SyncSome<T extends Object> = Sync<Some<T>>;
//typedef SyncNone<T extends Object> = Sync<None<T>>;
