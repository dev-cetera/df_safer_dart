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

// ignore_for_file: invalid_use_of_visible_for_testing_member

import '../monads/monad.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

extension FlattenResolvable2<T extends Object> on Resolvable<Resolvable<T>> {
  @pragma('vm:prefer-inline')
  Resolvable<T> flatten() => flatten2();

  Resolvable<T> flatten2() {
    if (value is Result<Resolvable<T>>) {
      return Sync(() {
        final a = value as Result<Resolvable<T>>;
        if (a.isErr()) {
          throw a;
        }
        final b = a.unwrap().value as Result<T>;
        if (b.isErr()) {
          throw b;
        }
        return b.unwrap();
      });
    } else {
      return Async(() async {
        final a = await value;
        if (a.isErr()) {
          throw a;
        }
        final b = await a.unwrap().value;
        if (b.isErr()) {
          throw b;
        }
        return b.unwrap();
      });
    }
  }
}

extension FlattenResolvable3<T extends Object>
    on Resolvable<Resolvable<Resolvable<T>>> {
  @pragma('vm:prefer-inline')
  Resolvable<T> flatten() => flatten3();

  @pragma('vm:prefer-inline')
  Resolvable<T> flatten3() => flatten2().flatten2();
}

extension FlattenResolvable4<T extends Object>
    on Resolvable<Resolvable<Resolvable<Resolvable<T>>>> {
  @pragma('vm:prefer-inline')
  Resolvable<T> flatten() => flatten4();

  @pragma('vm:prefer-inline')
  Resolvable<T> flatten4() => flatten3().flatten2();
}

extension FlattenResolvable5<T extends Object>
    on Resolvable<Resolvable<Resolvable<Resolvable<Resolvable<T>>>>> {
  @pragma('vm:prefer-inline')
  Resolvable<T> flatten() => flatten5();

  @pragma('vm:prefer-inline')
  Resolvable<T> flatten5() => flatten4().flatten2();
}

extension FlattenResolvable6<T extends Object>
    on
        Resolvable<
          Resolvable<Resolvable<Resolvable<Resolvable<Resolvable<T>>>>>
        > {
  @pragma('vm:prefer-inline')
  Resolvable<T> flatten() => flatten6();

  @pragma('vm:prefer-inline')
  Resolvable<T> flatten6() => flatten5().flatten2();
}

extension FlattenResolvable7<T extends Object>
    on
        Resolvable<
          Resolvable<
            Resolvable<Resolvable<Resolvable<Resolvable<Resolvable<T>>>>>
          >
        > {
  @pragma('vm:prefer-inline')
  Resolvable<T> flatten() => flatten7();

  @pragma('vm:prefer-inline')
  Resolvable<T> flatten7() => flatten6().flatten2();
}

extension FlattenResolvable8<T extends Object>
    on
        Resolvable<
          Resolvable<
            Resolvable<
              Resolvable<Resolvable<Resolvable<Resolvable<Resolvable<T>>>>>
            >
          >
        > {
  @pragma('vm:prefer-inline')
  Resolvable<T> flatten() => flatten8();

  @pragma('vm:prefer-inline')
  Resolvable<T> flatten8() => flatten7().flatten2();
}

extension FlattenResolvable9<T extends Object>
    on
        Resolvable<
          Resolvable<
            Resolvable<
              Resolvable<
                Resolvable<Resolvable<Resolvable<Resolvable<Resolvable<T>>>>>
              >
            >
          >
        > {
  @pragma('vm:prefer-inline')
  Resolvable<T> flatten() => flatten9();

  @pragma('vm:prefer-inline')
  Resolvable<T> flatten9() => flatten8().flatten2();
}
