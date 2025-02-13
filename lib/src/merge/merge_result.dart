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

import '../monad/monad.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

extension MergeResult2<T extends Object> on Result<Result<T>> {
  @pragma('vm:prefer-inline')
  Result<T> merge() => _merge2();

  Result<T> _merge2() {
    if (isErr()) {
      return cast();
    } else {
      final result = unwrap();
      if (result.isErr()) {
        return result.cast();
      } else {
        return Ok(result.unwrap());
      }
    }
  }
}

extension MergeResult3<T extends Object> on Result<Result<Result<T>>> {
  @pragma('vm:prefer-inline')
  Result<T> merge() => _merge3();

  @pragma('vm:prefer-inline')
  Result<T> _merge3() => _merge2()._merge2();
}

extension MergeResult4<T extends Object> on Result<Result<Result<Result<T>>>> {
  @pragma('vm:prefer-inline')
  Result<T> merge() => _merge4();

  @pragma('vm:prefer-inline')
  Result<T> _merge4() => _merge3()._merge2();
}

extension MergeResult5<T extends Object>
    on Result<Result<Result<Result<Result<T>>>>> {
  @pragma('vm:prefer-inline')
  Result<T> merge() => _merge5();

  @pragma('vm:prefer-inline')
  Result<T> _merge5() => _merge4()._merge2();
}

extension MergeResult6<T extends Object>
    on Result<Result<Result<Result<Result<Result<T>>>>>> {
  @pragma('vm:prefer-inline')
  Result<T> merge() => _merge6();

  @pragma('vm:prefer-inline')
  Result<T> _merge6() => _merge5()._merge2();
}

extension MergeResult7<T extends Object>
    on Result<Result<Result<Result<Result<Result<Result<T>>>>>>> {
  @pragma('vm:prefer-inline')
  Result<T> merge() => _merge7();

  @pragma('vm:prefer-inline')
  Result<T> _merge7() => _merge6()._merge2();
}

extension MergeResult8<T extends Object>
    on Result<Result<Result<Result<Result<Result<Result<Result<T>>>>>>>> {
  @pragma('vm:prefer-inline')
  Result<T> merge() => _merge8();

  @pragma('vm:prefer-inline')
  Result<T> _merge8() => _merge7()._merge2();
}

extension MergeResult9<T extends Object>
    on
        Result<
          Result<Result<Result<Result<Result<Result<Result<Result<T>>>>>>>>
        > {
  @pragma('vm:prefer-inline')
  Result<T> merge() => _merge9();

  @pragma('vm:prefer-inline')
  Result<T> _merge9() => _merge8()._merge2();
}
