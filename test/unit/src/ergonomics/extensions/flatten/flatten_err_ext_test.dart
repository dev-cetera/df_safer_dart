import 'package:df_safer_dart/df_safer_dart.dart';
import 'package:test/test.dart';

void main() {
  group('flatten_err_ext', () {
    test('flatten on Err<Err<T>> collapses to a single Err<T>', () {
      final inner = Err<int>('inner-fail', statusCode: 503);
      final nested = Err<Err<int>>(inner);
      final flat = nested.flatten();
      expect(flat, isA<Err<int>>());
    });

    test('flatten on Err<Err<T>> preserves the outer Err error value', () {
      final inner = Err<int>('inner-fail');
      final nested = Err<Err<int>>(inner, statusCode: 404);
      final flat = nested.flatten();
      expect(flat, isA<Err<int>>());
      expect(flat.statusCode.unwrapOr(0), 404);
    });

    test('flatten on Err<Err<Err<T>>> collapses three layers', () {
      final inner = Err<int>('deepest');
      final mid = Err<Err<int>>(inner);
      final outer = Err<Err<Err<int>>>(mid);
      final flat = outer.flatten();
      expect(flat, isA<Err<int>>());
    });
  });
}
