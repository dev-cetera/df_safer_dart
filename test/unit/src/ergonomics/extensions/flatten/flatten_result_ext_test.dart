import 'package:df_safer_dart/df_safer_dart.dart';
import 'package:test/test.dart';

void main() {
  group('flatten_result_ext', () {
    test('flatten on Ok(Ok(v)) collapses to Ok(v)', () {
      const Result<Result<int>> nested = Ok<Result<int>>(Ok<int>(42));
      final flat = nested.flatten();
      expect(flat, isA<Ok<int>>());
      expect(flat.unwrap(), 42);
    });

    test('flatten on Ok(Err) collapses to Err', () {
      final Result<Result<int>> nested =
          Ok<Result<int>>(Err<int>('inner-fail'));
      final flat = nested.flatten();
      expect(flat, isA<Err<int>>());
    });

    test('flatten on outer Err collapses to Err', () {
      final Result<Result<int>> nested = Err<Result<int>>('outer-fail');
      final flat = nested.flatten();
      expect(flat, isA<Err<int>>());
    });

    test('flatten on Result<Result<Result<T>>> collapses three layers', () {
      const Result<Result<Result<int>>> nested =
          Ok<Result<Result<int>>>(Ok<Result<int>>(Ok<int>(9)));
      final flat = nested.flatten();
      expect(flat, isA<Ok<int>>());
      expect(flat.unwrap(), 9);
    });
  });
}
