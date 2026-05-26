import 'package:df_safer_dart/df_safer_dart.dart';
import 'package:test/test.dart';

void main() {
  group('_none', () {
    test('default constructor produces a const None', () {
      const a = None<int>();
      const b = None<int>();
      expect(identical(a, b), isTrue);
    });

    test('value getter returns the Unit sentinel', () {
      const none = None<int>();
      expect(none.value, isNotNull);
      // Two Nones of the same T share the same Unit value.
      expect(none.value, equals(const None<int>().value));
    });

    test('isSome returns false', () {
      expect(const None<int>().isSome(), isFalse);
    });

    test('isNone returns true', () {
      expect(const None<int>().isNone(), isTrue);
    });

    test('some() returns Err because this is None', () {
      final result = const None<int>().some();
      expect(result, isA<Err<Some<int>>>());
    });

    test('none() returns Ok wrapping this None', () {
      const none = None<int>();
      final result = none.none();
      expect(result, isA<Ok<None<int>>>());
      expect(identical(result.unwrap(), none), isTrue);
    });

    test('ifSome does not invoke callback and returns Ok wrapping self', () {
      const none = None<int>();
      var called = false;
      final result = none.ifSome((self, some) => called = true);
      expect(called, isFalse);
      expect(result, isA<Ok<None<int>>>());
      expect(identical(result.unwrap(), none), isTrue);
    });

    test('ifNone invokes callback with self and self, returns Ok', () {
      const none = None<int>();
      Object? receivedSelf;
      None<int>? receivedNone;
      final result = none.ifNone((self, n) {
        receivedSelf = self;
        receivedNone = n;
      });
      expect(identical(receivedSelf, none), isTrue);
      expect(identical(receivedNone, none), isTrue);
      expect(result, isA<Ok<None<int>>>());
      expect(identical(result.unwrap(), none), isTrue);
    });

    test('orNull returns null', () {
      expect(const None<int>().orNull(), isNull);
    });

    test('mapSome returns this None unchanged (callback ignored)', () {
      const none = None<int>();
      var called = false;
      final result = none.mapSome((s) {
        called = true;
        return s;
      });
      expect(called, isFalse);
      expect(identical(result, none), isTrue);
    });

    test('mapNone invokes the callback and returns its result', () {
      const replacement = None<int>();
      final mapped = const None<int>().mapNone((n) => replacement);
      expect(identical(mapped, replacement), isTrue);
    });

    test('flatMap returns const None without invoking the callback', () {
      var called = false;
      final result = const None<int>().flatMap<String>((_) {
        called = true;
        return const Some('x');
      });
      expect(called, isFalse);
      expect(result, isA<None<String>>());
    });

    test('filter returns None without invoking the predicate', () {
      var called = false;
      final result = const None<int>().filter((_) {
        called = true;
        return true;
      });
      expect(called, isFalse);
      expect(result, isA<None<int>>());
    });

    test('fold invokes onNone and wraps its result in Ok', () {
      var someCalls = 0;
      var noneCalls = 0;
      final folded = const None<int>().fold(
        (s) {
          someCalls++;
          return null;
        },
        (n) {
          noneCalls++;
          return const Some<Object>('replaced');
        },
      );
      expect(someCalls, 0);
      expect(noneCalls, 1);
      expect(folded, isA<Ok<Option<Object>>>());
      final inner = folded.unwrap();
      expect(inner, isA<Some<Object>>());
      expect((inner as Some).value, 'replaced');
    });

    test('fold returns self wrapped in Ok when onNone returns null', () {
      const none = None<int>();
      final folded = none.fold((_) => null, (_) => null);
      expect(folded, isA<Ok<Option<Object>>>());
      expect(identical(folded.unwrap(), none), isTrue);
    });

    test('fold absorbs thrown Err verbatim into returned Err', () {
      final folded = const None<int>().fold(
        (_) => null,
        (_) => throw Err<int>('boom'),
      );
      expect(folded, isA<Err<Option<Object>>>());
    });

    test('fold absorbs generic throw into Err with stack trace', () {
      final folded = const None<int>().fold(
        (_) => null,
        (_) => throw StateError('bad'),
      );
      expect(folded, isA<Err<Option<Object>>>());
      expect((folded as Err).stackTrace, isNotNull);
    });

    test('someOr returns the other Option', () {
      const other = Some<int>(99);
      final result = const None<int>().someOr(other);
      expect(identical(result, other), isTrue);
    });

    test('noneOr returns this None', () {
      const none = None<int>();
      final result = none.noneOr(const Some(99));
      expect(identical(result, none), isTrue);
    });

    test('unwrap throws an Err', () {
      const Option<int> none = None();
      expect(() => none.unwrap(), throwsA(isA<Err<int>>()));
    });

    test('unwrapOr returns the fallback', () {
      const Option<int> none = None();
      expect(none.unwrapOr(123), 123);
    });

    test('map returns a typed None<R> without invoking the callback', () {
      var called = false;
      final mapped = const None<int>().map<String>((v) {
        called = true;
        return 'x';
      });
      expect(called, isFalse);
      expect(mapped, isA<None<String>>());
    });

    test('transf returns Ok(None<R>()) without invoking the callback', () {
      var called = false;
      final result = const None<int>().transf<String>((v) {
        called = true;
        return 'x';
      });
      expect(called, isFalse);
      expect(result, isA<Ok<None<String>>>());
      expect(result.unwrap(), isA<None<String>>());
    });

    test('transf without callback returns Ok(None())', () {
      final result = const None<int>().transf<String>();
      expect(result, isA<Ok<None<String>>>());
    });

    test('equality between two None<T> is true', () {
      expect(const None<int>() == const None<int>(), isTrue);
    });

    test('two None instances of the same T are canonicalized const', () {
      const a = None<String>();
      const b = None<String>();
      expect(identical(a, b), isTrue);
    });
  });
}
