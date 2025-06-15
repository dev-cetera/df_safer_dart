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

import '../monads/monad.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

extension FlattenResult2<T extends Object> on Result<Result<T>> {
  @pragma('vm:prefer-inline')
  Result<T> flatten() => flatten2();

  Result<T> flatten2() {
    if (isErr()) {
      return transf();
    } else {
      return unwrap();
    }
  }
}

extension FlattenResult3<T extends Object> on Result<Result<Result<T>>> {
  @pragma('vm:prefer-inline')
  Result<T> flatten() => flatten3();

  @pragma('vm:prefer-inline')
  Result<T> flatten3() => flatten2().flatten2();
}

extension FlattenResult4<T extends Object>
    on Result<Result<Result<Result<T>>>> {
  @pragma('vm:prefer-inline')
  Result<T> flatten() => flatten4();

  @pragma('vm:prefer-inline')
  Result<T> flatten4() => flatten3().flatten2();
}

extension FlattenResult5<T extends Object>
    on Result<Result<Result<Result<Result<T>>>>> {
  @pragma('vm:prefer-inline')
  Result<T> flatten() => flatten5();

  @pragma('vm:prefer-inline')
  Result<T> flatten5() => flatten4().flatten2();
}

extension FlattenResult6<T extends Object>
    on Result<Result<Result<Result<Result<Result<T>>>>>> {
  @pragma('vm:prefer-inline')
  Result<T> flatten() => flatten6();

  @pragma('vm:prefer-inline')
  Result<T> flatten6() => flatten5().flatten2();
}

extension FlattenResult7<T extends Object>
    on Result<Result<Result<Result<Result<Result<Result<T>>>>>>> {
  @pragma('vm:prefer-inline')
  Result<T> flatten() => flatten7();

  @pragma('vm:prefer-inline')
  Result<T> flatten7() => flatten6().flatten2();
}

extension FlattenResult8<T extends Object>
    on Result<Result<Result<Result<Result<Result<Result<Result<T>>>>>>>> {
  @pragma('vm:prefer-inline')
  Result<T> flatten() => flatten8();

  @pragma('vm:prefer-inline')
  Result<T> flatten8() => flatten7().flatten2();
}

extension FlattenResult9<T extends Object> on Result<
    Result<Result<Result<Result<Result<Result<Result<Result<T>>>>>>>>> {
  @pragma('vm:prefer-inline')
  Result<T> flatten() => flatten9();

  @pragma('vm:prefer-inline')
  Result<T> flatten9() => flatten8().flatten2();
}
