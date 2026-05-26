import 'package:df_safer_dart/df_safer_dart.dart';
import 'package:test/test.dart';

void main() {
  group('flatten_sync_ext', () {
    test('flatten on Sync<Sync<T>> with Ok inner unwraps to inner value', () {
      final inner = Sync<int>.okValue(42);
      final nested = Sync<Sync<int>>.okValue(inner);
      final flat = nested.flatten();
      expect(flat, isA<Sync<int>>());
      final r = flat.value;
      expect(r, isA<Ok<int>>());
      expect(r.unwrap(), 42);
    });

    test('flatten on Sync<Sync<T>> with inner Err propagates the inner Sync',
        () {
      final inner = Sync<int>.errValue('inner-fail');
      final nested = Sync<Sync<int>>.okValue(inner);
      final flat = nested.flatten();
      final r = flat.value;
      expect(r, isA<Err<int>>());
    });

    test('flatten on Sync<Sync<T>> with outer Err returns Sync.err', () {
      final nested = Sync<Sync<int>>.errValue('outer-fail');
      final flat = nested.flatten();
      expect(flat, isA<Sync<int>>());
      final r = flat.value;
      expect(r, isA<Err<int>>());
    });

    test('flatten on Sync<Sync<Sync<T>>> collapses three layers', () {
      final lvl0 = Sync<int>.okValue(3);
      final lvl1 = Sync<Sync<int>>.okValue(lvl0);
      final lvl2 = Sync<Sync<Sync<int>>>.okValue(lvl1);
      final flat = lvl2.flatten();
      expect(flat, isA<Sync<int>>());
      final r = flat.value;
      expect(r.unwrap(), 3);
    });
  });
}
