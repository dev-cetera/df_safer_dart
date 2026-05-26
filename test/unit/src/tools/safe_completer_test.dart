import 'package:df_safer_dart/df_safer_dart.dart';
import 'package:test/test.dart';

void main() {
  group('safe_completer', () {
    test('default constructor — isCompleted is false on a fresh instance', () {
      final c = SafeCompleter<int>();
      expect(c.isCompleted, isFalse);
    });

    test('resolve — accepts a Sync.okValue and exposes the value', () async {
      final c = SafeCompleter<int>();
      c.resolve(Sync.okValue(7)).end();
      expect(c.isCompleted, isTrue);
      final result = await c.resolvable().value;
      expect(result, isA<Ok<int>>());
      expect(result.unwrap(), 7);
    });

    test(
      'resolve — second call is rejected with Err while first is in-flight',
      () async {
        final c = SafeCompleter<int>();
        final slow = Future<int>.delayed(
          const Duration(milliseconds: 20),
          () => 1,
        );
        c.complete(slow).end();
        // isCompleted must be true the instant resolve is accepted (the
        // "committed" point) per CLAUDE.md, not only after settle.
        expect(c.isCompleted, isTrue);
        final second = await c.complete(99).value;
        expect(second, isA<Err>());
        expect(await c.resolvable().unwrap(), 1);
      },
    );

    test('resolve — returns Err when called after terminal completion',
        () async {
      final c = SafeCompleter<int>();
      c.complete(1).end();
      final r = await c.resolve(Sync.okValue(2)).value;
      expect(r, isA<Err>());
      expect((r as Err).error.toString(), contains('already completed'));
    });

    test('complete — forwards a sync value', () async {
      final c = SafeCompleter<String>();
      c.complete('hi').end();
      expect(await c.resolvable().unwrap(), 'hi');
    });

    test('complete — forwards a future value', () async {
      final c = SafeCompleter<String>();
      c.complete(
        Future<String>.delayed(const Duration(milliseconds: 5), () => 'fut'),
      ).end();
      expect(await c.resolvable().unwrap(), 'fut');
    });

    test('resolvable — returns Sync when synchronously completed', () {
      final c = SafeCompleter<int>();
      c.complete(5).end();
      final r = c.resolvable();
      expect(r, isA<Sync<int>>());
    });

    test('resolvable — returns Async while a future is still in-flight',
        () async {
      final c = SafeCompleter<int>();
      c.complete(
        Future<int>.delayed(const Duration(milliseconds: 10), () => 9),
      ).end();
      final r = c.resolvable();
      expect(r, isA<Async<int>>());
      expect(await r.unwrap(), 9);
    });

    test('isCompleted — observable as true during in-flight async resolve',
        () async {
      final c = SafeCompleter<int>();
      c.complete(
        Future<int>.delayed(const Duration(milliseconds: 15), () => 1),
      ).end();
      // Per CLAUDE.md hardening notes — committed point is observable.
      expect(c.isCompleted, isTrue);
      await c.resolvable().value;
      expect(c.isCompleted, isTrue);
    });

    test('transf — maps the inner value with the provided function', () async {
      final intC = SafeCompleter<int>();
      final strC = intC.transf<String>((i) => 'v$i');
      intC.complete(3).end();
      expect(await strC.resolvable().unwrap(), 'v3');
    });

    test('transf — without mapper performs a cast and surfaces TypeError',
        () async {
      final intC = SafeCompleter<int>();
      final strC = intC.transf<String>();
      intC.complete(3).end();
      final r = await strC.resolvable().value;
      expect(r, isA<Err>());
    },
        testOn: 'vm',);

    test('transf — propagates source Err to the new completer', () async {
      final intC = SafeCompleter<int>();
      final strC = intC.transf<String>((i) => 'v$i');
      intC.resolve(Sync<int>.errValue('boom')).end();
      final r = await strC.resolvable().value;
      expect(r, isA<Err>());
    });
  });
}
