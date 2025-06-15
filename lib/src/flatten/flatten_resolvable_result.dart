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

// ignore_for_file: invalid_use_of_visible_for_testing_member

import '../monads/monad.dart';
import 'flatten_result.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

extension FlattenResolvableResult2<T extends Object> on Resolvable<Result<T>> {
  Resolvable<T> flatten2() {
    if (value is Result<Result<T>>) {
      return Sync(() {
        return (value as Result<Result<T>>).flatten2().unwrap();
      });
    } else {
      return Async(() async {
        return (await value).flatten2().unwrap();
      });
    }
  }
}

extension FlattenResolvableResulte3<T extends Object>
    on Resolvable<Result<Result<T>>> {
  @pragma('vm:prefer-inline')
  Resolvable<T> flatten() => flatten3();

  @pragma('vm:prefer-inline')
  Resolvable<T> flatten3() => flatten2().flatten2();
}

extension FlattenResolvableResulte4<T extends Object>
    on Resolvable<Result<Result<Result<T>>>> {
  @pragma('vm:prefer-inline')
  Resolvable<T> flatten() => flatten4();

  @pragma('vm:prefer-inline')
  Resolvable<T> flatten4() => flatten3().flatten2();
}

extension FlattenResolvableResulte5<T extends Object>
    on Resolvable<Result<Result<Result<Result<T>>>>> {
  @pragma('vm:prefer-inline')
  Resolvable<T> flatten() => flatten5();

  @pragma('vm:prefer-inline')
  Resolvable<T> flatten5() => flatten4().flatten2();
}

extension FlattenResolvableResulte6<T extends Object>
    on Resolvable<Result<Result<Result<Result<Result<T>>>>>> {
  @pragma('vm:prefer-inline')
  Resolvable<T> flatten() => flatten6();

  @pragma('vm:prefer-inline')
  Resolvable<T> flatten6() => flatten5().flatten2();
}

extension FlattenResolvableResulte7<T extends Object>
    on Resolvable<Result<Result<Result<Result<Result<Result<T>>>>>>> {
  @pragma('vm:prefer-inline')
  Resolvable<T> flatten() => flatten7();

  @pragma('vm:prefer-inline')
  Resolvable<T> flatten7() => flatten6().flatten2();
}

extension FlattenResolvableResulte8<T extends Object>
    on Resolvable<Result<Result<Result<Result<Result<Result<Result<T>>>>>>>> {
  @pragma('vm:prefer-inline')
  Resolvable<T> flatten() => flatten8();

  @pragma('vm:prefer-inline')
  Resolvable<T> flatten8() => flatten7().flatten2();
}

extension FlattenResolvableResulte9<T extends Object>
    on
        Resolvable<
          Result<Result<Result<Result<Result<Result<Result<Result<T>>>>>>>>
        > {
  @pragma('vm:prefer-inline')
  Resolvable<T> flatten() => flatten9();

  @pragma('vm:prefer-inline')
  Resolvable<T> flatten9() => flatten8().flatten2();
}
