import 'package:df_safer_dart/df_safer_dart.dart';
import 'package:test/test.dart';

void main() {
  group('flatten_ok_ext', () {
    test('flatten on Ok<Ok<T>> collapses to inner Ok<T>', () {
      const inner = Ok<int>(42);
      const nested = Ok<Ok<int>>(inner);
      final flat = nested.flatten();
      expect(flat, isA<Ok<int>>());
      expect(flat.unwrap(), 42);
      expect(identical(flat, inner), isTrue);
    });

    test('flatten on Ok<Ok<Ok<T>>> collapses three layers to inner-most Ok',
        () {
      const inner = Ok<int>(7);
      const mid = Ok<Ok<int>>(inner);
      const outer = Ok<Ok<Ok<int>>>(mid);
      final flat = outer.flatten();
      expect(flat, isA<Ok<int>>());
      expect(flat.unwrap(), 7);
    });
  });
}
