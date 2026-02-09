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

extension FlattenAsyncExt2<T extends Object> on Async<Async<T>> {
  @pragma('vm:prefer-inline')
  Async<T> flatten() => flatten2();

  @protected
  Async<T> flatten2() {
    return Async(() async {
      final outerResult = await value;
      switch (outerResult) {
        case Ok(value: final innerAsync):
          return await innerAsync.unwrap();
        case final Err<Async<T>> err:
          throw err;
      }
    });
  }
}

extension FlattenAsyncExt3<T extends Object> on Async<Async<Async<T>>> {
  @pragma('vm:prefer-inline')
  Async<T> flatten() => flatten3();

  @protected
  @pragma('vm:prefer-inline')
  Async<T> flatten3() => flatten2().flatten2();
}

extension FlattenAsyncExt4<T extends Object> on Async<Async<Async<Async<T>>>> {
  @pragma('vm:prefer-inline')
  Async<T> flatten() => flatten4();

  @protected
  @pragma('vm:prefer-inline')
  Async<T> flatten4() => flatten3().flatten2();
}

extension FlattenAsyncExt5<T extends Object>
    on Async<Async<Async<Async<Async<T>>>>> {
  @pragma('vm:prefer-inline')
  Async<T> flatten() => flatten5();

  @protected
  @pragma('vm:prefer-inline')
  Async<T> flatten5() => flatten4().flatten2();
}

extension FlattenAsyncExt6<T extends Object>
    on Async<Async<Async<Async<Async<Async<T>>>>>> {
  @pragma('vm:prefer-inline')
  Async<T> flatten() => flatten6();

  @protected
  @pragma('vm:prefer-inline')
  Async<T> flatten6() => flatten5().flatten2();
}

extension FlattenAsyncExt7<T extends Object>
    on Async<Async<Async<Async<Async<Async<Async<T>>>>>>> {
  @pragma('vm:prefer-inline')
  Async<T> flatten() => flatten7();

  @protected
  @pragma('vm:prefer-inline')
  Async<T> flatten7() => flatten6().flatten2();
}

extension FlattenAsyncExt8<T extends Object>
    on Async<Async<Async<Async<Async<Async<Async<Async<T>>>>>>>> {
  @pragma('vm:prefer-inline')
  Async<T> flatten() => flatten8();

  @protected
  @pragma('vm:prefer-inline')
  Async<T> flatten8() => flatten7().flatten2();
}

extension FlattenAsyncExt9<T extends Object>
    on Async<Async<Async<Async<Async<Async<Async<Async<Async<T>>>>>>>>> {
  @pragma('vm:prefer-inline')
  Async<T> flatten() => flatten9();

  @protected
  @pragma('vm:prefer-inline')
  Async<T> flatten9() => flatten8().flatten2();
}
