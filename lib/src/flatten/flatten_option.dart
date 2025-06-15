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

extension FlattenOption2<T extends Object> on Option<Option<T>> {
  @pragma('vm:prefer-inline')
  Option<T> flatten() => flatten2();

  Option<T> flatten2() {
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

extension FlattenOption3<T extends Object> on Option<Option<Option<T>>> {
  @pragma('vm:prefer-inline')
  Option<T> flatten() => flatten3();

  @pragma('vm:prefer-inline')
  Option<T> flatten3() => flatten2().flatten2();
}

extension FlattenOption4<T extends Object>
    on Option<Option<Option<Option<T>>>> {
  @pragma('vm:prefer-inline')
  Option<T> flatten() => flatten4();

  @pragma('vm:prefer-inline')
  Option<T> flatten4() => flatten3().flatten2();
}

extension FlattenOption5<T extends Object>
    on Option<Option<Option<Option<Option<T>>>>> {
  @pragma('vm:prefer-inline')
  Option<T> flatten() => flatten5();

  @pragma('vm:prefer-inline')
  Option<T> flatten5() => flatten4().flatten2();
}

extension FlattenOption6<T extends Object>
    on Option<Option<Option<Option<Option<Option<T>>>>>> {
  @pragma('vm:prefer-inline')
  Option<T> flatten() => flatten6();

  @pragma('vm:prefer-inline')
  Option<T> flatten6() => flatten5().flatten2();
}

extension FlattenOption7<T extends Object>
    on Option<Option<Option<Option<Option<Option<Option<T>>>>>>> {
  @pragma('vm:prefer-inline')
  Option<T> flatten() => flatten7();

  @pragma('vm:prefer-inline')
  Option<T> flatten7() => flatten6().flatten2();
}

extension FlattenOption8<T extends Object>
    on Option<Option<Option<Option<Option<Option<Option<Option<T>>>>>>>> {
  @pragma('vm:prefer-inline')
  Option<T> flatten() => flatten8();

  @pragma('vm:prefer-inline')
  Option<T> flatten8() => flatten7().flatten2();
}

extension FlattenOption9<T extends Object>
    on
        Option<
          Option<Option<Option<Option<Option<Option<Option<Option<T>>>>>>>>
        > {
  @pragma('vm:prefer-inline')
  Option<T> flatten() => flatten9();

  @pragma('vm:prefer-inline')
  Option<T> flatten9() => flatten8().flatten2();
}
