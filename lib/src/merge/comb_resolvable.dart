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

import '../monad/monad.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

extension CombResolvable2<T extends Object> on Resolvable<Resolvable<T>> {
  @pragma('vm:prefer-inline')
  Resolvable<T> comb() => comb2();

  Resolvable<T> comb2() {
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

extension CombResolvable3<T extends Object>
    on Resolvable<Resolvable<Resolvable<T>>> {
  @pragma('vm:prefer-inline')
  Resolvable<T> comb() => comb3();

  @pragma('vm:prefer-inline')
  Resolvable<T> comb3() => comb2().comb2();
}

extension CombResolvable4<T extends Object>
    on Resolvable<Resolvable<Resolvable<Resolvable<T>>>> {
  @pragma('vm:prefer-inline')
  Resolvable<T> comb() => comb4();

  @pragma('vm:prefer-inline')
  Resolvable<T> comb4() => comb3().comb2();
}

extension CombResolvable5<T extends Object>
    on Resolvable<Resolvable<Resolvable<Resolvable<Resolvable<T>>>>> {
  @pragma('vm:prefer-inline')
  Resolvable<T> comb() => comb5();

  @pragma('vm:prefer-inline')
  Resolvable<T> comb5() => comb4().comb2();
}

extension CombResolvable6<T extends Object>
    on
        Resolvable<
          Resolvable<Resolvable<Resolvable<Resolvable<Resolvable<T>>>>>
        > {
  @pragma('vm:prefer-inline')
  Resolvable<T> comb() => comb6();

  @pragma('vm:prefer-inline')
  Resolvable<T> comb6() => comb5().comb2();
}

extension CombResolvable7<T extends Object>
    on
        Resolvable<
          Resolvable<
            Resolvable<Resolvable<Resolvable<Resolvable<Resolvable<T>>>>>
          >
        > {
  @pragma('vm:prefer-inline')
  Resolvable<T> comb() => comb7();

  @pragma('vm:prefer-inline')
  Resolvable<T> comb7() => comb6().comb2();
}

extension CombResolvable8<T extends Object>
    on
        Resolvable<
          Resolvable<
            Resolvable<
              Resolvable<Resolvable<Resolvable<Resolvable<Resolvable<T>>>>>
            >
          >
        > {
  @pragma('vm:prefer-inline')
  Resolvable<T> comb() => comb8();

  @pragma('vm:prefer-inline')
  Resolvable<T> comb8() => comb7().comb2();
}

extension CombResolvable9<T extends Object>
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
  Resolvable<T> comb() => comb9();

  @pragma('vm:prefer-inline')
  Resolvable<T> comb9() => comb8().comb2();
}
