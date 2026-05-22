//.title
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//
// Copyright © dev-cetera.com & contributors.
//
// The use of this source code is governed by an MIT-style license described in
// the LICENSE file located in this project's root directory.
//
// See: https://opensource.org/license/mit
//
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//.title~


import 'package:df_safer_dart/df_safer_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Sync construction', () {
    test('Sync(() => v) wraps in Ok', () {
      final s = Sync(() => 42);
      expect(s.value, isA<Ok<int>>());
      expect(s.value.unwrap(), 42);
    });

    test('Sync(() => throw) wraps in Err', () {
      final s = Sync<int>(() => throw StateError('boom'));
      expect(s.value, isA<Err>());
    });

    test('Sync(() => throw Err) preserves the Err type', () {
      final s = Sync<int>(() => throw Err<int>('boom'));
      expect(s.value, isA<Err<int>>());
      expect((s.value as Err).error, 'boom');
    });

    test('Sync.okValue', () {
      final s = Sync.okValue(7);
      expect(s.value.unwrap(), 7);
    });

    test('Sync.errValue', () {
      final s = Sync<int>.errValue('boom');
      expect(s.value, isA<Err<int>>());
    });

    test('Sync onError callback transforms thrown', () {
      final s = Sync<int>(
        () => throw StateError('a'),
        onError: (e, st) => Err<int>('handled: $e'),
      );
      expect((s.value as Err).error, contains('handled'));
    });

    test('Sync onError that itself throws still produces Err', () {
      final s = Sync<int>(
        () => throw StateError('first'),
        onError: (e, st) => throw StateError('second'),
      );
      expect(s.value, isA<Err>());
    });

    test('Sync onFinalize fires on success', () {
      var hit = 0;
      Sync<int>(() => 1, onFinalize: () => hit++).end();
      expect(hit, 1);
    });

    test('Sync onFinalize fires on failure', () {
      var hit = 0;
      Sync<int>(
        () => throw StateError('boom'),
        onFinalize: () => hit++,
      ).end();
      expect(hit, 1);
    });
  });

  group('Async construction', () {
    test('Async(() async => v) wraps in Ok', () async {
      final a = Async(() async => 42);
      final r = await a.value;
      expect(r.unwrap(), 42);
    });

    test('Async(() async => throw) wraps in Err', () async {
      final a = Async<int>(() async => throw StateError('boom'));
      final r = await a.value;
      expect(r, isA<Err>());
    });

    test('Async with async chain producing Err preserves', () async {
      final a = Async<int>(() async {
        await Future<void>.delayed(const Duration(milliseconds: 5));
        throw Err<int>('async-boom');
      });
      final r = await a.value;
      expect(r, isA<Err>());
      expect((r as Err).error, 'async-boom');
    });

    test('Async.okValue', () async {
      final a = Async.okValue(7);
      final r = await a.value;
      expect(r.unwrap(), 7);
    });

    test('Async.errValue', () async {
      final a = Async<int>.errValue(
        (error: 'boom', statusCode: null),
      );
      final r = await a.value;
      expect(r, isA<Err>());
    });

    test('Async onError catches', () async {
      final a = Async<int>(
        () async => throw StateError('a'),
        onError: (e, st) => Err<int>('handled: $e'),
      );
      final r = await a.value;
      expect(r, isA<Err>());
      expect((r as Err).error, contains('handled'));
    });

    test('Async onFinalize fires after success', () async {
      var hit = 0;
      final a = Async<int>(() async => 1, onFinalize: () => hit++);
      (await a.value).end();
      expect(hit, 1);
    });
  });

  group('Resolvable factory dispatch', () {
    test('returns Sync if closure returns sync', () {
      final r = Resolvable<int>(() => 1);
      expect(r, isA<Sync<int>>());
    });

    test('returns Async if closure returns Future', () {
      final r = Resolvable<int>(() async => 1);
      expect(r, isA<Async<int>>());
    });
  });

  group('isSync / isAsync / sync() / async()', () {
    test('Sync.isSync = true', () {
      expect(Sync.okValue(1).isSync(), isTrue);
      expect(Sync.okValue(1).isAsync(), isFalse);
    });

    test('Async.isAsync = true', () {
      expect(Async.okValue(1).isAsync(), isTrue);
      expect(Async.okValue(1).isSync(), isFalse);
    });

    test('Sync.sync yields Ok, Sync.async yields Err', () {
      final s = Sync.okValue(1);
      expect(s.sync(), isA<Ok<Sync<int>>>());
      expect(s.async(), isA<Err<Async<int>>>());
    });

    test('Async.async yields Ok, Async.sync yields Err', () {
      final a = Async.okValue(1);
      expect(a.async(), isA<Ok<Async<int>>>());
      expect(a.sync(), isA<Err<Sync<int>>>());
    });
  });

  group('Resolvable.ifOk / ifErr — abuse', () {
    test('Sync(Ok).ifOk runs', () {
      var hit = 0;
      Sync.okValue(1).ifOk((_, __) => hit++).end();
      expect(hit, 1);
    });

    test('Sync(Err).ifErr runs', () {
      var hit = 0;
      Sync<int>.errValue('boom').ifErr((_, __) => hit++).end();
      expect(hit, 1);
    });

    test('Sync(Ok).ifOk callback throwing becomes Err', () {
      final out = Sync.okValue(1).ifOk((_, __) => throw StateError('boom'));
      // The resulting Resolvable's value should reflect the new Err state.
      expect(out.sync().unwrap().value, isA<Err>());
    });

    test('Async(Ok).ifOk runs after future', () async {
      var hit = 0;
      final a = Async.okValue(1);
      a.ifOk((_, __) => hit++).end();
      (await a.value).end();
      // Allow microtasks
      await Future<void>.delayed(Duration.zero);
      expect(hit, 1);
    });

    test('Async(Ok).ifOk callback throwing becomes Err', () async {
      final a = Async.okValue(1);
      final out = a.ifOk((_, __) => throw StateError('boom'));
      final r = await out.value;
      expect(r, isA<Err>());
    });
  });

  group('Resolvable.map / then', () {
    test('Sync.map applies', () {
      final out = Sync.okValue(2).map((n) => n * 10);
      expect(out.value.unwrap(), 20);
    });

    test('Sync.map applies (then is protected, prefer map for Sync)', () {
      final out = Sync.okValue(2).map((n) => n + 1);
      expect(out.value.unwrap(), 3);
    });

    test('Sync.map of throwing mapper yields Err', () {
      final out = Sync.okValue(2).map<int>(
        (_) => throw StateError('boom'),
      );
      expect(out.value, isA<Err>());
    });

    test('Async.then chains', () async {
      final a = Async.okValue(2);
      final out = a.then((n) => n + 1);
      final r = await out.value;
      expect(r.unwrap(), 3);
    });

    test('Async.then throwing mapper yields Err', () async {
      final a = Async.okValue(2);
      final out = a.then<int>((_) => throw StateError('boom'));
      final r = await out.value;
      expect(r, isA<Err>());
    });
  });

  group('Resolvable.unwrap / unwrapOr', () {
    test('Sync(Ok).unwrap returns value', () {
      expect(Sync.okValue(1).unwrap(), 1);
    });

    test('Sync(Err).unwrap throws', () {
      expect(
        () => Sync<int>.errValue('boom').unwrap(),
        throwsA(isA<Err>()),
      );
    });

    test('Async(Ok).unwrap resolves to value', () async {
      expect(await Async.okValue(1).unwrap(), 1);
    });

    test('Async(Err).unwrap rejects', () async {
      await expectLater(
        Async<int>.errValue((error: 'boom', statusCode: null)).unwrap(),
        throwsA(isA<Err>()),
      );
    });

    test('Sync(Err).unwrapOr fallback', () {
      expect(Sync<int>.errValue('boom').unwrapOr(0), 0);
    });
  });

  group('Resolvable.withMinDuration', () {
    test('null duration is no-op', () {
      final s = Sync.okValue(1);
      expect(s.withMinDuration(null), same(s));
    });

    test('Sync with duration becomes Async', () async {
      final s = Sync.okValue(1);
      final delayed = s.withMinDuration(const Duration(milliseconds: 20));
      expect(delayed, isA<Async<int>>());
      final stopwatch = Stopwatch()..start();
      (await delayed.value).end();
      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(15));
    });
  });

  group('Resolvable.toAsync', () {
    test('Sync.toAsync yields Async with same Result', () async {
      final s = Sync.okValue(1);
      final a = s.toAsync();
      expect(a, isA<Async<int>>());
      final r = await a.value;
      expect(r.unwrap(), 1);
    });

    test('Async.toAsync returns self-like', () async {
      final a = Async.okValue(1);
      final r = await a.toAsync().value;
      expect(r.unwrap(), 1);
    });
  });

  group('Resolvable.orNull', () {
    test('Sync(Ok).orNull yields value', () async {
      expect(await Sync.okValue(1).orNull(), 1);
    });

    test('Sync(Err).orNull yields null', () async {
      expect(await Sync<int>.errValue('boom').orNull(), isNull);
    });

    test('Async(Ok).orNull yields value', () async {
      expect(await Async.okValue(1).orNull(), 1);
    });
  });

  group('Resolvable.syncOr / asyncOr / okOr / errOr', () {
    test('Sync.syncOr returns self', () {
      final s = Sync.okValue(1);
      expect(s.syncOr(Async.okValue(2)), same(s));
    });

    test('Async.syncOr returns other', () {
      final other = Sync.okValue(2);
      final out = Async.okValue(1).syncOr(other);
      expect(out, same(other));
    });

    test('Ok.okOr returns self for Sync', () {
      final s = Sync.okValue(1);
      expect(s.okOr(Sync.okValue(2)), same(s));
    });

    test('Err.okOr returns other for Sync', () {
      final other = Sync.okValue(99);
      expect(Sync<int>.errValue('boom').okOr(other), same(other));
    });
  });

  group('Resolvable.transf', () {
    test('Sync(Ok).transf with mapper', () {
      final s = Sync.okValue(2);
      final out = s.transf<String>((n) => 'v$n');
      expect(out.value.unwrap(), 'v2');
    });

    test('Sync(Ok).transf cast failure becomes Err', () {
      final s = Sync.okValue(2);
      final out = s.transf<String>();
      expect(out.value, isA<Err>());
    });

    test('Sync(Err).transf preserves error', () {
      final s = Sync<int>.errValue('boom');
      final out = s.transf<String>();
      expect(out.value, isA<Err>());
    });
  });

  group('Resolvable.combine2 / combine3', () {
    test('combine2 — two Sync(Ok)', () async {
      final out = Resolvable.combine2(
        Sync.okValue(1),
        Sync.okValue('a'),
      );
      final r = await out.value;
      expect(r.unwrap(), (1, 'a'));
    });

    test('combine2 — one Sync, one Async', () async {
      final out = Resolvable.combine2(
        Sync.okValue(1),
        Async.okValue('a'),
      );
      expect(out, isA<Async>());
      final r = await out.value;
      expect(r.unwrap(), (1, 'a'));
    });

    test('combine2 — one Err short-circuits', () async {
      final out = Resolvable.combine2(
        Sync<int>.errValue('boom'),
        Sync.okValue('a'),
      );
      final r = await out.value;
      expect(r, isA<Err>());
    });

    test('combine3 — three Ok', () async {
      final out = Resolvable.combine3(
        Sync.okValue(1),
        Sync.okValue('a'),
        Async.okValue(2.0),
      );
      final r = await out.value;
      expect(r.unwrap(), (1, 'a', 2.0));
    });
  });

  group('combineSync / combineAsync', () {
    test('combineSync — all Ok', () {
      final out = combineSync<int>([Sync.okValue(1), Sync.okValue(2)]);
      expect(out.value.unwrap(), [1, 2]);
    });

    test('combineSync — one Err', () {
      final out = combineSync<int>([
        Sync.okValue(1),
        Sync<int>.errValue('mid'),
      ]);
      expect(out.value, isA<Err>());
    });

    test('combineAsync — all Ok', () async {
      final out = combineAsync<int>([Async.okValue(1), Async.okValue(2)]);
      final r = await out.value;
      expect(r.unwrap(), [1, 2]);
    });

    test('combineAsync — concurrent execution', () async {
      var counter = 0;
      Async<int> makeAsync(int v) =>
          Async(() async {
            counter++;
            await Future<void>.delayed(const Duration(milliseconds: 20));
            return v;
          });
      final stopwatch = Stopwatch()..start();
      final out = combineAsync<int>([makeAsync(1), makeAsync(2), makeAsync(3)]);
      final r = await out.value;
      stopwatch.stop();
      expect(r.unwrap(), [1, 2, 3]);
      expect(counter, 3);
      // Concurrent: should be ~20ms not 60ms.
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });

    test('empty Sync', () {
      expect(combineSync<int>(const []).value.unwrap(), <int>[]);
    });

    test('empty Async', () async {
      expect(
        (await combineAsync<int>(const []).value).unwrap(),
        <int>[],
      );
    });
  });

  group('Resolvable.foldResult / fold', () {
    test('Sync.foldResult Ok → maps to new Ok', () {
      final out = Sync.okValue(1).foldResult(
        (ok) => Ok(ok.value + 1),
        (err) => err,
      );
      expect(out.value, isA<Ok>());
    });

    test('Sync.foldResult Err runs onErr', () {
      final out = Sync<int>.errValue('boom').foldResult(
        (ok) => ok,
        (err) => const Ok<int>(99),
      );
      expect(out.value, isA<Ok>());
    });
  });

  group('Sync asserts T is not Future', () {
    test('Sync constructor asserts on Future<X> as T', () {
      expect(
        () => Sync<Future<int>>(() => Future.value(1)),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('Sync.whenComplete', () {
    test('Sync(Ok).whenComplete runs', () {
      var hit = 0;
      Sync.okValue(1).whenComplete((_) {
        hit++;
        return Sync.okValue(1);
      }).end();
      expect(hit, 1);
    });

    test('Sync(Err).whenComplete does not run callback', () async {
      // whenComplete on Sync.err returns the err — callback only runs if Ok.
      var hit = 0;
      final out = Sync<int>.errValue('boom').whenComplete((_) {
        hit++;
        return Sync.okValue(1);
      });
      expect(hit, 0);
      expect(out.value, isA<Err>());
    });
  });
}
