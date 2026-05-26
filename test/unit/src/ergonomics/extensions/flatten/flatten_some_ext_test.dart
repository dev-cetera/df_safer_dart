import 'package:df_safer_dart/df_safer_dart.dart';
import 'package:test/test.dart';

void main() {
  group('flatten_some_ext', () {
    test('flatten on Some<Some<T>> collapses to inner Some<T>', () {
      const inner = Some<int>(42);
      const nested = Some<Some<int>>(inner);
      final flat = nested.flatten();
      expect(flat, isA<Some<int>>());
      expect(flat.unwrap(), 42);
      expect(identical(flat, inner), isTrue);
    });

    test('flatten on Some<Some<Some<T>>> collapses three layers to inner-most',
        () {
      const inner = Some<int>(7);
      const mid = Some<Some<int>>(inner);
      const outer = Some<Some<Some<int>>>(mid);
      final flat = outer.flatten();
      expect(flat, isA<Some<int>>());
      expect(flat.unwrap(), 7);
    });
  });
}
