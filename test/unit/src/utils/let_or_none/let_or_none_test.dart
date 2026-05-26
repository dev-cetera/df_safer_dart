import 'package:df_safer_dart/df_safer_dart.dart';
import 'package:test/test.dart';

void main() {
  group('let_or_none', () {
    test('letOrNone<int> returns Some for an int input', () {
      final r = letOrNone<int>(42);
      expect(r, isA<Some<int>>());
      expect(r.unwrap(), 42);
    });

    test('letOrNone<int> returns Some by parsing a numeric String', () {
      final r = letOrNone<int>('123');
      expect(r.unwrap(), 123);
    });

    test('letOrNone<int> returns None for a non-numeric String', () {
      expect(letOrNone<int>('not-a-number'), isA<None<int>>());
    });

    test('letOrNone<int> returns None for null input', () {
      expect(letOrNone<int>(null), isA<None<int>>());
    });

    test('letOrNone<double> returns Some for an int input', () {
      final r = letOrNone<double>(7);
      expect(r.unwrap(), 7.0);
    });

    test('letOrNone<String> stringifies non-String, non-null input', () {
      // letAsStringOrNone fallback path: any object becomes its toString.
      final r = letOrNone<String>(7);
      expect(r.unwrap(), '7');
    });

    test('letOrNone<bool> parses "true"/"false" strings', () {
      expect(letOrNone<bool>('true').unwrap(), isTrue);
      expect(letOrNone<bool>('false').unwrap(), isFalse);
      expect(letOrNone<bool>('TRUE').unwrap(), isTrue);
    });

    test('letOrNone<Uri> parses a valid URI string', () {
      final r = letOrNone<Uri>('https://example.com/x');
      expect(r.unwrap(), Uri.parse('https://example.com/x'));
    });

    test('letOrNone<DateTime> parses ISO-8601 string', () {
      final r = letOrNone<DateTime>('2026-05-26T12:00:00Z');
      expect(r.isSome(), isTrue);
      expect(r.unwrap().toUtc().year, 2026);
    });

    test('letOrNone unwraps a sync Outcome chain (Ok)', () {
      final ok = Sync<int>.okValue(99);
      final r = letOrNone<int>(ok);
      expect(r.unwrap(), 99);
    });

    test('letOrNone returns None when the Outcome is Err', () {
      final err = Sync<int>.err(Err<int>('boom'));
      expect(letOrNone<int>(err), isA<None<int>>());
    });

    test('letAsOrNone returns Some when input is the target type', () {
      final r = letAsOrNone<String>('hello');
      expect(r.unwrap(), 'hello');
    });

    test('letAsOrNone returns None when input is not the target type', () {
      expect(letAsOrNone<String>(42), isA<None<String>>());
    });

    test('letAsOrNone unwraps a sync Outcome chain', () {
      final ok = Sync<String>.okValue('via outcome');
      expect(letAsOrNone<String>(ok).unwrap(), 'via outcome');
    });

    test('letAsOrNone returns None for null input', () {
      expect(letAsOrNone<int>(null), isA<None<int>>());
    });

    test('letAsStringOrNone returns Some for any non-null object', () {
      expect(letAsStringOrNone(123).unwrap(), '123');
      expect(letAsStringOrNone(true).unwrap(), 'true');
      expect(letAsStringOrNone('hi').unwrap(), 'hi');
    });

    test('letAsStringOrNone returns None for null', () {
      // The function explicitly maps null → None rather than the literal
      // string "null".
      expect(letAsStringOrNone(null), isA<None<String>>());
    });

    test('letAsStringOrNone unwraps a sync Outcome chain', () {
      final ok = Sync<int>.okValue(5);
      expect(letAsStringOrNone(ok).unwrap(), '5');
    });

    test('jsonDecodeOrNone parses valid JSON into the target type', () {
      final r = jsonDecodeOrNone<Map<String, dynamic>>('{"a":1}');
      expect(r.unwrap(), {'a': 1});
    });

    test('jsonDecodeOrNone returns None for malformed JSON', () {
      expect(
        jsonDecodeOrNone<Map<String, dynamic>>('not json'),
        isA<None<Map<String, dynamic>>>(),
      );
    });

    test('jsonDecodeOrNone returns None if decoded type does not match', () {
      // Decoded JSON yields a List, but caller asked for a Map.
      expect(
        jsonDecodeOrNone<Map<String, dynamic>>('[1,2,3]'),
        isA<None<Map<String, dynamic>>>(),
      );
    });

    test('letNumOrNone returns Some for num input', () {
      expect(letNumOrNone(3.14).unwrap(), 3.14);
      expect(letNumOrNone(7).unwrap(), 7);
    });

    test('letNumOrNone parses a numeric string', () {
      expect(letNumOrNone(' 12.5 ').unwrap(), 12.5);
    });

    test('letNumOrNone returns None for non-numeric input', () {
      expect(letNumOrNone('abc'), isA<None<num>>());
      expect(letNumOrNone(<int>[1]), isA<None<num>>());
      expect(letNumOrNone(null), isA<None<num>>());
    });

    test('letNumOrNone unwraps an Outcome chain', () {
      final ok = Sync<int>.okValue(8);
      expect(letNumOrNone(ok).unwrap(), 8);
    });

    test('letIntOrNone returns Some for positive int', () {
      expect(letIntOrNone(42).unwrap(), 42);
    });

    test('letIntOrNone returns Some for negative int', () {
      expect(letIntOrNone(-99).unwrap(), -99);
    });

    test('letIntOrNone returns Some for zero', () {
      expect(letIntOrNone(0).unwrap(), 0);
    });

    test('letIntOrNone converts a valid finite double to int', () {
      expect(letIntOrNone(3.0).unwrap(), 3);
      expect(letIntOrNone(-7.0).unwrap(), -7);
    });

    test('letIntOrNone parses an integer-valued string', () {
      expect(letIntOrNone('100').unwrap(), 100);
    });

    test('letIntOrNone returns None for NaN', () {
      expect(letIntOrNone(double.nan), isA<None<int>>());
    });

    test('letIntOrNone returns None for +Infinity', () {
      expect(letIntOrNone(double.infinity), isA<None<int>>());
    });

    test('letIntOrNone returns None for -Infinity', () {
      expect(letIntOrNone(double.negativeInfinity), isA<None<int>>());
    });

    test('letIntOrNone returns None for doubles above int64 max', () {
      expect(letIntOrNone(1e20), isA<None<int>>());
    });

    test('letIntOrNone returns None for doubles below int64 min', () {
      expect(letIntOrNone(-1e20), isA<None<int>>());
    });

    test('letIntOrNone returns None for null', () {
      expect(letIntOrNone(null), isA<None<int>>());
    });

    test('letIntOrNone returns None for non-numeric input', () {
      expect(letIntOrNone('xyz'), isA<None<int>>());
    });

    test('letDoubleOrNone returns Some for double input', () {
      expect(letDoubleOrNone(2.5).unwrap(), 2.5);
    });

    test('letDoubleOrNone converts int to double', () {
      expect(letDoubleOrNone(7).unwrap(), 7.0);
    });

    test('letDoubleOrNone parses a numeric string', () {
      expect(letDoubleOrNone('1.5').unwrap(), 1.5);
    });

    test('letDoubleOrNone returns None for non-numeric input', () {
      expect(letDoubleOrNone('not a number'), isA<None<double>>());
      expect(letDoubleOrNone(null), isA<None<double>>());
    });

    test('letBoolOrNone returns Some for bool input', () {
      expect(letBoolOrNone(true).unwrap(), isTrue);
      expect(letBoolOrNone(false).unwrap(), isFalse);
    });

    test('letBoolOrNone parses "true"/"false" case-insensitively', () {
      expect(letBoolOrNone('true').unwrap(), isTrue);
      expect(letBoolOrNone('FALSE').unwrap(), isFalse);
      expect(letBoolOrNone(' True ').unwrap(), isTrue);
    });

    test('letBoolOrNone returns None for non-bool input', () {
      expect(letBoolOrNone('maybe'), isA<None<bool>>());
      expect(letBoolOrNone(1), isA<None<bool>>());
      expect(letBoolOrNone(null), isA<None<bool>>());
    });

    test('letBoolOrNone unwraps an Outcome chain', () {
      final ok = Sync<bool>.okValue(true);
      expect(letBoolOrNone(ok).unwrap(), isTrue);
    });

    test('letUriOrNone returns Some for a Uri input', () {
      final u = Uri.parse('https://x.example');
      expect(letUriOrNone(u).unwrap(), u);
    });

    test('letUriOrNone parses a Uri-shaped string', () {
      final r = letUriOrNone('https://x.example/path');
      expect(r.unwrap().host, 'x.example');
    });

    test('letUriOrNone returns None for non-Uri-shaped input', () {
      expect(letUriOrNone(123), isA<None<Uri>>());
      expect(letUriOrNone(null), isA<None<Uri>>());
    });

    test('letDateTimeOrNone returns Some for a DateTime input', () {
      final d = DateTime.utc(2026, 1, 1);
      expect(letDateTimeOrNone(d).unwrap(), d);
    });

    test('letDateTimeOrNone parses a valid ISO string', () {
      final r = letDateTimeOrNone('2026-05-26');
      expect(r.isSome(), isTrue);
    });

    test('letDateTimeOrNone returns None for an unparseable string', () {
      expect(letDateTimeOrNone('not-a-date'), isA<None<DateTime>>());
    });

    test('letDateTimeOrNone returns None for null', () {
      expect(letDateTimeOrNone(null), isA<None<DateTime>>());
    });
  });
}
