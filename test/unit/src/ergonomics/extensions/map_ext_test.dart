import 'package:df_safer_dart/df_safer_dart.dart';
import 'package:test/test.dart';

void main() {
  group('map_ext', () {
    group('MapExt.noneIfEmpty', () {
      test('non-empty map returns Some(this)', () {
        final m = {'a': 1};
        final out = m.noneIfEmpty;
        expect(out, isA<Some<Map<String, int>>>());
        expect(identical(out.unwrap(), m), isTrue);
      });

      test('empty map returns None', () {
        expect(<String, int>{}.noneIfEmpty, isA<None<Map<String, int>>>());
      });
    });

    group('MapExt.getOption', () {
      test('present key returns Some', () {
        final out = {'a': 1, 'b': 2}.getOption('a');
        expect(out, isA<Some<int>>());
        expect(out.unwrap(), 1);
      });

      test('missing key returns None', () {
        expect({'a': 1}.getOption('z'), isA<None<int>>());
      });
    });

    group('MapOfOptions', () {
      final source = <String, Option<int>>{
        'a': const Some(1),
        'b': const None(),
        'c': const Some(3),
      };

      test('whereSome keeps only Some entries', () {
        final out = source.whereSome();
        expect(out.keys.toSet(), {'a', 'c'});
        expect(out.values.every((v) => v is Some<int>), isTrue);
      });

      test('whereNone keeps only None entries', () {
        final out = source.whereNone();
        expect(out.keys.toSet(), {'b'});
        expect(out.values.every((v) => v is None<int>), isTrue);
      });

      test('someValues unwraps Some values', () {
        expect(source.someValues, {'a': 1, 'c': 3});
      });

      test('sequence returns Some(map) when all values are Some', () {
        final allSome = <String, Option<int>>{
          'a': const Some(1),
          'b': const Some(2),
        };
        final out = allSome.sequence();
        expect(out, isA<Some<Map<String, int>>>());
        expect(out.unwrap(), {'a': 1, 'b': 2});
      });

      test('sequence returns None when any value is None', () {
        expect(source.sequence(), isA<None<Map<String, int>>>());
      });

      test('partition splits some/none in one pass', () {
        final result = source.partition();
        expect(result.someParts, {'a': 1, 'c': 3});
        expect(result.noneKeys, ['b']);
      });
    });

    group('MapOfResults', () {
      final source = <String, Result<int>>{
        'a': const Ok(1),
        'b': Err('boom'),
        'c': const Ok(3),
      };

      test('whereOk keeps only Ok entries', () {
        final out = source.whereOk();
        expect(out.keys.toSet(), {'a', 'c'});
        expect(out.values.every((v) => v is Ok<int>), isTrue);
      });

      test('whereErr keeps only Err entries', () {
        final out = source.whereErr();
        expect(out.keys.toSet(), {'b'});
        expect(out.values.every((v) => v is Err<int>), isTrue);
      });

      test('okValues unwraps Ok values', () {
        expect(source.okValues, {'a': 1, 'c': 3});
      });

      test('sequence returns Ok(map) when all values are Ok', () {
        final allOk = <String, Result<int>>{
          'a': const Ok(1),
          'b': const Ok(2),
        };
        final out = allOk.sequence();
        expect(out, isA<Ok<Map<String, int>>>());
        expect(out.unwrap(), {'a': 1, 'b': 2});
      });

      test('sequence returns the first Err on failure', () {
        final out = source.sequence();
        expect(out, isA<Err<Map<String, int>>>());
        expect((out as Err<Map<String, int>>).error, 'boom');
      });

      test('partition splits ok/err in one pass', () {
        final result = source.partition();
        expect(result.okParts, {'a': 1, 'c': 3});
        expect(result.errParts.keys.toSet(), {'b'});
        expect(result.errParts['b'], isA<Err<int>>());
      });
    });
  });
}
