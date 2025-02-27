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

extension CombOption2<T extends Object> on Option<Option<T>> {
  @pragma('vm:prefer-inline')
  Option<T> comb() => comb2();

  Option<T> comb2() {
    if (isNone()) {
      return const None();
    } else {
      final option = unwrap();
      if (option.isNone()) {
        return const None();
      } else {
        return Some(option.unwrap());
      }
    }
  }
}

extension CombOption3<T extends Object> on Option<Option<Option<T>>> {
  @pragma('vm:prefer-inline')
  Option<T> comb() => comb3();

  @pragma('vm:prefer-inline')
  Option<T> comb3() => comb2().comb2();
}

extension CombOption4<T extends Object> on Option<Option<Option<Option<T>>>> {
  @pragma('vm:prefer-inline')
  Option<T> comb() => comb4();

  @pragma('vm:prefer-inline')
  Option<T> comb4() => comb3().comb2();
}

extension CombOption5<T extends Object>
    on Option<Option<Option<Option<Option<T>>>>> {
  @pragma('vm:prefer-inline')
  Option<T> comb() => comb5();

  @pragma('vm:prefer-inline')
  Option<T> comb5() => comb4().comb2();
}

extension CombOption6<T extends Object>
    on Option<Option<Option<Option<Option<Option<T>>>>>> {
  @pragma('vm:prefer-inline')
  Option<T> comb() => comb6();

  @pragma('vm:prefer-inline')
  Option<T> comb6() => comb5().comb2();
}

extension CombOption7<T extends Object>
    on Option<Option<Option<Option<Option<Option<Option<T>>>>>>> {
  @pragma('vm:prefer-inline')
  Option<T> comb() => comb7();

  @pragma('vm:prefer-inline')
  Option<T> comb7() => comb6().comb2();
}

extension CombOption8<T extends Object>
    on Option<Option<Option<Option<Option<Option<Option<Option<T>>>>>>>> {
  @pragma('vm:prefer-inline')
  Option<T> comb() => comb8();

  @pragma('vm:prefer-inline')
  Option<T> comb8() => comb7().comb2();
}

extension CombOption9<T extends Object>
    on
        Option<
          Option<Option<Option<Option<Option<Option<Option<Option<T>>>>>>>>
        > {
  @pragma('vm:prefer-inline')
  Option<T> comb() => comb9();

  @pragma('vm:prefer-inline')
  Option<T> comb9() => comb8().comb2();
}
