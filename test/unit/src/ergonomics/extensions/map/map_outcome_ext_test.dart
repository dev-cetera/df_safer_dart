import 'package:df_safer_dart/df_safer_dart.dart';
import 'package:test/test.dart';

void main() {
  group('map_outcome_ext', () {
    group('MapOutcomeExt2.map2', () {
      test('maps deepest value and flattens 2-deep Some chain', () async {
        final Outcome<Outcome<Object>> nested = Some(const Some(2));
        final reduced = nested.map2<int, int>((e) => e * 10);
        final result = await reduced.value;
        expect(result, isA<Ok<Option<Object>>>());
        expect(result.unwrap().unwrap(), 20);
      });

      test('None at any layer collapses to None after reduce', () async {
        final Outcome<Outcome<Object>> nested =
            Some(const None<Object>());
        final reduced = nested.map2<int, int>((e) => e * 10);
        final result = await reduced.value;
        expect(result.unwrap(), isA<None<Object>>());
      });
    });

    group('MapOutcomeExt3.map3', () {
      test('maps deepest value and flattens 3-deep chain', () async {
        final Outcome<Outcome<Outcome<Object>>> nested =
            Some(Some(const Some(3)));
        final reduced = nested.map3<int, int>((e) => e + 1);
        final result = await reduced.value;
        expect(result.unwrap().unwrap(), 4);
      });

      test('Err at any layer propagates', () async {
        final Outcome<Outcome<Outcome<Object>>> nested =
            Some(Some(Err<Object>('boom')));
        final reduced = nested.map3<int, int>((e) => e + 1);
        final result = await reduced.value;
        expect(result, isA<Err<Option<Object>>>());
      });
    });

    group('MapOutcomeExt4.map4', () {
      test('maps deepest value and flattens 4-deep chain', () async {
        final Outcome<Outcome<Outcome<Outcome<Object>>>> nested =
            Some(Some(Some(const Some(4))));
        final reduced = nested.map4<int, int>((e) => e * 2);
        final result = await reduced.value;
        expect(result.unwrap().unwrap(), 8);
      });

      test('None at the deepest layer collapses to None', () async {
        final Outcome<Outcome<Outcome<Outcome<Object>>>> nested =
            Some(Some(Some(const None<Object>())));
        final reduced = nested.map4<int, int>((e) => e * 2);
        final result = await reduced.value;
        expect(result.unwrap(), isA<None<Object>>());
      });
    });

    group('MapOutcomeExt5.map5', () {
      test('maps deepest value and flattens 5-deep chain', () async {
        final Outcome<Outcome<Outcome<Outcome<Outcome<Object>>>>> nested =
            Some(Some(Some(Some(const Some(5)))));
        final reduced = nested.map5<int, int>((e) => e + 100);
        final result = await reduced.value;
        expect(result.unwrap().unwrap(), 105);
      });

      test('None at the deepest layer collapses to None', () async {
        final Outcome<Outcome<Outcome<Outcome<Outcome<Object>>>>> nested =
            Some(Some(Some(Some(const None<Object>()))));
        final reduced = nested.map5<int, int>((e) => e + 100);
        final result = await reduced.value;
        expect(result.unwrap(), isA<None<Object>>());
      });
    });

    group('MapOutcomeExt6.map6', () {
      test('maps deepest value and flattens 6-deep chain', () async {
        final Outcome<Outcome<Outcome<Outcome<Outcome<Outcome<Object>>>>>>
            nested = Some(Some(Some(Some(Some(const Some(6))))));
        final reduced = nested.map6<int, int>((e) => e);
        final result = await reduced.value;
        expect(result.unwrap().unwrap(), 6);
      });

      test('None at the deepest layer collapses to None', () async {
        final Outcome<Outcome<Outcome<Outcome<Outcome<Outcome<Object>>>>>>
            nested = Some(Some(Some(Some(Some(const None<Object>())))));
        final reduced = nested.map6<int, int>((e) => e);
        final result = await reduced.value;
        expect(result.unwrap(), isA<None<Object>>());
      });
    });

    group('MapOutcomeExt7.map7', () {
      test('maps deepest value and flattens 7-deep chain', () async {
        final Outcome<
            Outcome<
                Outcome<
                    Outcome<
                        Outcome<Outcome<Outcome<Object>>>>>>> nested =
            Some(Some(Some(Some(Some(Some(const Some(7)))))));
        final reduced = nested.map7<int, int>((e) => e * 3);
        final result = await reduced.value;
        expect(result.unwrap().unwrap(), 21);
      });

      test('None at the deepest layer collapses to None', () async {
        final Outcome<
            Outcome<
                Outcome<
                    Outcome<
                        Outcome<Outcome<Outcome<Object>>>>>>> nested =
            Some(Some(Some(Some(Some(Some(const None<Object>()))))));
        final reduced = nested.map7<int, int>((e) => e * 3);
        final result = await reduced.value;
        expect(result.unwrap(), isA<None<Object>>());
      });
    });

    group('MapOutcomeExt8.map8', () {
      test('maps deepest value and flattens 8-deep chain', () async {
        final Outcome<
            Outcome<
                Outcome<
                    Outcome<
                        Outcome<
                            Outcome<Outcome<Outcome<Object>>>>>>>> nested =
            Some(Some(Some(Some(Some(Some(Some(const Some(8))))))));
        final reduced = nested.map8<int, int>((e) => e - 1);
        final result = await reduced.value;
        expect(result.unwrap().unwrap(), 7);
      });

      test('None at the deepest layer collapses to None', () async {
        final Outcome<
            Outcome<
                Outcome<
                    Outcome<
                        Outcome<
                            Outcome<Outcome<Outcome<Object>>>>>>>> nested =
            Some(Some(Some(Some(Some(Some(Some(const None<Object>())))))));
        final reduced = nested.map8<int, int>((e) => e - 1);
        final result = await reduced.value;
        expect(result.unwrap(), isA<None<Object>>());
      });
    });

    group('MapOutcomeExt9.map9', () {
      test('maps deepest value and flattens 9-deep chain', () async {
        final Outcome<
            Outcome<
                Outcome<
                    Outcome<
                        Outcome<
                            Outcome<
                                Outcome<
                                    Outcome<Outcome<Object>>>>>>>>> nested =
            Some(Some(Some(Some(Some(Some(Some(Some(const Some(9)))))))));
        final reduced = nested.map9<int, int>((e) => e + 1);
        final result = await reduced.value;
        expect(result.unwrap().unwrap(), 10);
      });

      test('None at the deepest layer collapses to None', () async {
        final Outcome<
            Outcome<
                Outcome<
                    Outcome<
                        Outcome<
                            Outcome<
                                Outcome<
                                    Outcome<Outcome<Object>>>>>>>>> nested =
            Some(
          Some(Some(Some(Some(Some(Some(Some(const None<Object>()))))))),
        );
        final reduced = nested.map9<int, int>((e) => e + 1);
        final result = await reduced.value;
        expect(result.unwrap(), isA<None<Object>>());
      });
    });

    group('MapOutcomeExt10.map10', () {
      test('maps deepest value and flattens 10-deep chain', () async {
        final Outcome<
            Outcome<
                Outcome<
                    Outcome<
                        Outcome<
                            Outcome<
                                Outcome<
                                    Outcome<
                                        Outcome<
                                            Outcome<Object>>>>>>>>>> nested =
            Some(
          Some(
            Some(Some(Some(Some(Some(Some(Some(const Some(10))))))),),
          ),
        );
        final reduced = nested.map10<int, int>((e) => e * e);
        final result = await reduced.value;
        expect(result.unwrap().unwrap(), 100);
      });

      test('None at the deepest layer collapses to None', () async {
        final Outcome<
            Outcome<
                Outcome<
                    Outcome<
                        Outcome<
                            Outcome<
                                Outcome<
                                    Outcome<
                                        Outcome<
                                            Outcome<Object>>>>>>>>>> nested =
            Some(
          Some(
            Some(
              Some(Some(Some(Some(Some(Some(const None<Object>())))))),
            ),
          ),
        );
        final reduced = nested.map10<int, int>((e) => e * e);
        final result = await reduced.value;
        expect(result.unwrap(), isA<None<Object>>());
      });
    });
  });
}
