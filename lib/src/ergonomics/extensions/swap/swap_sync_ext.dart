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

// ignore_for_file: must_use_unsafe_wrapper_or_error

import '/_common.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

extension SwapSyncAsyncExt<T extends Object> on Sync<Async<T>> {
  @pragma('vm:prefer-inline')
  Async<Sync<T>> swap() {
    switch (value) {
      case Ok(value: final asyncValue):
        return Async(() async {
          final innerResult = await asyncValue.value;
          return Sync.result(innerResult);
        });
      case final Err<Async<T>> err:
        final failedSync = Sync.err(err.transfErr<T>());
        return Async.okValue(failedSync);
    }
  }
}

extension SwapSyncResolvableExt<T extends Object> on Sync<Resolvable<T>> {
  @pragma('vm:prefer-inline')
  Resolvable<Sync<T>> swap() {
    switch (value) {
      case Ok(value: final resolvableValue):
        switch (resolvableValue) {
          case Sync(value: final syncValue):
            return Sync.okValue(Sync.result(syncValue));
          case Async(value: final asyncValue):
            return Async<Sync<T>>(() async {
              final result = await asyncValue;
              return Sync.result(result);
            });
        }
      case final Err<Resolvable<T>> err:
        final failedSync = Sync.err(err.transfErr<T>());
        return Sync.okValue(failedSync);
    }
  }
}

extension SwapSyncOptionExt<T extends Object> on Sync<Option<T>> {
  @pragma('vm:prefer-inline')
  Option<Sync<T>> swap() {
    switch (value) {
      case Ok(value: final optionValue):
        switch (optionValue) {
          case Some(value: final someValue):
            return Sync.okValue(someValue).wrapInSome();
          case None():
            return const None();
        }
      case final Err<Option<T>> err:
        return Sync.err(err.transfErr<T>()).wrapInSome();
    }
  }
}

extension SwapSyncSomeExt<T extends Object> on Sync<Some<T>> {
  @pragma('vm:prefer-inline')
  Some<Sync<T>> swap() => map((e) => e.unwrap()).wrapInSome();
}

extension SwapSyncNoneExt<T extends Object> on Sync<None<T>> {
  @pragma('vm:prefer-inline')
  None<Sync<T>> swap() => const None();
}

extension SwapSyncResultExt<T extends Object> on Sync<Result<T>> {
  @pragma('vm:prefer-inline')
  Result<Sync<T>> swap() {
    switch (value) {
      case Ok(value: final resultValue):
        switch (resultValue) {
          case Ok(value: final okValue):
            return Sync.okValue(okValue).wrapInOk();
          case final Err<T> err:
            return err.transfErr<Sync<T>>();
        }
      case final Err<Result<T>> err:
        return err.transfErr<Sync<T>>();
    }
  }
}

extension SwapSyncOkExt<T extends Object> on Sync<Ok<T>> {
  @pragma('vm:prefer-inline')
  Ok<Sync<T>> swap() => Ok(Sync.okValue(value.unwrap().unwrap()));
}

extension SwapSyncErrExt<T extends Object> on Sync<Err<T>> {
  @pragma('vm:prefer-inline')
  Err<Sync<T>> swap() => value.unwrap().transfErr<Sync<T>>();
}
