import 'package:df_safer_dart/df_safer_dart.dart';
import 'package:test/test.dart';

void main() {
  group('flatten_none_ext', () {
    test('flatten on None<None<T>> collapses to None<T>', () {
      const nested = None<None<int>>();
      final flat = nested.flatten();
      expect(flat, isA<None<int>>());
    });

    test('flatten on None<None<None<T>>> collapses three layers', () {
      const nested = None<None<None<int>>>();
      final flat = nested.flatten();
      expect(flat, isA<None<int>>());
    });
  });
}
