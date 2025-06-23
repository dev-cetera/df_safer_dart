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

import '/src/_src.g.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

extension $SyncAsyncSwapX<T extends Object> on Sync<Async<T>> {
  @pragma('vm:prefer-inline')
  Async<Sync<T>> swap() {
    switch (value) {
      case Ok(value: final asyncValue):
        return Async(() async {
          final innerResult = await asyncValue.value;
          return Sync.unsafe(innerResult);
        });
      case final Err<Async<T>> err:
        final failedSync = Sync.unsafe(err.transfErr<T>());
        return Async.unsafe(Future.value(Ok(failedSync)));
    }
  }
}

extension $SyncResolvableSwapX<T extends Object> on Sync<Resolvable<T>> {
  @pragma('vm:prefer-inline')
  Resolvable<Sync<T>> swap() {
    switch (value) {
      case Ok(value: final resolvableValue):
        switch (resolvableValue) {
          case Sync(value: final syncValue):
            return Sync.unsafe(Ok(Sync.unsafe(syncValue)));
          case Async(value: final asyncValue):
            return Async<Sync<T>>(() async {
              final result = await asyncValue;
              return Sync.unsafe(result);
            });
        }
      case final Err<Resolvable<T>> err:
        final failedSync = Sync.unsafe(err.transfErr<T>());
        return Sync.unsafe(Ok(failedSync));
    }
  }
}

extension $SyncOptionSwapX<T extends Object> on Sync<Option<T>> {
  @pragma('vm:prefer-inline')
  Option<Sync<T>> swap() {
    switch (value) {
      case Ok(value: final optionValue):
        switch (optionValue) {
          case Some(value: final someValue):
            return Sync.unsafe(Ok(someValue)).wrapSome();
          case None():
            return const None();
        }
      case final Err<Option<T>> err:
        return Sync.unsafe(err.transfErr<T>()).wrapSome();
    }
  }
}

extension $SyncSomeSwapX<T extends Object> on Sync<Some<T>> {
  @pragma('vm:prefer-inline')
  Some<Sync<T>> swap() => map((e) => e.unwrap()).wrapSome();
}

extension $SyncNoneSwapX<T extends Object> on Sync<None<T>> {
  @pragma('vm:prefer-inline')
  None<Sync<T>> swap() => const None();
}

extension $SyncResultSwapX<T extends Object> on Sync<Result<T>> {
  @pragma('vm:prefer-inline')
  Result<Sync<T>> swap() {
    switch (value) {
      case Ok(value: final resultValue):
        switch (resultValue) {
          case Ok(value: final okValue):
            return Sync.unsafe(Ok(okValue)).wrapOk();
          case final Err<T> err:
            return err.transfErr<Sync<T>>();
        }
      case final Err<Result<T>> err:
        return err.transfErr<Sync<T>>();
    }
  }
}

extension $SyncOkSwapX<T extends Object> on Sync<Ok<T>> {
  @pragma('vm:prefer-inline')
  Ok<Sync<T>> swap() => Ok(Sync.unsafe(Ok(value.unwrap().unwrap())));
}

extension $SyncErrSwapX<T extends Object> on Sync<Err<T>> {
  @pragma('vm:prefer-inline')
  Err<Sync<T>> swap() => value.unwrap().transfErr<Sync<T>>();
}
