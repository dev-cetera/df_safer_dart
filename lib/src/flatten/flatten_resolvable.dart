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

import 'package:meta/meta.dart' show protected;

import '../monads/monad.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

extension FlattenResolvable2<T extends Object> on Resolvable<Resolvable<T>> {
  @pragma('vm:prefer-inline')
  Resolvable<T> flatten() => flatten2();

  @protected
  Resolvable<T> flatten2() {
    switch (this) {
      case Sync(value: final outerResult):
        return outerResult.match(
          (innerResolvable) {
            switch (innerResolvable) {
              case Sync(value: final innerResult):
                return Sync.unsafe(innerResult);
              case Async(value: final innerFutureResult):
                return Async.unsafe(innerFutureResult);
            }
          },
          (err) => Sync.unsafe(err.transfErr()),
        );
      case Async(value: final outerFutureResult):
        return Async(() async {
          final outerResult = await outerFutureResult;
          return outerResult.match(
            (innerResolvable) {
              return innerResolvable.unwrap();
            },
            (err) => throw err,
          );
        });
    }
  }
}

extension FlattenResolvable3<T extends Object> on Resolvable<Resolvable<Resolvable<T>>> {
  @pragma('vm:prefer-inline')
  Resolvable<T> flatten() => flatten3();

  @protected
  @pragma('vm:prefer-inline')
  Resolvable<T> flatten3() => flatten2().flatten2();
}

extension FlattenResolvable4<T extends Object>
    on Resolvable<Resolvable<Resolvable<Resolvable<T>>>> {
  @pragma('vm:prefer-inline')
  Resolvable<T> flatten() => flatten4();

  @protected
  @pragma('vm:prefer-inline')
  Resolvable<T> flatten4() => flatten3().flatten2();
}

extension FlattenResolvable5<T extends Object>
    on Resolvable<Resolvable<Resolvable<Resolvable<Resolvable<T>>>>> {
  @pragma('vm:prefer-inline')
  Resolvable<T> flatten() => flatten5();

  @protected
  @pragma('vm:prefer-inline')
  Resolvable<T> flatten5() => flatten4().flatten2();
}

extension FlattenResolvable6<T extends Object>
    on Resolvable<Resolvable<Resolvable<Resolvable<Resolvable<Resolvable<T>>>>>> {
  @pragma('vm:prefer-inline')
  Resolvable<T> flatten() => flatten6();

  @protected
  @pragma('vm:prefer-inline')
  Resolvable<T> flatten6() => flatten5().flatten2();
}

extension FlattenResolvable7<T extends Object>
    on Resolvable<Resolvable<Resolvable<Resolvable<Resolvable<Resolvable<Resolvable<T>>>>>>> {
  @pragma('vm:prefer-inline')
  Resolvable<T> flatten() => flatten7();

  @protected
  @pragma('vm:prefer-inline')
  Resolvable<T> flatten7() => flatten6().flatten2();
}

extension FlattenResolvable8<T extends Object> on Resolvable<
    Resolvable<Resolvable<Resolvable<Resolvable<Resolvable<Resolvable<Resolvable<T>>>>>>>> {
  @pragma('vm:prefer-inline')
  Resolvable<T> flatten() => flatten8();

  @protected
  @pragma('vm:prefer-inline')
  Resolvable<T> flatten8() => flatten7().flatten2();
}

extension FlattenResolvable9<T extends Object> on Resolvable<
    Resolvable<
        Resolvable<Resolvable<Resolvable<Resolvable<Resolvable<Resolvable<Resolvable<T>>>>>>>>> {
  @pragma('vm:prefer-inline')
  Resolvable<T> flatten() => flatten9();

  @protected
  @pragma('vm:prefer-inline')
  Resolvable<T> flatten9() => flatten8().flatten2();
}
