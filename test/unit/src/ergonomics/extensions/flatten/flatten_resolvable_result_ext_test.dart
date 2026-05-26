import 'package:df_safer_dart/df_safer_dart.dart';
import 'package:test/test.dart';

void main() {
  group('flatten_resolvable_result_ext', () {
    test('Sync<Result<T>> with Ok(Ok(v)) flattens to Sync<Ok(v)>', () async {
      final Resolvable<Result<int>> nested =
          Sync<Result<int>>.okValue(const Ok<int>(42));
      final flat = nested.flatten();
      expect(flat, isA<Resolvable<int>>());
      final r = await flat.value;
      expect(r, isA<Ok<int>>());
      expect(r.unwrap(), 42);
    });

    test('Sync<Result<T>> with Ok(Err) flattens to Err', () async {
      final Resolvable<Result<int>> nested =
          Sync<Result<int>>.okValue(Err<int>('inner-fail'));
      final flat = nested.flatten();
      final r = await flat.value;
      expect(r, isA<Err<int>>());
    });

    test('Sync<Result<T>> with outer Err propagates Err', () async {
      final Resolvable<Result<int>> nested =
          Sync<Result<int>>.errValue('outer-fail');
      final flat = nested.flatten();
      final r = await flat.value;
      expect(r, isA<Err<int>>());
    });

    test('Async<Result<T>> with Ok(Ok(v)) flattens asynchronously', () async {
      final Resolvable<Result<int>> nested =
          Async<Result<int>>.okValue(const Ok<int>(11));
      final flat = nested.flatten();
      final r = await flat.value;
      expect(r, isA<Ok<int>>());
      expect(r.unwrap(), 11);
    });

    test('Async<Result<T>> with Ok(Err) flattens to Err', () async {
      final Resolvable<Result<int>> nested =
          Async<Result<int>>.okValue(Err<int>('inner-async-fail'));
      final flat = nested.flatten();
      final r = await flat.value;
      expect(r, isA<Err<int>>());
    });

    test('Resolvable<Result<Result<T>>> collapses three layers', () async {
      final Resolvable<Result<Result<int>>> nested =
          Sync<Result<Result<int>>>.okValue(
        const Ok<Result<int>>(Ok<int>(7)),
      );
      final flat = nested.flatten();
      final r = await flat.value;
      expect(r.unwrap(), 7);
    });
  });
}
