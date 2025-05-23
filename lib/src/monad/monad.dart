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

import 'dart:async' show FutureOr;
import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../df_safer_dart.dart';

part '_option.dart';
part '_result.dart';
part '_resolvable.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

sealed class Monad<T extends Object> implements Equatable {
  const Monad();

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
        return const Sync.value(Ok(None()));
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
        return test.unwrap().map((e) => e as R);
      } catch (_) {
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
        } catch (_) {
          throw Err<T>('Cannot resolve $T to $R.');
        }
      });
    }
  }
}
