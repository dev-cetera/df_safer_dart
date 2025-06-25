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

extension FlattenSyncExt2<T extends Object> on Sync<Sync<T>> {
  @pragma('vm:prefer-inline')
  Sync<T> flatten() => flatten2();

  @protected
  Sync<T> flatten2() {
    switch (value) {
      case Ok(value: final innerSync):
        return innerSync;
      case final Err<Sync<T>> err:
        return Sync.err(err.transfErr());
    }
  }
}

extension FlattenSyncExt3<T extends Object> on Sync<Sync<Sync<T>>> {
  @pragma('vm:prefer-inline')
  Sync<T> flatten() => flatten3();

  @protected
  @pragma('vm:prefer-inline')
  Sync<T> flatten3() => flatten2().flatten2();
}

extension FlattenSyncExt4<T extends Object> on Sync<Sync<Sync<Sync<T>>>> {
  @pragma('vm:prefer-inline')
  Sync<T> flatten() => flatten4();

  @protected
  @pragma('vm:prefer-inline')
  Sync<T> flatten4() => flatten3().flatten2();
}

extension FlattenSyncExt5<T extends Object> on Sync<Sync<Sync<Sync<Sync<T>>>>> {
  @pragma('vm:prefer-inline')
  Sync<T> flatten() => flatten5();

  @protected
  @pragma('vm:prefer-inline')
  Sync<T> flatten5() => flatten4().flatten2();
}

extension FlattenSyncExt6<T extends Object>
    on Sync<Sync<Sync<Sync<Sync<Sync<T>>>>>> {
  @pragma('vm:prefer-inline')
  Sync<T> flatten() => flatten6();

  @protected
  @pragma('vm:prefer-inline')
  Sync<T> flatten6() => flatten5().flatten2();
}

extension FlattenSyncExt7<T extends Object>
    on Sync<Sync<Sync<Sync<Sync<Sync<Sync<T>>>>>>> {
  @pragma('vm:prefer-inline')
  Sync<T> flatten() => flatten7();

  @protected
  @pragma('vm:prefer-inline')
  Sync<T> flatten7() => flatten6().flatten2();
}

extension FlattenSyncExt8<T extends Object>
    on Sync<Sync<Sync<Sync<Sync<Sync<Sync<Sync<T>>>>>>>> {
  @pragma('vm:prefer-inline')
  Sync<T> flatten() => flatten8();

  @protected
  @pragma('vm:prefer-inline')
  Sync<T> flatten8() => flatten7().flatten2();
}

extension FlattenSyncExt9<T extends Object>
    on Sync<Sync<Sync<Sync<Sync<Sync<Sync<Sync<Sync<T>>>>>>>>> {
  @pragma('vm:prefer-inline')
  Sync<T> flatten() => flatten9();

  @protected
  @pragma('vm:prefer-inline')
  Sync<T> flatten9() => flatten8().flatten2();
}
