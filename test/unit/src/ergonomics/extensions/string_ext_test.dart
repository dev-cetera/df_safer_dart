import 'package:df_safer_dart/df_safer_dart.dart';
import 'package:test/test.dart';

void main() {
  group('string_ext', () {
    group('noneIfEmpty', () {
      test('non-empty string returns Some(this)', () {
        final out = 'hello'.noneIfEmpty;
        expect(out, isA<Some<String>>());
        expect(out.unwrap(), 'hello');
      });

      test('empty string returns None', () {
        expect(''.noneIfEmpty, isA<None<String>>());
      });
    });

    group('firstOrNone', () {
      test('returns Some of first character', () {
        final out = 'abc'.firstOrNone;
        expect(out, isA<Some<String>>());
        expect(out.unwrap(), 'a');
      });

      test('empty string returns None', () {
        expect(''.firstOrNone, isA<None<String>>());
      });
    });

    group('lastOrNone', () {
      test('returns Some of last character', () {
        final out = 'abc'.lastOrNone;
        expect(out, isA<Some<String>>());
        expect(out.unwrap(), 'c');
      });

      test('empty string returns None', () {
        expect(''.lastOrNone, isA<None<String>>());
      });
    });

    group('elementAtOrNone', () {
      test('valid index returns Some of character', () {
        final out = 'abc'.elementAtOrNone(1);
        expect(out, isA<Some<String>>());
        expect(out.unwrap(), 'b');
      });

      test('negative index returns None', () {
        expect('abc'.elementAtOrNone(-1), isA<None<String>>());
      });

      test('index past end returns None', () {
        expect('abc'.elementAtOrNone(3), isA<None<String>>());
      });
    });
  });
}
