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

extension CombResult2<T extends Object> on Result<Result<T>> {
  @pragma('vm:prefer-inline')
  Result<T> comb() => comb2();

  Result<T> comb2() {
    if (isErr()) {
      return transf();
    } else {
      final result = unwrap();
      if (result.isErr()) {
        return result.transf();
      } else {
        return Ok(result.unwrap());
      }
    }
  }
}

extension CombResult3<T extends Object> on Result<Result<Result<T>>> {
  @pragma('vm:prefer-inline')
  Result<T> comb() => comb3();

  @pragma('vm:prefer-inline')
  Result<T> comb3() => comb2().comb2();
}

extension CombResult4<T extends Object> on Result<Result<Result<Result<T>>>> {
  @pragma('vm:prefer-inline')
  Result<T> comb() => comb4();

  @pragma('vm:prefer-inline')
  Result<T> comb4() => comb3().comb2();
}

extension CombResult5<T extends Object>
    on Result<Result<Result<Result<Result<T>>>>> {
  @pragma('vm:prefer-inline')
  Result<T> comb() => comb5();

  @pragma('vm:prefer-inline')
  Result<T> comb5() => comb4().comb2();
}

extension CombResult6<T extends Object>
    on Result<Result<Result<Result<Result<Result<T>>>>>> {
  @pragma('vm:prefer-inline')
  Result<T> comb() => comb6();

  @pragma('vm:prefer-inline')
  Result<T> comb6() => comb5().comb2();
}

extension CombResult7<T extends Object>
    on Result<Result<Result<Result<Result<Result<Result<T>>>>>>> {
  @pragma('vm:prefer-inline')
  Result<T> comb() => comb7();

  @pragma('vm:prefer-inline')
  Result<T> comb7() => comb6().comb2();
}

extension CombResult8<T extends Object>
    on Result<Result<Result<Result<Result<Result<Result<Result<T>>>>>>>> {
  @pragma('vm:prefer-inline')
  Result<T> comb() => comb8();

  @pragma('vm:prefer-inline')
  Result<T> comb8() => comb7().comb2();
}

extension CombResult9<T extends Object>
    on
        Result<
          Result<Result<Result<Result<Result<Result<Result<Result<T>>>>>>>>
        > {
  @pragma('vm:prefer-inline')
  Result<T> comb() => comb9();

  @pragma('vm:prefer-inline')
  Result<T> comb9() => comb8().comb2();
}
