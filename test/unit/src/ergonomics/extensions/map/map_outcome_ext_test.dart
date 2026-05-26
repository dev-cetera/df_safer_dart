import 'package:df_safer_dart/df_safer_dart.dart';
import 'package:test/test.dart';

// The `mapN` extension family has an awkward signature: the extension's `T`
// can't be inferred from a generic `Outcome<Outcome<Object>>` receiver. We
// pass an `Object`-typed mapper and cast inside it — this exercises the
// public behaviour (deep nested-`Outcome` flattening) without fighting the
// inference quirk.
void main() {
  group('map_outcome_ext', () {
    group('MapOutcomeExt2.map2', () {
      test('maps deepest value and flattens 2-deep Some chain', () async {
        final Outcome<Outcome<Object>> nested = const Some(Some<Object>(2));
        final reduced = nested.map2((Object e) => (e as int) * 10);
        final result = await reduced.value;
        expect(result, isA<Ok<Option<Object>>>());
        expect(result.unwrap().unwrap(), 20);
      });

      test('None at any layer collapses to None after reduce', () async {
        final Outcome<Outcome<Object>> nested = const Some(None<Object>());
        final reduced = nested.map2((Object e) => (e as int) * 10);
        final result = await reduced.value;
        expect(result.unwrap(), isA<None<Object>>());
      });
    });

    group('MapOutcomeExt3.map3', () {
      test('maps deepest value and flattens 3-deep chain', () async {
        final Outcome<Outcome<Outcome<Object>>> nested =
            const Some(Some(Some<Object>(3)));
        final reduced = nested.map3((Object e) => (e as int) + 1);
        final result = await reduced.value;
        expect(result.unwrap().unwrap(), 4);
      });

      test('Err at any layer propagates', () async {
        final Outcome<Outcome<Outcome<Object>>> nested =
            Some(Some(Err<Object>('boom')));
        final reduced = nested.map3((Object e) => (e as int) + 1);
        final result = await reduced.value;
        expect(result, isA<Err<Option<Object>>>());
      });
    });

    group('MapOutcomeExt4.map4', () {
      test('maps deepest value and flattens 4-deep chain', () async {
        final Outcome<Outcome<Outcome<Outcome<Object>>>> nested =
            const Some(Some(Some(Some<Object>(4))));
        final reduced = nested.map4((Object e) => (e as int) * 2);
        final result = await reduced.value;
        expect(result.unwrap().unwrap(), 8);
      });

      test('None at the deepest layer collapses to None', () async {
        final Outcome<Outcome<Outcome<Outcome<Object>>>> nested =
            const Some(Some(Some(None<Object>())));
        final reduced = nested.map4((Object e) => (e as int) * 2);
        final result = await reduced.value;
        expect(result.unwrap(), isA<None<Object>>());
      });
    });

    group('MapOutcomeExt5.map5', () {
      test('maps deepest value and flattens 5-deep chain', () async {
        final Outcome<Outcome<Outcome<Outcome<Outcome<Object>>>>> nested =
            const Some(Some(Some(Some(Some<Object>(5)))));
        final reduced = nested.map5((Object e) => (e as int) + 100);
        final result = await reduced.value;
        expect(result.unwrap().unwrap(), 105);
      });

      test('None at the deepest layer collapses to None', () async {
        final Outcome<Outcome<Outcome<Outcome<Outcome<Object>>>>> nested =
            const Some(Some(Some(Some(None<Object>()))));
        final reduced = nested.map5((Object e) => (e as int) + 100);
        final result = await reduced.value;
        expect(result.unwrap(), isA<None<Object>>());
      });
    });

    group('MapOutcomeExt6.map6', () {
      test('maps deepest value and flattens 6-deep chain', () async {
        final Outcome<Outcome<Outcome<Outcome<Outcome<Outcome<Object>>>>>>
            nested = const Some(Some(Some(Some(Some(Some<Object>(6))))));
        final reduced = nested.map6((Object e) => e as int);
        final result = await reduced.value;
        expect(result.unwrap().unwrap(), 6);
      });

      test('None at the deepest layer collapses to None', () async {
        final Outcome<Outcome<Outcome<Outcome<Outcome<Outcome<Object>>>>>>
            nested = const Some(Some(Some(Some(Some(None<Object>())))));
        final reduced = nested.map6((Object e) => e as int);
        final result = await reduced.value;
        expect(result.unwrap(), isA<None<Object>>());
      });
    });

    group('MapOutcomeExt7.map7', () {
      test('maps deepest value and flattens 7-deep chain', () async {
        final Outcome<
                Outcome<
                    Outcome<Outcome<Outcome<Outcome<Outcome<Object>>>>>>>
            nested = const Some(Some(Some(Some(Some(Some(Some<Object>(7)))))));
        final reduced = nested.map7((Object e) => (e as int) * 3);
        final result = await reduced.value;
        expect(result.unwrap().unwrap(), 21);
      });

      test('None at the deepest layer collapses to None', () async {
        final Outcome<
                Outcome<
                    Outcome<Outcome<Outcome<Outcome<Outcome<Object>>>>>>>
            nested = const Some(Some(Some(Some(Some(Some(None<Object>()))))));
        final reduced = nested.map7((Object e) => (e as int) * 3);
        final result = await reduced.value;
        expect(result.unwrap(), isA<None<Object>>());
      });
    });

    // map8 / map9 / map10 are pure compositions of map7 by induction
    // (the source defines `mapN` as `map((e) => e.map{N-1}(...)).reduce()`).
    // Verified at one of those depths is sufficient — the smaller arities
    // above cover the recursion shape, and this single deepest test guards
    // that the full 8-layer chain compiles and resolves.
    group('MapOutcomeExt8.map8', () {
      test('maps deepest value and flattens 8-deep chain', () async {
        final Outcome<
                Outcome<
                    Outcome<
                        Outcome<
                            Outcome<
                                Outcome<Outcome<Outcome<Object>>>>>>>> nested =
            const Some(Some(Some(Some(Some(Some(Some(Some<Object>(8))))))));
        final reduced = nested.map8((Object e) => (e as int) - 1);
        final result = await reduced.value;
        expect(result.unwrap().unwrap(), 7);
      });
    });
  });
}
