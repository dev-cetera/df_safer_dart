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

import '/_common.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

extension FlattenResultExt2<T extends Object> on Result<Result<T>> {
  @pragma('vm:prefer-inline')
  Result<T> flatten() => flatten2();

  @protected
  Result<T> flatten2() {
    switch (this) {
      case Ok(value: final innerResult):
        return innerResult;
      case Err err:
        return err.transfErr();
    }
  }
}

extension FlattenResultExt3<T extends Object> on Result<Result<Result<T>>> {
  @pragma('vm:prefer-inline')
  Result<T> flatten() => flatten3();

  @protected
  @pragma('vm:prefer-inline')
  Result<T> flatten3() => flatten2().flatten2();
}

extension FlattenResultExt4<T extends Object> on Result<Result<Result<Result<T>>>> {
  @pragma('vm:prefer-inline')
  Result<T> flatten() => flatten4();

  @protected
  @pragma('vm:prefer-inline')
  Result<T> flatten4() => flatten3().flatten2();
}

extension FlattenResultExt5<T extends Object> on Result<Result<Result<Result<Result<T>>>>> {
  @pragma('vm:prefer-inline')
  Result<T> flatten() => flatten5();

  @protected
  @pragma('vm:prefer-inline')
  Result<T> flatten5() => flatten4().flatten2();
}

extension FlattenResultExt6<T extends Object> on Result<Result<Result<Result<Result<Result<T>>>>>> {
  @pragma('vm:prefer-inline')
  Result<T> flatten() => flatten6();

  @protected
  @pragma('vm:prefer-inline')
  Result<T> flatten6() => flatten5().flatten2();
}

extension FlattenResultExt7<T extends Object>
    on Result<Result<Result<Result<Result<Result<Result<T>>>>>>> {
  @pragma('vm:prefer-inline')
  Result<T> flatten() => flatten7();

  @protected
  @pragma('vm:prefer-inline')
  Result<T> flatten7() => flatten6().flatten2();
}

extension FlattenResultExt8<T extends Object>
    on Result<Result<Result<Result<Result<Result<Result<Result<T>>>>>>>> {
  @pragma('vm:prefer-inline')
  Result<T> flatten() => flatten8();

  @protected
  @pragma('vm:prefer-inline')
  Result<T> flatten8() => flatten7().flatten2();
}

extension FlattenResultExt9<T extends Object>
    on Result<Result<Result<Result<Result<Result<Result<Result<Result<T>>>>>>>>> {
  @pragma('vm:prefer-inline')
  Result<T> flatten() => flatten9();

  @protected
  @pragma('vm:prefer-inline')
  Result<T> flatten9() => flatten8().flatten2();
}
