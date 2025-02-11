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

import '../df_safer_dart.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

extension MergeOption2<T extends Object> on Option<Option<T>> {
  Option<T> merge() {
    return _merge2();
  }

  Option<T> _merge2() {
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

extension MergeOption3<T extends Object> on Option<Option<Option<T>>> {
  @pragma('vm:prefer-inline')
  Option<T> merge() => _merge3();

  @pragma('vm:prefer-inline')
  Option<T> _merge3() => _merge2()._merge2();
}

extension MergeOption4<T extends Object> on Option<Option<Option<Option<T>>>> {
  @pragma('vm:prefer-inline')
  Option<T> merge() => _merge4();

  @pragma('vm:prefer-inline')
  Option<T> _merge4() => _merge3()._merge2();
}

extension MergeOption5<T extends Object> on Option<Option<Option<Option<Option<T>>>>> {
  @pragma('vm:prefer-inline')
  Option<T> merge() => _merge5();

  @pragma('vm:prefer-inline')
  Option<T> _merge5() => _merge4()._merge2();
}

extension MergeOption6<T extends Object> on Option<Option<Option<Option<Option<Option<T>>>>>> {
  @pragma('vm:prefer-inline')
  Option<T> merge() => _merge6();

  @pragma('vm:prefer-inline')
  Option<T> _merge6() => _merge5()._merge2();
}

extension MergeOption7<T extends Object>
    on Option<Option<Option<Option<Option<Option<Option<T>>>>>>> {
  @pragma('vm:prefer-inline')
  Option<T> merge() => _merge7();

  @pragma('vm:prefer-inline')
  Option<T> _merge7() => _merge6()._merge2();
}

extension MergeOption8<T extends Object>
    on Option<Option<Option<Option<Option<Option<Option<Option<T>>>>>>>> {
  @pragma('vm:prefer-inline')
  Option<T> merge() => _merge8();

  @pragma('vm:prefer-inline')
  Option<T> _merge8() => _merge7()._merge2();
}

extension MergeOption9<T extends Object>
    on Option<Option<Option<Option<Option<Option<Option<Option<Option<T>>>>>>>>> {
  @pragma('vm:prefer-inline')
  Option<T> merge() => _merge9();

  @pragma('vm:prefer-inline')
  Option<T> _merge9() => _merge8()._merge2();
}
