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

extension MapMonadExt2<T extends Object> on Monad<Monad<Object>> {
  @pragma('vm:prefer-inline')
  TResolvableOption<Object> map2<R extends Object>(R Function(T) mapper) {
    return map((e) => e.map((e) => mapper(e as T))).reduce();
  }
}

extension MapMonadExt3<T extends Object> on Monad<Monad<Monad<Object>>> {
  @pragma('vm:prefer-inline')
  TResolvableOption<Object> map3<R extends Object>(R Function(T) mapper) {
    return map((e) => e.map2((e) => mapper(e as T))).reduce();
  }
}

extension MapMonadExt4<T extends Object> on Monad<Monad<Monad<Monad<Object>>>> {
  @pragma('vm:prefer-inline')
  TResolvableOption<Object> map4<R extends Object>(R Function(T) mapper) {
    return map((e) => e.map3((e) => mapper(e as T))).reduce();
  }
}

extension MapMonadExt5<T extends Object>
    on Monad<Monad<Monad<Monad<Monad<Object>>>>> {
  @pragma('vm:prefer-inline')
  TResolvableOption<Object> map5<R extends Object>(R Function(T) mapper) {
    return map((e) => e.map4((e) => mapper(e as T))).reduce();
  }
}

extension MapMonadExt6<T extends Object>
    on Monad<Monad<Monad<Monad<Monad<Monad<Object>>>>>> {
  @pragma('vm:prefer-inline')
  TResolvableOption<Object> map6<R extends Object>(R Function(T) mapper) {
    return map((e) => e.map5((e) => mapper(e as T))).reduce();
  }
}

extension MapMonadExt7<T extends Object>
    on Monad<Monad<Monad<Monad<Monad<Monad<Monad<Object>>>>>>> {
  @pragma('vm:prefer-inline')
  TResolvableOption<Object> map7<R extends Object>(R Function(T) mapper) {
    return map((e) => e.map6((e) => mapper(e as T))).reduce();
  }
}

extension MapMonadExt8<T extends Object>
    on Monad<Monad<Monad<Monad<Monad<Monad<Monad<Monad<Object>>>>>>>> {
  @pragma('vm:prefer-inline')
  TResolvableOption<Object> map8<R extends Object>(R Function(T) mapper) {
    return map((e) => e.map7((e) => mapper(e as T))).reduce();
  }
}

extension MapMonadExt9<T extends Object>
    on Monad<Monad<Monad<Monad<Monad<Monad<Monad<Monad<Monad<Object>>>>>>>>> {
  @pragma('vm:prefer-inline')
  TResolvableOption<Object> map9<R extends Object>(R Function(T) mapper) {
    return map((e) => e.map8((e) => mapper(e as T))).reduce();
  }
}

extension MapMonadExt10<T extends Object>
    on
        Monad<
          Monad<Monad<Monad<Monad<Monad<Monad<Monad<Monad<Monad<Object>>>>>>>>>
        > {
  @pragma('vm:prefer-inline')
  TResolvableOption<Object> map10<R extends Object>(R Function(T) mapper) {
    return map((e) => e.map9((e) => mapper(e as T))).reduce();
  }
}
