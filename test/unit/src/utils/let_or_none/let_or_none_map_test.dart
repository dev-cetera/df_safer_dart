import 'package:df_safer_dart/df_safer_dart.dart';
import 'package:test/test.dart';

void main() {
  group('let_or_none_map', () {
    test('letMapOrNone returns Some for a matching Map input', () {
      final r = letMapOrNone<String, int>(<String, int>{'a': 1, 'b': 2});
      expect(r.isSome(), isTrue);
      final m = r.unwrap();
      expect(m.length, 2);
      expect(m['a']!.unwrap(), 1);
      expect(m['b']!.unwrap(), 2);
    });

    test('letMapOrNone returns Some(empty) for an empty Map', () {
      final r = letMapOrNone<String, int>(<String, int>{});
      expect(r.isSome(), isTrue);
      expect(r.unwrap(), isEmpty);
    });

    test('letMapOrNone returns None when a key fails to convert', () {
      // Caller asks for Map<int, int>, but the source has a String key — the
      // helper bails on the first non-convertible key.
      final r = letMapOrNone<int, int>(<dynamic, dynamic>{'a': 1});
      expect(r, isA<None<Map<int, Option<int>>>>());
    });

    test('letMapOrNone yields None values for non-convertible values', () {
      final r = letMapOrNone<String, int>(<dynamic, dynamic>{
        'good': 1,
        'bad': 'not-an-int-string',
      });
      // Per implementation: a failed value becomes None inside the map; the
      // map itself is still Some.
      expect(r.isSome(), isTrue);
      final m = r.unwrap();
      expect(m['good']!.unwrap(), 1);
      expect(m['bad'], isA<None<int>>());
    });

    test('letMapOrNone parses a JSON-encoded object string', () {
      final r = letMapOrNone<String, int>('{"x":1,"y":2}');
      expect(r.isSome(), isTrue);
      final m = r.unwrap();
      expect(m['x']!.unwrap(), 1);
      expect(m['y']!.unwrap(), 2);
    });

    test('letMapOrNone returns None for malformed JSON', () {
      expect(
        letMapOrNone<String, int>('not json'),
        isA<None<Map<String, Option<int>>>>(),
      );
    });

    test('letMapOrNone returns None for null input', () {
      expect(
        letMapOrNone<String, int>(null),
        isA<None<Map<String, Option<int>>>>(),
      );
    });

    test('letMapOrNone returns None for unsupported input types', () {
      expect(
        letMapOrNone<String, int>(42),
        isA<None<Map<String, Option<int>>>>(),
      );
    });

    test('letMapOrNone unwraps an Outcome chain (Ok)', () {
      final ok = Sync<Map<String, int>>.okValue(<String, int>{'a': 1});
      final r = letMapOrNone<String, int>(ok);
      expect(r.unwrap()['a']!.unwrap(), 1);
    });

    test('letMapOrNone returns None when the Outcome is Err', () {
      final err = Sync<Map<String, int>>.err(
        Err<Map<String, int>>('bad'),
      );
      expect(
        letMapOrNone<String, int>(err),
        isA<None<Map<String, Option<int>>>>(),
      );
    });

    test('letMapOrNone trims surrounding whitespace before JSON-decoding', () {
      final r = letMapOrNone<String, int>('   {"k":9}   ');
      expect(r.unwrap()['k']!.unwrap(), 9);
    });

    test('letMapOrNone coerces convertible string keys/values into K/V', () {
      // The dispatcher routes string→int through letIntOrNone, so a JSON map
      // with string-encoded numbers should still produce Option<int> values.
      final r = letMapOrNone<String, int>('{"a":"1","b":"2"}');
      final m = r.unwrap();
      expect(m['a']!.unwrap(), 1);
      expect(m['b']!.unwrap(), 2);
    });
  });
}
