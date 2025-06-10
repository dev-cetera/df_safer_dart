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

import '../monads/monad.dart';
import 'helpers.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

extension MapMonad2<T extends Object> on Monad<Monad<Object>> {
  @pragma('vm:prefer-inline')
  TReduced<Object> map2<R extends Object>(R Function(T) mapper) {
    return map((e) => e.map((e) => mapper(e as T))).reduce();
  }
}

extension MapMonad3<T extends Object> on Monad<Monad<Monad<Object>>> {
  @pragma('vm:prefer-inline')
  TReduced<Object> map3<R extends Object>(R Function(T) mapper) {
    return map((e) => e.map2((e) => mapper(e as T))).reduce();
  }
}

extension MapMonad4<T extends Object> on Monad<Monad<Monad<Monad<Object>>>> {
  @pragma('vm:prefer-inline')
  TReduced<Object> map4<R extends Object>(R Function(T) mapper) {
    return map((e) => e.map3((e) => mapper(e as T))).reduce();
  }
}

extension MapMonad5<T extends Object> on Monad<Monad<Monad<Monad<Monad<Object>>>>> {
  @pragma('vm:prefer-inline')
  TReduced<Object> map5<R extends Object>(R Function(T) mapper) {
    return map((e) => e.map4((e) => mapper(e as T))).reduce();
  }
}

extension MapMonad6<T extends Object> on Monad<Monad<Monad<Monad<Monad<Monad<Object>>>>>> {
  @pragma('vm:prefer-inline')
  TReduced<Object> map6<R extends Object>(R Function(T) mapper) {
    return map((e) => e.map5((e) => mapper(e as T))).reduce();
  }
}

extension MapMonad7<T extends Object> on Monad<Monad<Monad<Monad<Monad<Monad<Monad<Object>>>>>>> {
  @pragma('vm:prefer-inline')
  TReduced<Object> map7<R extends Object>(R Function(T) mapper) {
    return map((e) => e.map6((e) => mapper(e as T))).reduce();
  }
}

extension MapMonad8<T extends Object>
    on Monad<Monad<Monad<Monad<Monad<Monad<Monad<Monad<Object>>>>>>>> {
  @pragma('vm:prefer-inline')
  TReduced<Object> map8<R extends Object>(R Function(T) mapper) {
    return map((e) => e.map7((e) => mapper(e as T))).reduce();
  }
}

extension MapMonad9<T extends Object>
    on Monad<Monad<Monad<Monad<Monad<Monad<Monad<Monad<Monad<Object>>>>>>>>> {
  @pragma('vm:prefer-inline')
  TReduced<Object> map9<R extends Object>(R Function(T) mapper) {
    return map((e) => e.map8((e) => mapper(e as T))).reduce();
  }
}

extension MapMonad10<T extends Object>
    on Monad<Monad<Monad<Monad<Monad<Monad<Monad<Monad<Monad<Monad<Object>>>>>>>>>> {
  @pragma('vm:prefer-inline')
  TReduced<Object> map10<R extends Object>(R Function(T) mapper) {
    return map((e) => e.map9((e) => mapper(e as T))).reduce();
  }
}

extension MapMonad11<T extends Object>
    on Monad<Monad<Monad<Monad<Monad<Monad<Monad<Monad<Monad<Monad<Monad<Object>>>>>>>>>>> {
  @pragma('vm:prefer-inline')
  TReduced<Object> map11<R extends Object>(R Function(T) mapper) {
    return map((e) => e.map10((e) => mapper(e as T))).reduce();
  }
}

extension MapMonad12<T extends Object>
    on Monad<Monad<Monad<Monad<Monad<Monad<Monad<Monad<Monad<Monad<Monad<Monad<Object>>>>>>>>>>>> {
  @pragma('vm:prefer-inline')
  TReduced<Object> map12<R extends Object>(R Function(T) mapper) {
    return map((e) => e.map11((e) => mapper(e as T))).reduce();
  }
}

extension MapMonad13<T extends Object> on Monad<
    Monad<Monad<Monad<Monad<Monad<Monad<Monad<Monad<Monad<Monad<Monad<Monad<Object>>>>>>>>>>>>> {
  @pragma('vm:prefer-inline')
  TReduced<Object> map13<R extends Object>(R Function(T) mapper) {
    return map((e) => e.map12((e) => mapper(e as T))).reduce();
  }
}

extension MapMonad14<T extends Object> on Monad<
    Monad<
        Monad<
            Monad<Monad<Monad<Monad<Monad<Monad<Monad<Monad<Monad<Monad<Monad<Object>>>>>>>>>>>>>> {
  @pragma('vm:prefer-inline')
  TReduced<Object> map14<R extends Object>(R Function(T) mapper) {
    return map((e) => e.map13((e) => mapper(e as T))).reduce();
  }
}

extension MapMonad15<T extends Object> on Monad<
    Monad<
        Monad<
            Monad<
                Monad<
                    Monad<
                        Monad<
                            Monad<Monad<Monad<Monad<Monad<Monad<Monad<Monad<Object>>>>>>>>>>>>>>> {
  @pragma('vm:prefer-inline')
  TReduced<Object> map15<R extends Object>(R Function(T) mapper) {
    return map((e) => e.map14((e) => mapper(e as T))).reduce();
  }
}

extension MapMonad16<T extends Object> on Monad<
    Monad<
        Monad<
            Monad<
                Monad<
                    Monad<
                        Monad<
                            Monad<
                                Monad<
                                    Monad<
                                        Monad<Monad<Monad<Monad<Monad<Monad<Object>>>>>>>>>>>>>>>> {
  @pragma('vm:prefer-inline')
  TReduced<Object> map16<R extends Object>(R Function(T) mapper) {
    return map((e) => e.map15((e) => mapper(e as T))).reduce();
  }
}

extension MapMonad17<T extends Object> on Monad<
    Monad<
        Monad<
            Monad<
                Monad<
                    Monad<
                        Monad<
                            Monad<
                                Monad<
                                    Monad<
                                        Monad<
                                            Monad<
                                                Monad<
                                                    Monad<
                                                        Monad<Monad<Monad<Object>>>>>>>>>>>>>>>>> {
  @pragma('vm:prefer-inline')
  TReduced<Object> map17<R extends Object>(R Function(T) mapper) {
    return map((e) => e.map16((e) => mapper(e as T))).reduce();
  }
}

extension MapMonad18<T extends Object> on Monad<
    Monad<
        Monad<
            Monad<
                Monad<
                    Monad<
                        Monad<
                            Monad<
                                Monad<
                                    Monad<
                                        Monad<
                                            Monad<
                                                Monad<
                                                    Monad<
                                                        Monad<
                                                            Monad<
                                                                Monad<
                                                                    Monad<Object>>>>>>>>>>>>>>>>>> {
  @pragma('vm:prefer-inline')
  TReduced<Object> map18<R extends Object>(R Function(T) mapper) {
    return map((e) => e.map17((e) => mapper(e as T))).reduce();
  }
}
