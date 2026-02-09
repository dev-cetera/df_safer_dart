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

extension FlattenResolvableExt2<T extends Object> on Resolvable<Resolvable<T>> {
  @pragma('vm:prefer-inline')
  Resolvable<T> flatten() => flatten2();

  @protected
  Resolvable<T> flatten2() {
    switch (this) {
      case Sync(value: final outerResult):
        switch (outerResult) {
          case Ok(value: final innerResolvable):
            return innerResolvable;

          case final Err<Resolvable<T>> err:
            return Sync.err(err.transfErr());
        }
      case Async(value: final outerFutureResult):
        return Async(() async {
          final outerResult = await outerFutureResult;
          switch (outerResult) {
            case Ok(value: final innerResolvable):
              return await innerResolvable.unwrap();
            case final Err<Resolvable<T>> err:
              throw err;
          }
        });
    }
  }
}

extension FlattenResolvableExt3<T extends Object>
    on Resolvable<Resolvable<Resolvable<T>>> {
  @pragma('vm:prefer-inline')
  Resolvable<T> flatten() => flatten3();

  @protected
  @pragma('vm:prefer-inline')
  Resolvable<T> flatten3() => flatten2().flatten2();
}

extension FlattenResolvableExt4<T extends Object>
    on Resolvable<Resolvable<Resolvable<Resolvable<T>>>> {
  @pragma('vm:prefer-inline')
  Resolvable<T> flatten() => flatten4();

  @protected
  @pragma('vm:prefer-inline')
  Resolvable<T> flatten4() => flatten3().flatten2();
}

extension FlattenResolvableExt5<T extends Object>
    on Resolvable<Resolvable<Resolvable<Resolvable<Resolvable<T>>>>> {
  @pragma('vm:prefer-inline')
  Resolvable<T> flatten() => flatten5();

  @protected
  @pragma('vm:prefer-inline')
  Resolvable<T> flatten5() => flatten4().flatten2();
}

extension FlattenResolvableExt6<T extends Object>
    on
        Resolvable<
          Resolvable<Resolvable<Resolvable<Resolvable<Resolvable<T>>>>>
        > {
  @pragma('vm:prefer-inline')
  Resolvable<T> flatten() => flatten6();

  @protected
  @pragma('vm:prefer-inline')
  Resolvable<T> flatten6() => flatten5().flatten2();
}

extension FlattenResolvableExt7<T extends Object>
    on
        Resolvable<
          Resolvable<
            Resolvable<Resolvable<Resolvable<Resolvable<Resolvable<T>>>>>
          >
        > {
  @pragma('vm:prefer-inline')
  Resolvable<T> flatten() => flatten7();

  @protected
  @pragma('vm:prefer-inline')
  Resolvable<T> flatten7() => flatten6().flatten2();
}

extension FlattenResolvableExt8<T extends Object>
    on
        Resolvable<
          Resolvable<
            Resolvable<
              Resolvable<Resolvable<Resolvable<Resolvable<Resolvable<T>>>>>
            >
          >
        > {
  @pragma('vm:prefer-inline')
  Resolvable<T> flatten() => flatten8();

  @protected
  @pragma('vm:prefer-inline')
  Resolvable<T> flatten8() => flatten7().flatten2();
}

extension FlattenResolvableExt9<T extends Object>
    on
        Resolvable<
          Resolvable<
            Resolvable<
              Resolvable<
                Resolvable<Resolvable<Resolvable<Resolvable<Resolvable<T>>>>>
              >
            >
          >
        > {
  @pragma('vm:prefer-inline')
  Resolvable<T> flatten() => flatten9();

  @protected
  @pragma('vm:prefer-inline')
  Resolvable<T> flatten9() => flatten8().flatten2();
}
