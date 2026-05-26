import 'package:df_safer_dart/df_safer_dart.dart';
import 'package:test/test.dart';

void main() {
  group('flatten_async_ext', () {
    test('flatten on Async<Async<T>> with Ok inner unwraps to inner value',
        () async {
      final inner = Async<int>.okValue(42);
      final nested = Async<Async<int>>.okValue(inner);
      final flat = nested.flatten();
      expect(flat, isA<Async<int>>());
      final r = await flat.value;
      expect(r, isA<Ok<int>>());
      expect(r.unwrap(), 42);
    });

    test('flatten on Async<Async<T>> with inner Err propagates Err', () async {
      final inner = Async<int>.errValue((error: 'inner-fail', statusCode: 500));
      final nested = Async<Async<int>>.okValue(inner);
      final flat = nested.flatten();
      final r = await flat.value;
      expect(r, isA<Err<int>>());
    });

    test('flatten on Async<Async<T>> with outer Err propagates Err', () async {
      final nested = Async<Async<int>>.errValue(
        (error: 'outer-fail', statusCode: null),
      );
      final flat = nested.flatten();
      final r = await flat.value;
      expect(r, isA<Err<int>>());
    });

    test('flatten on Async<Async<Async<T>>> collapses three layers', () async {
      final lvl0 = Async<int>.okValue(7);
      final lvl1 = Async<Async<int>>.okValue(lvl0);
      final lvl2 = Async<Async<Async<int>>>.okValue(lvl1);
      final flat = lvl2.flatten();
      expect(flat, isA<Async<int>>());
      final r = await flat.value;
      expect(r.unwrap(), 7);
    });
  });
}
