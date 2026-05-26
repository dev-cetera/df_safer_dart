import 'package:df_safer_dart/df_safer_dart.dart';
import 'package:test/test.dart';

void main() {
  group('shortcuts', () {
    test('OK_UNIT is a const Ok wrapping the Unit singleton', () {
      expect(OK_UNIT, isA<Ok<Unit>>());
      expect(OK_UNIT.value, same(UNIT));
      expect(identical(OK_UNIT, OK_UNIT), isTrue);
    });

    test('SOME_UNIT is a const Some wrapping the Unit singleton', () {
      expect(SOME_UNIT, isA<Some<Unit>>());
      expect(SOME_UNIT.value, same(UNIT));
      expect(identical(SOME_UNIT, SOME_UNIT), isTrue);
    });

    test('NONE_UNIT is a const None<Unit>', () {
      expect(NONE_UNIT, isA<None<Unit>>());
      expect(identical(NONE_UNIT, NONE_UNIT), isTrue);
    });

    test('syncUnit() returns Sync<Unit> resolving to Ok(Unit.instance)', () {
      final s = syncUnit();
      expect(s, isA<Sync<Unit>>());
      final r = s.value;
      expect(r.isOk(), isTrue);
      expect(r.unwrap(), same(UNIT));
    });

    test('syncNone<T>() returns Sync<None<T>> resolving to Ok(None)', () {
      final s = syncNone<int>();
      expect(s, isA<Sync<None<int>>>());
      final r = s.value;
      expect(r.isOk(), isTrue);
      expect(r.unwrap(), isA<None<int>>());
    });

    test(
        'syncSome<T>(value) returns Sync<Some<T>> resolving to Ok(Some(value))',
        () {
      final s = syncSome<int>(42);
      expect(s, isA<Sync<Some<int>>>());
      final r = s.value;
      expect(r.isOk(), isTrue);
      final inner = r.unwrap();
      expect(inner, isA<Some<int>>());
      expect(inner.value, 42);
    });

    test('asyncUnit() returns Async<Unit> resolving to Ok(Unit.instance)',
        () async {
      final a = asyncUnit();
      expect(a, isA<Async<Unit>>());
      final r = await a.value;
      expect(r.isOk(), isTrue);
      expect(r.unwrap(), same(UNIT));
    });

    test('asyncNone<T>() returns Async<None<T>> resolving to Ok(None)',
        () async {
      final a = asyncNone<int>();
      expect(a, isA<Async<None<int>>>());
      final r = await a.value;
      expect(r.isOk(), isTrue);
      expect(r.unwrap(), isA<None<int>>());
    });

    test(
        'asyncSome<T>(value) returns Async<Some<T>> resolving to Ok(Some(value))',
        () async {
      final a = asyncSome<int>(7);
      expect(a, isA<Async<Some<int>>>());
      final r = await a.value;
      expect(r.isOk(), isTrue);
      final inner = r.unwrap();
      expect(inner, isA<Some<int>>());
      expect(inner.value, 7);
    });

    test('asyncSome<T>(FutureOr) awaits a Future input', () async {
      final a = asyncSome<int>(Future<int>.value(99));
      final r = await a.value;
      expect(r.isOk(), isTrue);
      expect(r.unwrap().value, 99);
    });

    test('resolvableNone<T>() returns a Resolvable<None<T>> Sync variant', () {
      final r = resolvableNone<int>();
      expect(r, isA<Resolvable<None<int>>>());
      expect(r, isA<Sync<None<int>>>());
      final inner = (r as Sync<None<int>>).value;
      expect(inner.unwrap(), isA<None<int>>());
    });

    test('resolvableSome<T>(value) returns a Resolvable<Some<T>> Sync variant',
        () {
      final r = resolvableSome<int>(5);
      expect(r, isA<Resolvable<Some<int>>>());
      expect(r, isA<Sync<Some<int>>>());
      final inner = (r as Sync<Some<int>>).value.unwrap();
      expect(inner, isA<Some<int>>());
      expect(inner.value, 5);
    });

    test('resolvableUnit() returns a Resolvable<Unit> Sync variant', () {
      final r = resolvableUnit();
      expect(r, isA<Resolvable<Unit>>());
      expect(r, isA<Sync<Unit>>());
      expect((r as Sync<Unit>).value.unwrap(), same(UNIT));
    });
  });
}
