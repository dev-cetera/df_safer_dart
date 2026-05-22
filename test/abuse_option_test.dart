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


import 'package:df_safer_dart/df_safer_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Option construction', () {
    test('Some.new + value getter', () {
      const s = Some<int>(7);
      expect(s.value, 7);
      expect(s.isSome(), isTrue);
      expect(s.isNone(), isFalse);
    });

    test('const None<T>()', () {
      const n = None<int>();
      expect(n.isNone(), isTrue);
      expect(n.isSome(), isFalse);
    });

    test('Option.from(null) → None', () {
      final int? nullable = null;
      expect(Option<int>.from(nullable), isA<None<int>>());
    });

    test('Option.from(value) → Some(value)', () {
      final o = Option.from(42);
      expect(o, isA<Some<int>>());
      expect(o.unwrap(), 42);
    });

    test('Option.from preserves complex object identity', () {
      final list = [1, 2, 3];
      final o = Option.from(list);
      expect(identical(o.unwrap(), list), isTrue);
    });

    test('None<T>() across types is equal by Equatable contract', () {
      expect(const None<int>() == const None<int>(), isTrue);
    });

    test('Some equality is value-based', () {
      expect(const Some(1) == const Some(1), isTrue);
      expect(const Some(1) == const Some(2), isFalse);
    });
  });

  group('Option.isSome / isNone / some() / none()', () {
    test('Some.some() yields Ok', () {
      const s = Some<int>(1);
      expect(s.some(), isA<Ok<Some<int>>>());
    });

    test('Some.none() yields Err', () {
      const s = Some<int>(1);
      expect(s.none(), isA<Err<None<int>>>());
    });

    test('None.some() yields Err', () {
      const n = None<int>();
      expect(n.some(), isA<Err<Some<int>>>());
    });

    test('None.none() yields Ok', () {
      const n = None<int>();
      expect(n.none(), isA<Ok<None<int>>>());
    });
  });

  group('Option.ifSome / ifNone — side effects', () {
    test('ifSome runs on Some', () {
      var hit = 0;
      const s = Some<int>(1);
      final out = s.ifSome((self, some) => hit++);
      expect(hit, 1);
      expect(out, isA<Ok<Some<int>>>());
    });

    test('ifSome does not run on None', () {
      var hit = 0;
      const n = None<int>();
      n.ifSome((self, some) => hit++).end();
      expect(hit, 0);
    });

    test('ifSome callback that throws becomes Err', () {
      const s = Some<int>(1);
      final out = s.ifSome((_, __) => throw StateError('boom'));
      expect(out, isA<Err>());
      expect((out as Err).error, isA<StateError>());
    });

    test('ifNone runs on None', () {
      var hit = 0;
      const n = None<int>();
      n.ifNone((self, none) => hit++).end();
      expect(hit, 1);
    });

    test('ifNone does not run on Some', () {
      var hit = 0;
      const s = Some<int>(1);
      s.ifNone((self, none) => hit++).end();
      expect(hit, 0);
    });
  });

  group('Option.orNull / unwrap / unwrapOr', () {
    test('Some.orNull yields value', () {
      expect(const Some(9).orNull(), 9);
    });

    test('None.orNull yields null', () {
      expect(const None<int>().orNull(), isNull);
    });

    test('Some.unwrap yields value', () {
      expect(const Some(9).unwrap(), 9);
    });

    test('None.unwrap throws Err', () {
      const Option<int> n = None<int>();
      expect(() => n.unwrap(), throwsA(isA<Err>()));
    });

    test('Some.unwrapOr returns value', () {
      expect(const Some(9).unwrapOr(0), 9);
    });

    test('None.unwrapOr returns fallback', () {
      const Option<int> n = None<int>();
      expect(n.unwrapOr(0), 0);
    });
  });

  group('Option.map / mapSome / flatMap / filter', () {
    test('Some.map applies', () {
      final m = const Some(2).map((n) => n * 10);
      expect(m.unwrap(), 20);
    });

    test('None.map yields None', () {
      final m = const None<int>().map((n) => n * 10);
      expect(m, isA<None<int>>());
    });

    test('Some.mapSome receives a Some', () {
      var received = const Some<int>(0);
      const s = Some<int>(5);
      s.mapSome((some) {
        received = some;
        return some;
      }).end();
      expect(received.value, 5);
    });

    test('Some.flatMap chains', () {
      final out = const Some(2).flatMap((v) => Some(v + 1));
      expect(out.unwrap(), 3);
    });

    test('Some.flatMap to None', () {
      final out = const Some(2).flatMap((_) => const None<int>());
      expect(out, isA<None<int>>());
    });

    test('None.flatMap stays None', () {
      final out = const None<int>().flatMap((v) => Some(v + 1));
      expect(out, isA<None<int>>());
    });

    test('Some.filter true keeps', () {
      expect(const Some(2).filter((n) => n > 0).unwrap(), 2);
    });

    test('Some.filter false drops', () {
      expect(const Some(2).filter((n) => n < 0), isA<None<int>>());
    });

    test('None.filter stays None', () {
      expect(const None<int>().filter((_) => true), isA<None<int>>());
    });
  });

  group('Option.someOr / noneOr', () {
    test('Some.someOr returns self', () {
      expect(const Some(1).someOr(const Some(2)).unwrap(), 1);
    });

    test('None.someOr returns other', () {
      expect(const None<int>().someOr(const Some(2)).unwrap(), 2);
    });

    test('Some.noneOr returns other', () {
      expect(const Some(1).noneOr(const Some(2)).unwrap(), 2);
    });

    test('None.noneOr returns self', () {
      expect(const None<int>().noneOr(const Some(2)), isA<None<int>>());
    });
  });

  group('Option.fold — abuse', () {
    test('Some.fold calls onSome', () {
      final out = const Some(1).fold(
        (some) => Some(some.value * 2),
        (none) => fail('should not call onNone'),
      );
      expect(out, isA<Ok<Option<Object>>>());
    });

    test('Some.fold callback throw becomes Err', () {
      final out = const Some(1).fold(
        (_) => throw StateError('boom'),
        (_) => null,
      );
      expect(out, isA<Err>());
      expect((out as Err).error, isA<StateError>());
    });

    test('None.fold calls onNone', () {
      final out = const None<int>().fold(
        (_) => fail('should not call onSome'),
        (none) => const Some(99),
      );
      expect(out, isA<Ok<Option<Object>>>());
    });

    test('None.fold callback throw becomes Err', () {
      final out = const None<int>().fold(
        (_) => null,
        (_) => throw StateError('boom'),
      );
      expect(out, isA<Err>());
    });
  });

  group('Option.transf — cast safety', () {
    test('Some.transf with mapper applies', () {
      final out = const Some(2).transf<String>((n) => 'x$n');
      expect(out.unwrap().unwrap(), 'x2');
    });

    test('Some.transf without mapper, matching type, casts', () {
      final o = const Some<Object>(2) as Option<Object>;
      final out = o.transf<int>();
      expect((out.unwrap() as Some).value, 2);
    });

    test('Some.transf without mapper, wrong type, yields Err', () {
      final o = const Some<Object>('hello') as Option<Object>;
      final out = o.transf<int>();
      expect(out, isA<Err>());
    });

    test('None.transf yields None — never throws', () {
      final out = const None<int>().transf<String>();
      expect(out, isA<Ok<Option<Object>>>());
      expect(out.unwrap(), isA<None>());
    });
  });

  group('Option deep nesting', () {
    test('Some(Some(Some(...)))) flatMap drilldown works', () {
      const s = Some(Some(Some(Some(5))));
      final inner = s.value.value.value.value;
      expect(inner, 5);
    });

    test('Option.combine2 — all Some', () {
      final o = Option.combine2(const Some(1), const Some('a'));
      expect(o.unwrap(), (1, 'a'));
    });

    test('Option.combine2 — one None', () {
      final o = Option.combine2(const Some(1), const None<String>());
      expect(o, isA<None>());
    });

    test('Option.combine3', () {
      final o = Option.combine3(
        const Some(1),
        const Some('a'),
        const Some(2.0),
      );
      expect(o.unwrap(), (1, 'a', 2.0));
    });
  });

  group('combineOption', () {
    test('all Some returns Some(list)', () {
      final out = combineOption<int>([
        const Some(1),
        const Some(2),
        const Some(3),
      ]);
      expect(out.unwrap(), [1, 2, 3]);
    });

    test('any None returns None', () {
      final out = combineOption<int>([
        const Some(1),
        const None(),
        const Some(3),
      ]);
      expect(out, isA<None>());
    });

    test('empty iterable returns Some(empty list)', () {
      final out = combineOption<int>(const []);
      expect(out.unwrap(), <int>[]);
    });

    test('handles single-pass generator', () {
      Iterable<Option<int>> g() sync* {
        yield const Some(1);
        yield const Some(2);
      }

      expect(combineOption(g()).unwrap(), [1, 2]);
    });
  });
}
