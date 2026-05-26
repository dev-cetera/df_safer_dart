// ignore_for_file: invalid_use_of_protected_member

import 'package:df_safer_dart/df_safer_dart.dart';
import 'package:test/test.dart';

void main() {
  group('lazy', () {
    test('Lazy.singleton computes the value only on first access', () {
      var callCount = 0;
      final lazy = Lazy<int>(() {
        callCount++;
        return Sync.okValue(42);
      });
      expect(callCount, 0, reason: 'constructor must not run before access');
      final first = lazy.singleton;
      expect(callCount, 1);
      expect(first, isA<Sync<int>>());
      expect((first as Sync<int>).value, isA<Ok<int>>());
      expect(first.value.unwrap(), 42);
    });

    test('Lazy.singleton memoises and returns the same Resolvable instance',
        () {
      var callCount = 0;
      final lazy = Lazy<int>(() {
        callCount++;
        return Sync.okValue(callCount);
      });
      final a = lazy.singleton;
      final b = lazy.singleton;
      expect(callCount, 1, reason: 'constructor must run exactly once');
      expect(identical(a, b), isTrue);
      expect((a as Sync<int>).value.unwrap(), 1);
    });

    test('Lazy.currentInstance starts as None and becomes Some after access',
        () {
      final lazy = Lazy<int>(() => Sync.okValue(7));
      expect(lazy.currentInstance, isA<None<Resolvable<int>>>());
      lazy.singleton;
      expect(lazy.currentInstance, isA<Some<Resolvable<int>>>());
    });

    test('Lazy.resetSingleton clears the cache so the next access recomputes',
        () {
      var callCount = 0;
      final lazy = Lazy<int>(() {
        callCount++;
        return Sync.okValue(callCount);
      });
      expect((lazy.singleton as Sync<int>).value.unwrap(), 1);
      expect((lazy.singleton as Sync<int>).value.unwrap(), 1);
      lazy.resetSingleton();
      expect(lazy.currentInstance, isA<None<Resolvable<int>>>());
      expect((lazy.singleton as Sync<int>).value.unwrap(), 2);
      expect(callCount, 2);
    });

    test('Lazy.singleton absorbs thrown errors into Sync.err', () {
      final lazy = Lazy<int>(() {
        throw StateError('boom');
      });
      final r = lazy.singleton;
      expect(r, isA<Sync<int>>());
      final inner = (r as Sync<int>).value;
      expect(inner, isA<Err<int>>());
      expect((inner as Err).error, isA<StateError>());
    });

    test('Lazy.singleton caches a failed construction (same Err on re-read)',
        () {
      var callCount = 0;
      final lazy = Lazy<int>(() {
        callCount++;
        throw StateError('boom-$callCount');
      });
      final a = lazy.singleton;
      final b = lazy.singleton;
      expect(callCount, 1, reason: 'failed construction must be cached');
      expect(identical(a, b), isTrue);
    });

    test('Lazy.singleton converts a thrown Err into a typed Sync.err', () {
      final lazy = Lazy<int>(() {
        throw Err<String>('typed-err');
      });
      final r = lazy.singleton;
      expect(r, isA<Sync<int>>());
      final inner = (r as Sync<int>).value;
      expect(inner, isA<Err<int>>());
      expect((inner as Err).error, 'typed-err');
    });

    test(
        'Lazy.singleton detects re-entrant access and returns a Sync.err '
        'instead of stack-overflowing', () {
      late Lazy<int> lazy;
      lazy = Lazy<int>(() {
        // Re-entrance: read singleton from inside the constructor.
        return lazy.singleton;
      });
      final r = lazy.singleton;
      expect(r, isA<Sync<int>>());
      final inner = (r as Sync<int>).value;
      expect(inner, isA<Err<int>>());
      final msg = (inner as Err).error.toString();
      expect(msg.contains('re-entrant'), isTrue);
    });

    test('Lazy.factory invokes the constructor every time', () {
      var callCount = 0;
      final lazy = Lazy<int>(() {
        callCount++;
        return Sync.okValue(callCount);
      });
      final a = lazy.factory;
      final b = lazy.factory;
      expect(callCount, 2);
      expect((a as Sync<int>).value.unwrap(), 1);
      expect((b as Sync<int>).value.unwrap(), 2);
      // factory must NOT touch currentInstance.
      expect(lazy.currentInstance, isA<None<Resolvable<int>>>());
    });

    test('Lazy.factory absorbs thrown errors into Sync.err', () {
      final lazy = Lazy<int>(() {
        throw StateError('factory-boom');
      });
      final r = lazy.factory;
      expect(r, isA<Sync<int>>());
      final inner = (r as Sync<int>).value;
      expect(inner, isA<Err<int>>());
      expect((inner as Err).error, isA<StateError>());
    });

    test('Lazy.factory converts a thrown Err into a typed Sync.err', () {
      final lazy = Lazy<int>(() {
        throw Err<String>('factory-typed');
      });
      final r = lazy.factory;
      final inner = (r as Sync<int>).value;
      expect(inner, isA<Err<int>>());
      expect((inner as Err).error, 'factory-typed');
    });

    test(
        'Lazy.factory detects re-entrant access and returns a Sync.err '
        'instead of stack-overflowing', () {
      late Lazy<int> lazy;
      lazy = Lazy<int>(() {
        return lazy.factory;
      });
      final r = lazy.factory;
      expect(r, isA<Sync<int>>());
      final inner = (r as Sync<int>).value;
      expect(inner, isA<Err<int>>());
      final msg = (inner as Err).error.toString();
      expect(msg.contains('re-entrant'), isTrue);
    });

    test('Lazy works with Async resolvable constructor', () async {
      var callCount = 0;
      final lazy = Lazy<int>(() {
        callCount++;
        return Async(() async => 99);
      });
      final r = lazy.singleton;
      expect(r, isA<Async<int>>());
      final result = await (r as Async<int>).value;
      expect(result, isA<Ok<int>>());
      expect(result.unwrap(), 99);
      expect(callCount, 1);
      // Second access must return the same cached Async.
      final r2 = lazy.singleton;
      expect(identical(r, r2), isTrue);
      expect(callCount, 1);
    });
  });
}
