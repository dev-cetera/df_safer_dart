import 'package:df_safer_dart/df_safer_dart.dart';
import 'package:test/test.dart';

void main() {
  group('let_or_none_collections', () {
    test('letIterableOrNone returns Some for an Iterable input', () {
      final r = letIterableOrNone<int>([1, 2, 3]);
      expect(r.isSome(), isTrue);
      final items = r.unwrap().toList();
      expect(items.length, 3);
      expect(items[0].unwrap(), 1);
      expect(items[2].unwrap(), 3);
    });

    test('letIterableOrNone returns Some(<empty>) for empty input', () {
      final r = letIterableOrNone<int>(const <int>[]);
      expect(r.isSome(), isTrue);
      expect(r.unwrap(), isEmpty);
    });

    test(
      'letIterableOrNone yields None entries for elements that do not convert',
      () {
        final r = letIterableOrNone<int>(<dynamic>[1, 'two', 3]);
        final items = r.unwrap().toList();
        expect(items[0].unwrap(), 1);
        expect(items[1], isA<None<int>>());
        expect(items[2].unwrap(), 3);
      },
    );

    test('letIterableOrNone parses a JSON-encoded array string', () {
      final r = letIterableOrNone<int>('[1,2,3]');
      expect(r.isSome(), isTrue);
      final items = r.unwrap().toList();
      expect(items.map((e) => e.unwrap()), [1, 2, 3]);
    });

    test('letIterableOrNone returns None for null input', () {
      expect(letIterableOrNone<int>(null), isA<None<Iterable<Option<int>>>>());
    });

    test('letIterableOrNone returns None for non-iterable, non-string input',
        () {
      expect(letIterableOrNone<int>(42), isA<None<Iterable<Option<int>>>>());
    });

    test('letIterableOrNone unwraps an Outcome chain (Ok)', () {
      final ok = Sync<List<int>>.okValue(<int>[10, 20]);
      final r = letIterableOrNone<int>(ok);
      final items = r.unwrap().toList();
      expect(items.map((e) => e.unwrap()), [10, 20]);
    });

    test('letIterableOrNone returns None when the Outcome is Err', () {
      final err = Sync<List<int>>.err(Err<List<int>>('nope'));
      expect(letIterableOrNone<int>(err), isA<None<Iterable<Option<int>>>>());
    });

    test('letIterableOrNone materializes the source iterable eagerly', () {
      // Iterable.generate is single-pass-friendly but the returned iterable
      // should still be reusable because the helper calls `.toList()`.
      final r = letIterableOrNone<int>(Iterable<int>.generate(4, (i) => i));
      final items = r.unwrap();
      // Iterate twice — both must yield identical sequences.
      expect(items.map((e) => e.unwrap()).toList(), [0, 1, 2, 3]);
      expect(items.map((e) => e.unwrap()).toList(), [0, 1, 2, 3]);
    });

    test('letListOrNone returns Some<List> for an Iterable input', () {
      final r = letListOrNone<int>([1, 2, 3]);
      expect(r.isSome(), isTrue);
      expect(r.unwrap(), isA<List<Option<int>>>());
      expect(r.unwrap().map((e) => e.unwrap()).toList(), [1, 2, 3]);
    });

    test('letListOrNone returns Some(empty) for empty input', () {
      final r = letListOrNone<int>(const <int>[]);
      expect(r.unwrap(), isEmpty);
    });

    test('letListOrNone returns None for null input', () {
      expect(letListOrNone<int>(null), isA<None<List<Option<int>>>>());
    });

    test('letListOrNone returns None for unsupported input types', () {
      expect(letListOrNone<int>(42), isA<None<List<Option<int>>>>());
    });

    test('letListOrNone parses JSON arrays from strings', () {
      final r = letListOrNone<int>('[7,8,9]');
      expect(r.unwrap().map((e) => e.unwrap()), [7, 8, 9]);
    });

    test('letSetOrNone returns Some<Set> for an Iterable input', () {
      final r = letSetOrNone<int>([1, 2, 2, 3]);
      expect(r.isSome(), isTrue);
      expect(r.unwrap(), isA<Set<Option<int>>>());
      // Set deduplicates equal Option<int> entries.
      final values = r.unwrap().map((e) => e.unwrap()).toSet();
      expect(values, {1, 2, 3});
    });

    test('letSetOrNone returns Some(empty) for empty input', () {
      final r = letSetOrNone<int>(const <int>[]);
      expect(r.unwrap(), isEmpty);
    });

    test('letSetOrNone returns None for null input', () {
      expect(letSetOrNone<int>(null), isA<None<Set<Option<int>>>>());
    });

    test('letSetOrNone returns None for unsupported types', () {
      expect(letSetOrNone<int>(42), isA<None<Set<Option<int>>>>());
    });
  });
}
