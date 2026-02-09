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

extension FlattenNoneExt2<T extends Object> on None<None<T>> {
  @pragma('vm:prefer-inline')
  None<T> flatten() => flatten2();

  @protected
  None<T> flatten2() => const None();
}

extension FlattenNoneExt3<T extends Object> on None<None<None<T>>> {
  @pragma('vm:prefer-inline')
  None<T> flatten() => flatten3();

  @protected
  @pragma('vm:prefer-inline')
  None<T> flatten3() => flatten2().flatten2();
}

extension FlattenNoneExt4<T extends Object> on None<None<None<None<T>>>> {
  @pragma('vm:prefer-inline')
  None<T> flatten() => flatten4();

  @protected
  @pragma('vm:prefer-inline')
  None<T> flatten4() => flatten3().flatten2();
}

extension FlattenNoneExt5<T extends Object> on None<None<None<None<None<T>>>>> {
  @pragma('vm:prefer-inline')
  None<T> flatten() => flatten5();

  @protected
  @pragma('vm:prefer-inline')
  None<T> flatten5() => flatten4().flatten2();
}

extension FlattenNoneExt6<T extends Object>
    on None<None<None<None<None<None<T>>>>>> {
  @pragma('vm:prefer-inline')
  None<T> flatten() => flatten6();

  @protected
  @pragma('vm:prefer-inline')
  None<T> flatten6() => flatten5().flatten2();
}

extension FlattenNoneExt7<T extends Object>
    on None<None<None<None<None<None<None<T>>>>>>> {
  @pragma('vm:prefer-inline')
  None<T> flatten() => flatten7();

  @protected
  @pragma('vm:prefer-inline')
  None<T> flatten7() => flatten6().flatten2();
}

extension FlattenNoneExt8<T extends Object>
    on None<None<None<None<None<None<None<None<T>>>>>>>> {
  @pragma('vm:prefer-inline')
  None<T> flatten() => flatten8();

  @protected
  @pragma('vm:prefer-inline')
  None<T> flatten8() => flatten7().flatten2();
}

extension FlattenNoneExt9<T extends Object>
    on None<None<None<None<None<None<None<None<None<T>>>>>>>>> {
  @pragma('vm:prefer-inline')
  None<T> flatten() => flatten9();

  @protected
  @pragma('vm:prefer-inline')
  None<T> flatten9() => flatten8().flatten2();
}
