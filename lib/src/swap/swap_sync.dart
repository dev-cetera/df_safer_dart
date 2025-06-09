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

import '/src/_src.g.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

extension SyncAsyncSwapX<T extends Object> on Sync<Async<T>> {
  @pragma('vm:prefer-inline')
  Async<Sync<T>> swap() {
    return value.match(
      (value) => Async(() async {
        final innerResult = await value.value;
        return Sync.value(innerResult);
      }),
      (err) {
        final failedSync = Sync.value(err.transfErr<T>());
        return Async.value(Future.value(Ok(failedSync)));
      },
    );
  }
}

extension SyncResolvableSwapX<T extends Object> on Sync<Resolvable<T>> {
  @pragma('vm:prefer-inline')
  Resolvable<Sync<T>> swap() {
    return value.match(
      (value) {
        if (value.isSync()) {
          final sync = value.unwrapSync();
          return Sync.value(Ok(Sync.value(sync.value)));
        } else {
          final async = value.unwrapAsync();
          return Async<Sync<T>>(() async {
            final result = await async.value;
            return Sync.value(result);
          });
        }
      },
      (err) {
        final failedSync = Sync.value(err.transfErr<T>());
        return Sync.value(Ok(failedSync));
      },
    );
  }
}

extension SyncOptionSwapX<T extends Object> on Sync<Option<T>> {
  @pragma('vm:prefer-inline')
  Option<Sync<T>> swap() {
    return value.match(
      (value) => value.match(
        (value) => Sync.value(Ok(value)).asSome(),
        () => const None(),
      ),
      (err) => Sync.value(err.transfErr<T>()).asSome(),
    );
  }
}

extension SyncSomeSwapX<T extends Object> on Sync<Some<T>> {
  @pragma('vm:prefer-inline')
  Some<Sync<T>> swap() => map((e) => e.unwrap()).asSome();
}

extension SyncNoneSwapX<T extends Object> on Sync<None<T>> {
  @pragma('vm:prefer-inline')
  None<Sync<T>> swap() => const None();
}

extension SyncResultSwapX<T extends Object> on Sync<Result<T>> {
  @pragma('vm:prefer-inline')
  Result<Sync<T>> swap() {
    return value.match(
      (value) => value.match(
        (value) => Sync.value(Ok(value)).asOk(),
        (err) => err.transfErr<Sync<T>>(),
      ),
      (err) => err.transfErr<Sync<T>>(),
    );
  }
}

extension SyncOkSwapX<T extends Object> on Sync<Ok<T>> {
  @pragma('vm:prefer-inline')
  Ok<Sync<T>> swap() => Ok(Sync.value(Ok(value.unwrap().unwrap())));
}

extension SyncErrSwapX<T extends Object> on Sync<Err<T>> {
  @pragma('vm:prefer-inline')
  Err<Sync<T>> swap() => value.unwrap().transfErr<Sync<T>>();
}
