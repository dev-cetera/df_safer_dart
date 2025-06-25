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

extension FlattenOkExt2<T extends Object> on Ok<Ok<T>> {
  @pragma('vm:prefer-inline')
  Ok<T> flatten() => flatten2();

  @protected
  Ok<T> flatten2() => value;
}

extension FlattenOkExt3<T extends Object> on Ok<Ok<Ok<T>>> {
  @pragma('vm:prefer-inline')
  Ok<T> flatten() => flatten3();

  @protected
  @pragma('vm:prefer-inline')
  Ok<T> flatten3() => flatten2().flatten2();
}

extension FlattenOkExt4<T extends Object> on Ok<Ok<Ok<Ok<T>>>> {
  @pragma('vm:prefer-inline')
  Ok<T> flatten() => flatten4();

  @protected
  @pragma('vm:prefer-inline')
  Ok<T> flatten4() => flatten3().flatten2();
}

extension FlattenOkExt5<T extends Object> on Ok<Ok<Ok<Ok<Ok<T>>>>> {
  @pragma('vm:prefer-inline')
  Ok<T> flatten() => flatten5();

  @protected
  @pragma('vm:prefer-inline')
  Ok<T> flatten5() => flatten4().flatten2();
}

extension FlattenOkExt6<T extends Object> on Ok<Ok<Ok<Ok<Ok<Ok<T>>>>>> {
  @pragma('vm:prefer-inline')
  Ok<T> flatten() => flatten6();

  @protected
  @pragma('vm:prefer-inline')
  Ok<T> flatten6() => flatten5().flatten2();
}

extension FlattenOkExt7<T extends Object> on Ok<Ok<Ok<Ok<Ok<Ok<Ok<T>>>>>>> {
  @pragma('vm:prefer-inline')
  Ok<T> flatten() => flatten7();

  @protected
  @pragma('vm:prefer-inline')
  Ok<T> flatten7() => flatten6().flatten2();
}

extension FlattenOkExt8<T extends Object> on Ok<Ok<Ok<Ok<Ok<Ok<Ok<Ok<T>>>>>>>> {
  @pragma('vm:prefer-inline')
  Ok<T> flatten() => flatten8();

  @protected
  @pragma('vm:prefer-inline')
  Ok<T> flatten8() => flatten7().flatten2();
}

extension FlattenOkExt9<T extends Object>
    on Ok<Ok<Ok<Ok<Ok<Ok<Ok<Ok<Ok<T>>>>>>>>> {
  @pragma('vm:prefer-inline')
  Ok<T> flatten() => flatten9();

  @protected
  @pragma('vm:prefer-inline')
  Ok<T> flatten9() => flatten8().flatten2();
}
