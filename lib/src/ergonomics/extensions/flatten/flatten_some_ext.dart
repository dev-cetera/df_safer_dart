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

extension FlattenSomeExt2<T extends Object> on Some<Some<T>> {
  @pragma('vm:prefer-inline')
  Some<T> flatten() => flatten2();

  @protected
  Some<T> flatten2() => value;
}

extension FlattenSomeExt3<T extends Object> on Some<Some<Some<T>>> {
  @pragma('vm:prefer-inline')
  Some<T> flatten() => flatten3();

  @protected
  @pragma('vm:prefer-inline')
  Some<T> flatten3() => flatten2().flatten2();
}

extension FlattenSomeExt4<T extends Object> on Some<Some<Some<Some<T>>>> {
  @pragma('vm:prefer-inline')
  Some<T> flatten() => flatten4();

  @protected
  @pragma('vm:prefer-inline')
  Some<T> flatten4() => flatten3().flatten2();
}

extension FlattenSomeExt5<T extends Object> on Some<Some<Some<Some<Some<T>>>>> {
  @pragma('vm:prefer-inline')
  Some<T> flatten() => flatten5();

  @protected
  @pragma('vm:prefer-inline')
  Some<T> flatten5() => flatten4().flatten2();
}

extension FlattenSomeExt6<T extends Object>
    on Some<Some<Some<Some<Some<Some<T>>>>>> {
  @pragma('vm:prefer-inline')
  Some<T> flatten() => flatten6();

  @protected
  @pragma('vm:prefer-inline')
  Some<T> flatten6() => flatten5().flatten2();
}

extension FlattenSomeExt7<T extends Object>
    on Some<Some<Some<Some<Some<Some<Some<T>>>>>>> {
  @pragma('vm:prefer-inline')
  Some<T> flatten() => flatten7();

  @protected
  @pragma('vm:prefer-inline')
  Some<T> flatten7() => flatten6().flatten2();
}

extension FlattenSomeExt8<T extends Object>
    on Some<Some<Some<Some<Some<Some<Some<Some<T>>>>>>>> {
  @pragma('vm:prefer-inline')
  Some<T> flatten() => flatten8();

  @protected
  @pragma('vm:prefer-inline')
  Some<T> flatten8() => flatten7().flatten2();
}

extension FlattenSomeExt9<T extends Object>
    on Some<Some<Some<Some<Some<Some<Some<Some<Some<T>>>>>>>>> {
  @pragma('vm:prefer-inline')
  Some<T> flatten() => flatten9();

  @protected
  @pragma('vm:prefer-inline')
  Some<T> flatten9() => flatten8().flatten2();
}
