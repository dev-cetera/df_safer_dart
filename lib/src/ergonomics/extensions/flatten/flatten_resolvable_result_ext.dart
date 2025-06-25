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
// ignore_for_file: no_future_monads

import '/_common.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

extension FlattenResolvableResultExt2<T extends Object> on Resolvable<Result<T>> {
  @pragma('vm:prefer-inline')
  Resolvable<T> flatten() => flatten2();

  @protected
  Resolvable<T> flatten2() {
    switch (value) {
      case Future<Result<Result<T>>> value:
        return Async(() async {
          return (await value).flatten2().unwrap();
        });
      default:
        return Sync(() {
          return (value as Result<Result<T>>).flatten2().unwrap();
        });
    }
  }
}

extension FlattenResolvableResulteExt3<T extends Object> on Resolvable<Result<Result<T>>> {
  @pragma('vm:prefer-inline')
  Resolvable<T> flatten() => flatten3();

  @protected
  @pragma('vm:prefer-inline')
  Resolvable<T> flatten3() => flatten2().flatten2();
}

extension FlattenResolvableResulteExt4<T extends Object> on Resolvable<Result<Result<Result<T>>>> {
  @pragma('vm:prefer-inline')
  Resolvable<T> flatten() => flatten4();

  @protected
  @pragma('vm:prefer-inline')
  Resolvable<T> flatten4() => flatten3().flatten2();
}

extension FlattenResolvableResulteExt5<T extends Object>
    on Resolvable<Result<Result<Result<Result<T>>>>> {
  @pragma('vm:prefer-inline')
  Resolvable<T> flatten() => flatten5();

  @protected
  @pragma('vm:prefer-inline')
  Resolvable<T> flatten5() => flatten4().flatten2();
}

extension FlattenResolvableResulteExt6<T extends Object>
    on Resolvable<Result<Result<Result<Result<Result<T>>>>>> {
  @pragma('vm:prefer-inline')
  Resolvable<T> flatten() => flatten6();

  @protected
  @pragma('vm:prefer-inline')
  Resolvable<T> flatten6() => flatten5().flatten2();
}

extension FlattenResolvableResulteExt7<T extends Object>
    on Resolvable<Result<Result<Result<Result<Result<Result<T>>>>>>> {
  @pragma('vm:prefer-inline')
  Resolvable<T> flatten() => flatten7();

  @protected
  @pragma('vm:prefer-inline')
  Resolvable<T> flatten7() => flatten6().flatten2();
}

extension FlattenResolvableResulteExt8<T extends Object>
    on Resolvable<Result<Result<Result<Result<Result<Result<Result<T>>>>>>>> {
  @pragma('vm:prefer-inline')
  Resolvable<T> flatten() => flatten8();

  @protected
  @pragma('vm:prefer-inline')
  Resolvable<T> flatten8() => flatten7().flatten2();
}

extension FlattenResolvableResulteExt9<T extends Object>
    on Resolvable<Result<Result<Result<Result<Result<Result<Result<Result<T>>>>>>>>> {
  @pragma('vm:prefer-inline')
  Resolvable<T> flatten() => flatten9();

  @protected
  @pragma('vm:prefer-inline')
  Resolvable<T> flatten9() => flatten8().flatten2();
}
