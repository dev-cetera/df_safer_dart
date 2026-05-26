import 'package:df_safer_dart/df_safer_dart.dart';
import 'package:test/test.dart';

void main() {
  group('to_unit_on_outcome_ext', () {
    // Void receivers.

    test('ToUnitOnVoidOutcome.toUnit returns Outcome<Unit> with Unit value', () {
      final Outcome<void> outcome = const Some<int>(1);
      final result = outcome.toUnit();
      expect(result, isA<Outcome<Unit>>());
      expect(result.unwrap(), same(Unit.instance));
    });

    test('ToUnitOnVoidOption.toUnit returns Option<Unit> with Unit value', () {
      final Option<void> option = const Some<int>(2);
      final result = option.toUnit();
      expect(result, isA<Option<Unit>>());
      expect(result.unwrap(), same(Unit.instance));
    });

    test('ToUnitOnVoidSome.toUnit returns Some<Unit> with Unit value', () {
      final Some<void> some = const Some<int>(3);
      final result = some.toUnit();
      expect(result, isA<Some<Unit>>());
      expect(result.value, same(Unit.instance));
    });

    test('ToUnitOnVoidNone.toUnit returns None<Unit>', () {
      final None<void> none = const None<int>();
      final result = none.toUnit();
      expect(result, isA<None<Unit>>());
    });

    test(
      'ToUnitOnVoidResolvable.toUnit returns Resolvable<Unit> with Unit value',
      () async {
        final Resolvable<void> resolvable = Sync<int>.okValue(4);
        final result = resolvable.toUnit();
        expect(result, isA<Resolvable<Unit>>());
        final settled = await result.toAsync().value;
        expect(settled.unwrap(), same(Unit.instance));
      },
    );

    test('ToUnitOnVoidSync.toUnit returns Sync<Unit> with Unit value', () {
      final Sync<void> sync = Sync<int>.okValue(5);
      final result = sync.toUnit();
      expect(result, isA<Sync<Unit>>());
      expect(result.value.unwrap(), same(Unit.instance));
    });

    test(
      'ToUnitOnVoidAsync.toUnit returns Async<Unit> with Unit value',
      () async {
        final Async<void> async_ = Async<int>.okValue(6);
        final result = async_.toUnit();
        expect(result, isA<Async<Unit>>());
        final settled = await result.value;
        expect(settled.unwrap(), same(Unit.instance));
      },
    );

    test('ToUnitOnVoidResult.toUnit returns Result<Unit> with Unit value', () {
      final Result<void> result = const Ok<int>(7);
      final unitResult = result.toUnit();
      expect(unitResult, isA<Result<Unit>>());
      expect(unitResult.unwrap(), same(Unit.instance));
    });

    test('ToUnitOnVoidOk.toUnit returns Result<Unit> with Unit value', () {
      final Ok<void> ok = const Ok<int>(8);
      final result = ok.toUnit();
      expect(result, isA<Result<Unit>>());
      expect(result.unwrap(), same(Unit.instance));
    });

    test('ToUnitOnVoidErr.toUnit returns Err<Unit> preserving the error', () {
      final Err<void> err = Err<int>('boom-void');
      final result = err.toUnit();
      expect(result, isA<Err<Unit>>());
      expect(result.error, 'boom-void');
    });

    // Object receivers.

    test(
      'ToUnitOnObjectOutcome.toUnit returns Outcome<Unit> with Unit value',
      () {
        final Outcome<Object> outcome = const Some<int>(11);
        final result = outcome.toUnit();
        expect(result, isA<Outcome<Unit>>());
        expect(result.unwrap(), same(Unit.instance));
      },
    );

    test(
      'ToUnitOnObjectOption.toUnit returns Option<Unit> with Unit value',
      () {
        final Option<Object> option = const Some<int>(12);
        final result = option.toUnit();
        expect(result, isA<Option<Unit>>());
        expect(result.unwrap(), same(Unit.instance));
      },
    );

    test('ToUnitOnObjectSome.toUnit returns Some<Unit> with Unit value', () {
      final Some<Object> some = const Some<int>(13);
      final result = some.toUnit();
      expect(result, isA<Some<Unit>>());
      expect(result.value, same(Unit.instance));
    });

    test('ToUnitOnObjectNone.toUnit returns None<Unit>', () {
      final None<Object> none = const None<int>();
      final result = none.toUnit();
      expect(result, isA<None<Unit>>());
    });

    test(
      'ToUnitOnObjectResolvable.toUnit returns Resolvable<Unit> with Unit value',
      () async {
        final Resolvable<Object> resolvable = Sync<int>.okValue(14);
        final result = resolvable.toUnit();
        expect(result, isA<Resolvable<Unit>>());
        final settled = await result.toAsync().value;
        expect(settled.unwrap(), same(Unit.instance));
      },
    );

    test('ToUnitOnObjectSync.toUnit returns Sync<Unit> with Unit value', () {
      final Sync<Object> sync = Sync<int>.okValue(15);
      final result = sync.toUnit();
      expect(result, isA<Sync<Unit>>());
      expect(result.value.unwrap(), same(Unit.instance));
    });

    test(
      'ToUnitOnObjectAsync.toUnit returns Async<Unit> with Unit value',
      () async {
        final Async<Object> async_ = Async<int>.okValue(16);
        final result = async_.toUnit();
        expect(result, isA<Async<Unit>>());
        final settled = await result.value;
        expect(settled.unwrap(), same(Unit.instance));
      },
    );

    test(
      'ToUnitOnObjectResult.toUnit returns Result<Unit> with Unit value',
      () {
        final Result<Object> result = const Ok<int>(17);
        final unitResult = result.toUnit();
        expect(unitResult, isA<Result<Unit>>());
        expect(unitResult.unwrap(), same(Unit.instance));
      },
    );

    test('ToUnitOnObjectOk.toUnit returns Result<Unit> with Unit value', () {
      final Ok<Object> ok = const Ok<int>(18);
      final result = ok.toUnit();
      expect(result, isA<Result<Unit>>());
      expect(result.unwrap(), same(Unit.instance));
    });

    test('ToUnitOnObjectErr.toUnit returns Err<Unit> preserving the error', () {
      final Err<Object> err = Err<int>('boom-object');
      final result = err.toUnit();
      expect(result, isA<Err<Unit>>());
      expect(result.error, 'boom-object');
    });
  });
}
