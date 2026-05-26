import 'package:df_safer_dart/df_safer_dart.dart';
import 'package:test/test.dart';

void main() {
  group('flatten_option_ext', () {
    test('flatten on Some(Some(v)) collapses to Some(v)', () {
      const Option<Option<int>> nested = Some<Option<int>>(Some<int>(5));
      final flat = nested.flatten();
      expect(flat, isA<Some<int>>());
      expect(flat.unwrap(), 5);
    });

    test('flatten on Some(None) collapses to None', () {
      const Option<Option<int>> nested = Some<Option<int>>(None<int>());
      final flat = nested.flatten();
      expect(flat, isA<None<int>>());
    });

    test('flatten on None outer collapses to None', () {
      const Option<Option<int>> nested = None<Option<int>>();
      final flat = nested.flatten();
      expect(flat, isA<None<int>>());
    });

    test('flatten on Option<Option<Option<T>>> collapses three layers', () {
      const Option<Option<Option<int>>> nested =
          Some<Option<Option<int>>>(Some<Option<int>>(Some<int>(9)));
      final flat = nested.flatten();
      expect(flat, isA<Some<int>>());
      expect(flat.unwrap(), 9);
    });
  });
}
