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

import '/_common.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

extension FlattenErrExt2<T extends Object> on Err<Err<T>> {
  @pragma('vm:prefer-inline')
  Err<T> flatten() => flatten2();

  @protected
  Err<T> flatten2() => transfErr();
}

extension FlattenErrExt3<T extends Object> on Err<Err<Err<T>>> {
  @pragma('vm:prefer-inline')
  Err<T> flatten() => flatten3();

  @protected
  @pragma('vm:prefer-inline')
  Err<T> flatten3() => flatten2().flatten2();
}

extension FlattenErrExt4<T extends Object> on Err<Err<Err<Err<T>>>> {
  @pragma('vm:prefer-inline')
  Err<T> flatten() => flatten4();

  @protected
  @pragma('vm:prefer-inline')
  Err<T> flatten4() => flatten3().flatten2();
}

extension FlattenErrExt5<T extends Object> on Err<Err<Err<Err<Err<T>>>>> {
  @pragma('vm:prefer-inline')
  Err<T> flatten() => flatten5();

  @protected
  @pragma('vm:prefer-inline')
  Err<T> flatten5() => flatten4().flatten2();
}

extension FlattenErrExt6<T extends Object> on Err<Err<Err<Err<Err<Err<T>>>>>> {
  @pragma('vm:prefer-inline')
  Err<T> flatten() => flatten6();

  @protected
  @pragma('vm:prefer-inline')
  Err<T> flatten6() => flatten5().flatten2();
}

extension FlattenErrExt7<T extends Object>
    on Err<Err<Err<Err<Err<Err<Err<T>>>>>>> {
  @pragma('vm:prefer-inline')
  Err<T> flatten() => flatten7();

  @protected
  @pragma('vm:prefer-inline')
  Err<T> flatten7() => flatten6().flatten2();
}

extension FlattenErrExt8<T extends Object>
    on Err<Err<Err<Err<Err<Err<Err<Err<T>>>>>>>> {
  @pragma('vm:prefer-inline')
  Err<T> flatten() => flatten8();

  @protected
  @pragma('vm:prefer-inline')
  Err<T> flatten8() => flatten7().flatten2();
}

extension FlattenErrExt9<T extends Object>
    on Err<Err<Err<Err<Err<Err<Err<Err<Err<T>>>>>>>>> {
  @pragma('vm:prefer-inline')
  Err<T> flatten() => flatten9();

  @protected
  @pragma('vm:prefer-inline')
  Err<T> flatten9() => flatten8().flatten2();
}
