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

extension FlattenOptionExt2<T extends Object> on Option<Option<T>> {
  @pragma('vm:prefer-inline')
  Option<T> flatten() => flatten2();

  @protected
  Option<T> flatten2() {
    switch (this) {
      case Some(value: final innerResult):
        return innerResult;
      case None():
        return const None();
    }
  }
}

extension FlattenOptionExt3<T extends Object> on Option<Option<Option<T>>> {
  @pragma('vm:prefer-inline')
  Option<T> flatten() => flatten3();

  @protected
  @pragma('vm:prefer-inline')
  Option<T> flatten3() => flatten2().flatten2();
}

extension FlattenOptionExt4<T extends Object>
    on Option<Option<Option<Option<T>>>> {
  @pragma('vm:prefer-inline')
  Option<T> flatten() => flatten4();

  @protected
  @pragma('vm:prefer-inline')
  Option<T> flatten4() => flatten3().flatten2();
}

extension FlattenOptionExt5<T extends Object>
    on Option<Option<Option<Option<Option<T>>>>> {
  @pragma('vm:prefer-inline')
  Option<T> flatten() => flatten5();

  @protected
  @pragma('vm:prefer-inline')
  Option<T> flatten5() => flatten4().flatten2();
}

extension FlattenOptionExt6<T extends Object>
    on Option<Option<Option<Option<Option<Option<T>>>>>> {
  @pragma('vm:prefer-inline')
  Option<T> flatten() => flatten6();

  @protected
  @pragma('vm:prefer-inline')
  Option<T> flatten6() => flatten5().flatten2();
}

extension FlattenOptionExt7<T extends Object>
    on Option<Option<Option<Option<Option<Option<Option<T>>>>>>> {
  @pragma('vm:prefer-inline')
  Option<T> flatten() => flatten7();

  @protected
  @pragma('vm:prefer-inline')
  Option<T> flatten7() => flatten6().flatten2();
}

extension FlattenOptionExt8<T extends Object>
    on Option<Option<Option<Option<Option<Option<Option<Option<T>>>>>>>> {
  @pragma('vm:prefer-inline')
  Option<T> flatten() => flatten8();

  @protected
  @pragma('vm:prefer-inline')
  Option<T> flatten8() => flatten7().flatten2();
}

extension FlattenOptionExt9<T extends Object>
    on
        Option<
          Option<Option<Option<Option<Option<Option<Option<Option<T>>>>>>>>
        > {
  @pragma('vm:prefer-inline')
  Option<T> flatten() => flatten9();

  @protected
  @pragma('vm:prefer-inline')
  Option<T> flatten9() => flatten8().flatten2();
}
