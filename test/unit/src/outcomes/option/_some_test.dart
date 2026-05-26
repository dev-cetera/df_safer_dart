import 'package:df_safer_dart/df_safer_dart.dart';
import 'package:test/test.dart';

void main() {
  group('_some', () {
    test('constructor + value getter exposes the wrapped value', () {
      const some = Some<int>(42);
      expect(some.value, 42);
    });

    test('isSome returns true', () {
      expect(const Some<int>(1).isSome(), isTrue);
    });

    test('isNone returns false', () {
      expect(const Some<int>(1).isNone(), isFalse);
    });

    test('some() returns Ok wrapping this Some', () {
      const some = Some<int>(5);
      final result = some.some();
      expect(result, isA<Ok<Some<int>>>());
      expect(identical(result.unwrap(), some), isTrue);
    });

    test('none() returns Err because this is Some', () {
      final result = const Some<int>(5).none();
      expect(result, isA<Err<None<int>>>());
    });

    test('ifSome invokes callback with self and self, returns Ok', () {
      const some = Some<int>(9);
      Some<int>? receivedSelf;
      Some<int>? receivedSome;
      final result = some.ifSome((self, s) {
        receivedSelf = self;
        receivedSome = s;
      });
      expect(identical(receivedSelf, some), isTrue);
      expect(identical(receivedSome, some), isTrue);
      expect(result, isA<Ok<Some<int>>>());
      expect(identical(result.unwrap(), some), isTrue);
    });

    test('ifNone does not invoke callback and returns Ok wrapping self', () {
      const some = Some<int>(9);
      var called = false;
      final result = some.ifNone((self, none) => called = true);
      expect(called, isFalse);
      expect(result, isA<Ok<Some<int>>>());
      expect(identical(result.unwrap(), some), isTrue);
    });

    test('orNull returns the contained value', () {
      expect(const Some<int>(7).orNull(), 7);
    });

    test('mapSome transforms via callback and returns the new Some', () {
      const some = Some<int>(2);
      final mapped = some.mapSome((s) => Some(s.value * 10));
      expect(mapped, isA<Some<int>>());
      expect(mapped.value, 20);
    });

    test('mapNone returns this Some unchanged (callback ignored)', () {
      const some = Some<int>(2);
      var called = false;
      final mapped = some.mapNone((n) {
        called = true;
        return const None();
      });
      expect(called, isFalse);
      expect(identical(mapped, some), isTrue);
    });

    test('flatMap chains into another Option produced by callback', () {
      final result = const Some<int>(3).flatMap<String>(
        (v) => Some('v=$v'),
      );
      expect(result, isA<Some<String>>());
      expect(result.unwrap(), 'v=3');
    });

    test('flatMap to None propagates None', () {
      final result = const Some<int>(3).flatMap<String>(
        (v) => const None(),
      );
      expect(result, isA<None<String>>());
    });

    test('filter returns this when predicate is true', () {
      const some = Some<int>(4);
      final filtered = some.filter((v) => v.isEven);
      expect(identical(filtered, some), isTrue);
    });

    test('filter returns None when predicate is false', () {
      final filtered = const Some<int>(4).filter((v) => v.isOdd);
      expect(filtered, isA<None<int>>());
    });

    test('fold invokes onSome and wraps its result in Ok', () {
      var someCalls = 0;
      var noneCalls = 0;
      final folded = const Some<int>(5).fold(
        (s) {
          someCalls++;
          return Some<Object>('mapped:${s.value}');
        },
        (n) {
          noneCalls++;
          return null;
        },
      );
      expect(someCalls, 1);
      expect(noneCalls, 0);
      expect(folded, isA<Ok<Option<Object>>>());
      final inner = folded.unwrap();
      expect(inner, isA<Some<Object>>());
      expect((inner as Some).value, 'mapped:5');
    });

    test('fold returns self wrapped in Ok when onSome returns null', () {
      const some = Some<int>(5);
      final folded = some.fold((_) => null, (_) => null);
      expect(folded, isA<Ok<Option<Object>>>());
      expect(identical(folded.unwrap(), some), isTrue);
    });

    test('fold absorbs thrown Err verbatim into returned Err', () {
      final folded = const Some<int>(1).fold(
        (_) => throw Err<int>('boom'),
        (_) => null,
      );
      expect(folded, isA<Err<Option<Object>>>());
    });

    test('fold absorbs generic throw into Err with stack trace', () {
      final folded = const Some<int>(1).fold(
        (_) => throw StateError('bad'),
        (_) => null,
      );
      expect(folded, isA<Err<Option<Object>>>());
      expect((folded as Err).stackTrace, isNotNull);
    });

    test('someOr returns this regardless of other', () {
      const some = Some<int>(1);
      final result = some.someOr(const Some(99));
      expect(identical(result, some), isTrue);
    });

    test('noneOr returns the other Option', () {
      const other = Some<int>(99);
      final result = const Some<int>(1).noneOr(other);
      expect(identical(result, other), isTrue);
    });

    test('unwrap returns the contained value', () {
      expect(const Some<int>(11).unwrap(), 11);
    });

    test('unwrapOr returns the contained value, ignoring fallback', () {
      expect(const Some<int>(11).unwrapOr(0), 11);
    });

    test('map produces a new Some with the mapped value', () {
      final mapped = const Some<int>(2).map<String>((v) => 'n=$v');
      expect(mapped, isA<Some<String>>());
      expect(mapped.value, 'n=2');
    });

    test('transf with no callback performs a cast and wraps in Ok(Some)', () {
      final Some<Object> upcast = const Some<int>(7);
      final result = upcast.transf<int>();
      expect(result, isA<Ok<Option<int>>>());
      final inner = result.unwrap();
      expect(inner, isA<Some<int>>());
      expect((inner as Some).value, 7);
    });

    test('transf with callback maps then wraps in Ok(Some)', () {
      final result = const Some<int>(3).transf<String>((v) => 'x$v');
      expect(result, isA<Ok<Option<String>>>());
      final inner = result.unwrap();
      expect(inner, isA<Some<String>>());
      expect((inner as Some).value, 'x3');
    });

    test('transf cast failure becomes Err (does not throw)', () {
      final Some<Object> upcast = const Some<int>(7);
      final result = upcast.transf<String>();
      expect(result, isA<Err<Option<String>>>());
    });

    test('transf preserves Err thrown by user callback', () {
      final result = const Some<int>(3).transf<String>(
        (_) => throw Err<String>('nope'),
      );
      expect(result, isA<Err<Option<String>>>());
    });
  });
}
