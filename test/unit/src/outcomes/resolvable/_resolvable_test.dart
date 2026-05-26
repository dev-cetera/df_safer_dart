import 'dart:async';

import 'package:df_safer_dart/df_safer_dart.dart';
import 'package:test/test.dart';

void main() {
  group('_resolvable', () {
    test('value getter returns FutureOr<Result<T>> for Sync', () {
      final Resolvable<int> r = Sync.okValue(7);
      final v = r.value;
      expect(v, isA<Result<int>>());
      expect((v as Result<int>).unwrap(), 7);
    });

    test('value getter returns Future<Result<T>> for Async', () async {
      final Resolvable<int> r = Async<int>(() async => 11);
      final v = r.value;
      expect(v, isA<Future<Result<int>>>());
      final result = await (v as Future<Result<int>>);
      expect(result.unwrap(), 11);
    });

    test('Resolvable.result protected constructor (via Sync.result)', () {
      final Resolvable<int> r = Sync.result(const Ok(3));
      expect(r.value, isA<Ok<int>>());
    });

    test('Resolvable.ok protected constructor (via Sync.ok)', () {
      final Resolvable<int> r = Sync.ok(const Ok(4));
      expect((r.value as Ok<int>).value, 4);
    });

    test('Resolvable.err protected constructor (via Sync.err)', () {
      final Resolvable<int> r = Sync.err(Err<int>('oops'));
      expect(r.value, isA<Err<int>>());
    });

    test('combine2 merges two Oks into a tuple', () async {
      final r = Resolvable.combine2(Sync.okValue(1), Sync.okValue('a'));
      final result = await r.value;
      expect(result.unwrap(), (1, 'a'));
    });

    test('combine2 short-circuits on Err', () async {
      final r = Resolvable.combine2<int, String>(
        Sync.okValue(1),
        Sync.errValue('bad'),
      );
      final result = await r.value;
      expect(result, isA<Err>());
    });

    test('combine2 uses onErr combiner when provided', () async {
      final r = Resolvable.combine2<int, int>(
        Sync.errValue('e1'),
        Sync.errValue('e2'),
        (a, b) => Err<(int, int)>('combined'),
      );
      final result = await r.value;
      expect(result, isA<Err<(int, int)>>());
      expect((result as Err<(int, int)>).error, 'combined');
    });

    test('combine3 merges three Oks into a tuple', () async {
      final r = Resolvable.combine3(
        Sync.okValue(1),
        Sync.okValue('x'),
        Sync.okValue(true),
      );
      final result = await r.value;
      expect(result.unwrap(), (1, 'x', true));
    });

    test('combine3 short-circuits on Err', () async {
      final r = Resolvable.combine3<int, int, int>(
        Sync.okValue(1),
        Sync.errValue('bad'),
        Sync.okValue(3),
      );
      final result = await r.value;
      expect(result, isA<Err>());
    });

    test('Resolvable() factory returns Sync for non-Future', () {
      final r = Resolvable<int>(() => 5);
      expect(r, isA<Sync<int>>());
      expect(r.isSync(), true);
    });

    test('Resolvable() factory returns Async for Future closure', () async {
      final r = Resolvable<int>(() async => 9);
      expect(r, isA<Async<int>>());
      final result = await r.value;
      expect(result.unwrap(), 9);
    });

    test('Resolvable() factory absorbs sync throws into Err', () {
      final r = Resolvable<int>(() => throw StateError('boom'));
      expect(r, isA<Sync<int>>());
      expect(r.value, isA<Err<int>>());
    });

    test('Resolvable() factory preserves a thrown Err verbatim', () {
      final r = Resolvable<int>(() => throw Err<String>('keep me'));
      expect(r.value, isA<Err<int>>());
      expect((r.value as Err<int>).error, 'keep me');
    });

    test('Resolvable() factory routes non-Err throw via onError', () {
      final r = Resolvable<int>(
        () => throw StateError('boom'),
        onError: (e, st) => Err<int>('handled'),
      );
      expect((r.value as Err<int>).error, 'handled');
    });

    test('Resolvable() factory runs onFinalize', () {
      var ran = false;
      final r = Resolvable<int>(() => 1, onFinalize: () => ran = true);
      expect(ran, true);
      expect((r.value as Ok<int>).value, 1);
    });

    test('Resolvable() factory absorbs onFinalize throws into Err', () {
      final r = Resolvable<int>(
        () => 1,
        onFinalize: () => throw StateError('cleanup failed'),
      );
      expect(r.value, isA<Err<int>>());
    });

    test('asResolvable returns same instance', () {
      final s = Sync.okValue(1);
      expect(identical(s.asResolvable(), s), true);
    });

    test('isSync / isAsync abstract methods are dispatched', () {
      expect(Sync.okValue(1).isSync(), true);
      expect(Sync.okValue(1).isAsync(), false);
      expect(Async<int>(() async => 1).isSync(), false);
      expect(Async<int>(() async => 1).isAsync(), true);
    });

    test('sync() returns Ok on Sync, Err on Async', () {
      expect(Sync.okValue(1).sync(), isA<Ok<Sync<int>>>());
      expect(Async<int>(() async => 1).sync(), isA<Err<Sync<int>>>());
    });

    test('async() returns Ok on Async, Err on Sync', () {
      expect(Sync.okValue(1).async(), isA<Err<Async<int>>>());
      expect(Async<int>(() async => 1).async(), isA<Ok<Async<int>>>());
    });

    test('ifSync side-effect runs on Sync only', () {
      var ranOnSync = 0;
      var ranOnAsync = 0;
      Sync.okValue(1).ifSync((self, s) => ranOnSync++);
      Async<int>(() async => 1).ifSync((self, s) => ranOnAsync++);
      expect(ranOnSync, 1);
      expect(ranOnAsync, 0);
    });

    test('ifAsync side-effect runs on Async only', () {
      var ranOnSync = 0;
      var ranOnAsync = 0;
      Sync.okValue(1).ifAsync((self, a) => ranOnSync++);
      Async<int>(() async => 1).ifAsync((self, a) => ranOnAsync++);
      expect(ranOnSync, 0);
      expect(ranOnAsync, 1);
    });

    test('mapSync transforms inner Sync', () {
      final s = Sync.okValue(1).mapSync(
        (sync) => Sync.okValue(sync.value.unwrap() + 9),
      );
      expect((s.value as Ok<int>).value, 10);
    });

    test('mapAsync transforms inner Async', () async {
      final a = Async<int>(() async => 1)
          .mapAsync((async) => Async<int>(() async => 42));
      final result = await a.value;
      expect(result.unwrap(), 42);
    });

    test('ifOk runs side-effect on Ok', () {
      var count = 0;
      Sync.okValue(2).ifOk((self, ok) => count++);
      Sync<int>.errValue('e').ifOk((self, ok) => count++);
      expect(count, 1);
    });

    test('ifErr runs side-effect on Err', () {
      var count = 0;
      Sync.okValue(2).ifErr((self, err) => count++);
      Sync<int>.errValue('e').ifErr((self, err) => count++);
      expect(count, 1);
    });

    test('resultMap maps inner Result', () {
      final mapped = Sync.okValue(2).resultMap<int>((r) => Ok(r.unwrap() * 5));
      expect((mapped.value as Ok<int>).value, 10);
    });

    test('mapFutureOr maps with FutureOr<R> result', () async {
      final r = Sync.okValue(2).mapFutureOr<int>((v) async => v + 8);
      final result = await r.value;
      expect(result.unwrap(), 10);
    });

    test('fold dispatches to onSync vs onAsync', () async {
      final s = Sync.okValue(1).fold(
        (sync) => Sync.okValue('sync'),
        (async) => Sync.okValue('async'),
      );
      final a = Async<int>(() async => 1).fold(
        (sync) => Sync.okValue('sync'),
        (async) => Sync.okValue('async'),
      );
      expect((await s.value).unwrap(), 'sync');
      expect((await a.value).unwrap(), 'async');
    });

    test('foldResult dispatches to onOk vs onErr', () async {
      final ok = Sync.okValue(1).foldResult(
        (o) => const Ok<String>('was-ok'),
        (e) => const Ok<String>('was-err'),
      );
      final err = Sync<int>.errValue('x').foldResult(
        (o) => const Ok<String>('was-ok'),
        (e) => const Ok<String>('was-err'),
      );
      expect((ok.value).unwrap(), 'was-ok');
      expect((err.value).unwrap(), 'was-err');
    });

    test('withMinDuration(null) returns same instance', () {
      final s = Sync.okValue(1);
      expect(identical(s.withMinDuration(null), s), true);
    });

    test('withMinDuration enforces minimum elapsed time', () async {
      final start = DateTime.now();
      final r = Sync.okValue(1).withMinDuration(
        const Duration(milliseconds: 60),
      );
      final result = await r.value;
      final elapsed = DateTime.now().difference(start).inMilliseconds;
      expect(result.unwrap(), 1);
      expect(elapsed >= 55, true);
    });

    test('toAsync converts Sync to Async', () async {
      final a = Sync.okValue(1).toAsync();
      expect(a, isA<Async<int>>());
      expect((await a.value).unwrap(), 1);
    });

    test('orNull returns Future of Ok value or null on Err', () async {
      expect(await Sync.okValue(1).orNull(), 1);
      expect(await Sync<int>.errValue('e').orNull(), isNull);
      expect(await Async<int>(() async => 2).orNull(), 2);
    });

    test('syncOr returns self when Sync, other when Async', () {
      final s = Sync.okValue(1);
      final a = Async<int>(() async => 2);
      final fallback = Sync.okValue(99);
      expect(identical(s.syncOr(fallback), s), true);
      expect(identical(a.syncOr(fallback), fallback), true);
    });

    test('asyncOr returns self when Async, other when Sync', () {
      final s = Sync.okValue(1);
      final a = Async<int>(() async => 2);
      final fallback = Async<int>(() async => 99);
      expect(identical(a.asyncOr(fallback), a), true);
      expect(identical(s.asyncOr(fallback), fallback), true);
    });

    test('okOr returns self on Ok, other on Err', () async {
      final ok = Sync.okValue(1);
      final err = Sync<int>.errValue('boom');
      final other = Sync.okValue(99);
      expect((await ok.okOr(other).value).unwrap(), 1);
      expect((await err.okOr(other).value).unwrap(), 99);
    });

    test('errOr returns self on Err, other on Ok', () async {
      final ok = Sync.okValue(1);
      final err = Sync<int>.errValue('boom');
      final other = Sync.okValue(99);
      final errOut = await err.errOr(other).value;
      expect(errOut, isA<Err<int>>());
      expect((await ok.errOr(other).value).unwrap(), 99);
    });

    test('ok() returns Option<Ok<T>>', () async {
      final s1 = Sync.okValue(1).ok();
      final s2 = Sync<int>.errValue('e').ok();
      expect(s1, isA<Some<Ok<int>>>());
      expect(s2, isA<None<Ok<int>>>());
      final a1 = await Async<int>(() async => 1).ok();
      expect(a1, isA<Some<Ok<int>>>());
    });

    test('err() returns Option<Err<T>>', () async {
      expect(Sync.okValue(1).err(), isA<None<Err<int>>>());
      expect(Sync<int>.errValue('e').err(), isA<Some<Err<int>>>());
      final a1 = await Async<int>(() async => 1).err();
      expect(a1, isA<None<Err<int>>>());
    });

    test('unwrap returns value or throws Err', () async {
      expect(Sync.okValue(1).unwrap(), 1);
      expect(await Async<int>(() async => 2).unwrap(), 2);
      expect(() => Sync<int>.errValue('e').unwrap(), throwsA(isA<Err>()));
    });

    test('unwrapOr returns value or fallback', () async {
      expect(Sync.okValue(1).unwrapOr(99), 1);
      expect(Sync<int>.errValue('e').unwrapOr(99), 99);
      expect(await Async<int>(() async => 2).unwrapOr(99), 2);
    });

    test('map transforms Ok value', () async {
      expect((Sync.okValue(2).map((v) => v + 1).value as Ok<int>).value, 3);
      final a = Async<int>(() async => 2).map((v) => v + 1);
      expect((await a.value).unwrap(), 3);
    });

    test('then chains on the Resolvable interface', () async {
      // `Sync.then` is `@protected` but the base `Resolvable.then` is public —
      // call via the base type to verify dispatch.
      final Resolvable<int> s = Sync.okValue(2);
      final s2 = s.then((v) => v + 1);
      expect((s2.value as Ok<int>).value, 3);
      final Resolvable<int> a = Async<int>(() async => 2);
      final a2 = a.then((v) => v + 1);
      expect((await a2.value).unwrap(), 3);
    });

    test('flatMap chains and short-circuits Err', () async {
      final ok = Sync.okValue(2).flatMap((v) => Sync.okValue(v + 10));
      expect((ok.value as Ok<int>).value, 12);
      final err = Sync<int>.errValue('e').flatMap(
        (v) => Sync.okValue(v + 10),
      );
      expect(err.value, isA<Err>());
      final a = Async<int>(() async => 3).flatMap(
        (v) => Async<int>(() async => v * 2),
      );
      expect((await a.value).unwrap(), 6);
    });

    test('whenComplete runs continuation on Ok', () {
      var ran = 0;
      final r = Sync.okValue(1).whenComplete<int>((s) {
        ran++;
        return Sync.okValue(s.value.unwrap() + 100);
      });
      expect(ran, 1);
      expect((r.value as Ok<int>).value, 101);
    });

    test('transf casts T to R, failures become Err', () {
      final ok = Sync<Object>.okValue(42).transf<int>();
      expect((ok.value as Ok<int>).value, 42);
      final bad = Sync<Object>.okValue('not-int').transf<int>();
      expect(bad.value, isA<Err<int>>());
    });
  });
}
