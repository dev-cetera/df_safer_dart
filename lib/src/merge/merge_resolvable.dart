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

extension MergeResolvable2<T extends Object> on Resolvable<Resolvable<T>> {
  @pragma('vm:prefer-inline')
  Resolvable<T> merge() => _merge2();

  Resolvable<T> _merge2() {
    if (value is Result<Resolvable<T>>) {
      return Sync.unsafe(() {
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
      return Async.unsafe(() async {
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

extension MergeResolvable3<T extends Object>
    on Resolvable<Resolvable<Resolvable<T>>> {
  @pragma('vm:prefer-inline')
  Resolvable<T> merge() => _merge3();

  @pragma('vm:prefer-inline')
  Resolvable<T> _merge3() => _merge2()._merge2();
}

extension MergeResolvable4<T extends Object>
    on Resolvable<Resolvable<Resolvable<Resolvable<T>>>> {
  @pragma('vm:prefer-inline')
  Resolvable<T> merge() => _merge4();

  @pragma('vm:prefer-inline')
  Resolvable<T> _merge4() => _merge3()._merge2();
}

extension MergeResolvable5<T extends Object>
    on Resolvable<Resolvable<Resolvable<Resolvable<Resolvable<T>>>>> {
  @pragma('vm:prefer-inline')
  Resolvable<T> merge() => _merge5();

  @pragma('vm:prefer-inline')
  Resolvable<T> _merge5() => _merge4()._merge2();
}

extension MergeResolvable6<T extends Object>
    on
        Resolvable<
          Resolvable<Resolvable<Resolvable<Resolvable<Resolvable<T>>>>>
        > {
  @pragma('vm:prefer-inline')
  Resolvable<T> merge() => _merge6();

  @pragma('vm:prefer-inline')
  Resolvable<T> _merge6() => _merge5()._merge2();
}

extension MergeResolvable7<T extends Object>
    on
        Resolvable<
          Resolvable<
            Resolvable<Resolvable<Resolvable<Resolvable<Resolvable<T>>>>>
          >
        > {
  @pragma('vm:prefer-inline')
  Resolvable<T> merge() => _merge7();

  @pragma('vm:prefer-inline')
  Resolvable<T> _merge7() => _merge6()._merge2();
}

extension MergeResolvable8<T extends Object>
    on
        Resolvable<
          Resolvable<
            Resolvable<
              Resolvable<Resolvable<Resolvable<Resolvable<Resolvable<T>>>>>
            >
          >
        > {
  @pragma('vm:prefer-inline')
  Resolvable<T> merge() => _merge8();

  @pragma('vm:prefer-inline')
  Resolvable<T> _merge8() => _merge7()._merge2();
}

extension MergeResolvable9<T extends Object>
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
  Resolvable<T> merge() => _merge9();

  @pragma('vm:prefer-inline')
  Resolvable<T> _merge9() => _merge8()._merge2();
}
