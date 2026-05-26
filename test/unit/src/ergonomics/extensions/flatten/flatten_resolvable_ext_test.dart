import 'package:df_safer_dart/df_safer_dart.dart';
import 'package:test/test.dart';

void main() {
  group('flatten_resolvable_ext', () {
    test('Sync(Ok(Sync<int>)) flattens to Sync<int> preserving Ok value',
        () async {
      final inner = Sync<int>.okValue(42);
      final Resolvable<Resolvable<int>> nested =
          Sync<Resolvable<int>>.okValue(inner);
      final flat = nested.flatten();
      expect(flat, isA<Resolvable<int>>());
      final r = await flat.value;
      expect(r, isA<Ok<int>>());
      expect(r.unwrap(), 42);
    });

    test('Sync outer Err propagates to Sync.err result', () async {
      final Resolvable<Resolvable<int>> nested =
          Sync<Resolvable<int>>.errValue('outer-fail');
      final flat = nested.flatten();
      final r = await flat.value;
      expect(r, isA<Err<int>>());
    });

    test('Async outer with Ok(inner Async) flattens to Async value', () async {
      final inner = Async<int>.okValue(11);
      final Resolvable<Resolvable<int>> nested =
          Async<Resolvable<int>>.okValue(inner);
      final flat = nested.flatten();
      final r = await flat.value;
      expect(r.unwrap(), 11);
    });

    test('Async outer Err propagates Err', () async {
      final Resolvable<Resolvable<int>> nested =
          Async<Resolvable<int>>.errValue(
        (error: 'outer-async-fail', statusCode: null),
      );
      final flat = nested.flatten();
      final r = await flat.value;
      expect(r, isA<Err<int>>());
    });

    test('Resolvable<Resolvable<Resolvable<T>>> collapses three layers',
        () async {
      final lvl0 = Sync<int>.okValue(3);
      final Resolvable<Resolvable<int>> lvl1 =
          Sync<Resolvable<int>>.okValue(lvl0);
      final Resolvable<Resolvable<Resolvable<int>>> lvl2 =
          Sync<Resolvable<Resolvable<int>>>.okValue(lvl1);
      final flat = lvl2.flatten();
      final r = await flat.value;
      expect(r.unwrap(), 3);
    });
  });
}
