import 'dart:async';

import 'package:df_safer_dart/df_safer_dart.dart';
import 'package:test/test.dart';

void main() {
  group('_async', () {
    test('Async.combine2 produces Ok tuple when both Ok', () async {
      final a = Async.combine2(
        Async<int>(() async => 1),
        Async<String>(() async => 'a'),
      );
      final result = await a.value;
      expect(result.unwrap(), (1, 'a'));
    });

    test('Async.combine2 short-circuits to Err', () async {
      final a = Async.combine2<int, int>(
        Async<int>(() async => 1),
        Async<int>(() async => throw StateError('e')),
      );
      final result = await a.value;
      expect(result, isA<Err>());
    });

    test('Async.combine2 onErr combiner is invoked on failure', () async {
      final a = Async.combine2<int, int>(
        Async<int>(() async => throw StateError('e1')),
        Async<int>(() async => throw StateError('e2')),
        (l, r) => Err<(int, int)>('combined'),
      );
      final result = await a.value;
      expect(result, isA<Err<(int, int)>>());
      expect((result as Err<(int, int)>).error, 'combined');
    });

    test('Async.combine3 produces Ok tuple when all Ok', () async {
      final a = Async.combine3(
        Async<int>(() async => 1),
        Async<String>(() async => 'x'),
        Async<bool>(() async => true),
      );
      final result = await a.value;
      expect(result.unwrap(), (1, 'x', true));
    });

    test('Async.combine3 short-circuits to Err', () async {
      final a = Async.combine3<int, int, int>(
        Async<int>(() async => 1),
        Async<int>(() async => throw StateError('e')),
        Async<int>(() async => 3),
      );
      final result = await a.value;
      expect(result, isA<Err>());
    });

    test('value getter always returns a Future<Result<T>>', () async {
      final v = Async<int>(() async => 7).value;
      expect(v, isA<Future<Result<int>>>());
      expect((await v).unwrap(), 7);
    });

    test('value getter wraps a sync Result when constructed via toAsync',
        () async {
      final a = Sync.okValue(3).toAsync();
      final v = a.value;
      expect(v, isA<Future<Result<int>>>());
      expect((await v).unwrap(), 3);
    });

    test('Async.result constructor accepts FutureOr<Result<T>>', () async {
      final a = Async<int>.result(Future.value(const Ok(5)));
      expect((await a.value).unwrap(), 5);
    });

    test('Async.ok constructor accepts FutureOr<Ok<T>>', () async {
      final a = Async<int>.ok(Future.value(const Ok(6)));
      expect((await a.value).unwrap(), 6);
    });

    test('Async.okValue wraps a value as Ok', () async {
      final a = Async<int>.okValue(Future.value(7));
      expect((await a.value).unwrap(), 7);
    });

    test('Async.err constructor accepts FutureOr<Err<T>>', () async {
      final a = Async<int>.err(Future.value(Err<int>('boom')));
      expect(await a.value, isA<Err<int>>());
    });

    test('Async.errValue constructs an Err from FutureOr error record',
        () async {
      final a = Async<int>.errValue(
        Future.value((error: 'boom', statusCode: 418)),
      );
      final result = await a.value;
      expect(result, isA<Err<int>>());
      expect((result as Err<int>).error, 'boom');
      expect(result.statusCode.unwrap(), 418);
    });

    test('Async() factory invokes the closure eagerly (microtask)', () async {
      var count = 0;
      final a = Async<int>(() async {
        count++;
        return 1;
      });
      // Async.result schedules the closure immediately; awaiting `.value`
      // drains the microtask queue. The closure is invoked exactly once.
      (await a.value).end();
      expect(count, 1);
    });

    test('Async() factory absorbs thrown errors into Err', () async {
      final a = Async<int>(() async => throw StateError('boom'));
      final result = await a.value;
      expect(result, isA<Err<int>>());
    });

    test('Async() factory preserves user-thrown Err verbatim', () async {
      final a = Async<int>(() async => throw Err<String>('keep me'));
      final result = await a.value;
      expect(result, isA<Err<int>>());
      expect((result as Err<int>).error, 'keep me');
    });

    test('Async() factory routes non-Err throw via onError', () async {
      final a = Async<int>(
        () async => throw StateError('boom'),
        onError: (_, __) => Err<int>('handled'),
      );
      final result = await a.value;
      expect((result as Err<int>).error, 'handled');
    });

    test('Async() factory runs onFinalize and absorbs its throws', () async {
      var ran = 0;
      final ok = Async<int>(() async => 1, onFinalize: () => ran++);
      expect((await ok.value).unwrap(), 1);
      expect(ran, 1);
      final bad = Async<int>(
        () async => 1,
        onFinalize: () => throw StateError('cleanup'),
      );
      expect(await bad.value, isA<Err<int>>());
    });

    test('isSync returns false', () {
      expect(Async<int>(() async => 1).isSync(), false);
    });

    test('isAsync returns true', () {
      expect(Async<int>(() async => 1).isAsync(), true);
    });

    test('sync() returns Err describing the misuse', () {
      final wrapped = Async<int>(() async => 1).sync();
      expect(wrapped, isA<Err<Sync<int>>>());
    });

    test('async() returns Ok wrapping self', () {
      final a = Async<int>(() async => 1);
      final wrapped = a.async();
      expect(wrapped, isA<Ok<Async<int>>>());
      expect(identical(wrapped.unwrap(), a), true);
    });

    test('ifSync is a no-op on Async', () {
      var ran = 0;
      final a = Async<int>(() async => 1);
      final out = a.ifSync((_, __) => ran++);
      expect(ran, 0);
      expect(identical(out, a), true);
    });

    test('ifAsync runs callback and absorbs throws into Err', () async {
      var ran = 0;
      final a = Async<int>(() async => 1).ifAsync((_, __) => ran++);
      expect(ran, 1);
      expect((await a.value).unwrap(), 1);
      final bad = Async<int>(() async => 1).ifAsync(
        (_, __) => throw StateError('boom'),
      );
      expect(await bad.value, isA<Err<int>>());
    });

    test('ifOk runs callback on Ok, propagates Err', () async {
      var ran = 0;
      final ok = Async<int>(() async => 1).ifOk((_, __) => ran++);
      expect((await ok.value).unwrap(), 1);
      expect(ran, 1);
      ran = 0;
      final err = Async<int>(() async => throw StateError('e')).ifOk(
        (_, __) => ran++,
      );
      expect(await err.value, isA<Err<int>>());
      expect(ran, 0);
    });

    test('ifErr runs callback on Err, propagates Ok', () async {
      var ran = 0;
      final ok = Async<int>(() async => 1).ifErr((_, __) => ran++);
      expect((await ok.value).unwrap(), 1);
      expect(ran, 0);
      ran = 0;
      final err = Async<int>(() async => throw StateError('e')).ifErr(
        (_, __) => ran++,
      );
      expect(await err.value, isA<Err<int>>());
      expect(ran, 1);
    });

    test('resultMap maps inner Result on Ok, short-circuits on Err', () async {
      final a = Async<int>(() async => 2).resultMap<int>(
        (r) => Ok(r.unwrap() * 5),
      );
      expect((await a.value).unwrap(), 10);
      final err = Async<int>(() async => throw StateError('e')).resultMap<int>(
        (r) => Ok(r.unwrap() * 5),
      );
      expect(await err.value, isA<Err<int>>());
    });

    test('mapFutureOr returns Async with awaited value', () async {
      final a = Async<int>(() async => 2).mapFutureOr<int>((v) => v + 10);
      expect(a, isA<Async<int>>());
      expect((await a.value).unwrap(), 12);
      final b = Async<int>(() async => 2).mapFutureOr<int>(
        (v) async => v + 100,
      );
      expect((await b.value).unwrap(), 102);
    });

    test('fold invokes onAsync, absorbs throws', () async {
      final a = Async<int>(() async => 1).fold(
        (_) => Sync.okValue('sync-branch'),
        (_) => Sync.okValue('async-branch'),
      );
      expect((await a.value).unwrap(), 'async-branch');
      final bad = Async<int>(() async => 1).fold(
        (_) => Sync.okValue('sync-branch'),
        (_) => throw StateError('boom'),
      );
      expect(await bad.value, isA<Err>());
    });

    test('foldResult dispatches Ok branch; Err short-circuits via resultMap',
        () async {
      final ok = Async<int>(() async => 1).foldResult(
        (o) => const Ok<String>('was-ok'),
        (e) => const Ok<String>('was-err'),
      );
      expect((await ok.value).unwrap(), 'was-ok');
      // foldResult is implemented via resultMap which short-circuits on Err
      // before reaching e.fold, so an Err input propagates unchanged.
      final err = Async<int>(() async => throw StateError('e')).foldResult(
        (o) => const Ok<String>('was-ok'),
        (e) => const Ok<String>('was-err'),
      );
      expect(await err.value, isA<Err>());
    });

    test('toAsync returns self (identity)', () {
      final a = Async<int>(() async => 1);
      expect(identical(a.toAsync(), a), true);
    });

    test('orNull returns Future<T?>', () async {
      expect(await Async<int>(() async => 1).orNull(), 1);
      expect(
        await Async<int>(() async => throw StateError('e')).orNull(),
        isNull,
      );
    });

    test('syncOr returns other when Async', () {
      final a = Async<int>(() async => 1);
      final fb = Sync.okValue(99);
      expect(identical(a.syncOr(fb), fb), true);
    });

    test('asyncOr returns this', () {
      final a = Async<int>(() async => 1);
      final fb = Async<int>(() async => 99);
      expect(identical(a.asyncOr(fb), a), true);
    });

    test('okOr returns Ok-value if Ok, otherwise other.value', () async {
      final ok = Async<int>(() async => 1);
      final err = Async<int>(() async => throw StateError('e'));
      final fb = Sync.okValue(99);
      expect((await ok.okOr(fb).value).unwrap(), 1);
      expect((await err.okOr(fb).value).unwrap(), 99);
    });

    test('errOr returns Err if Err, otherwise other.value', () async {
      final ok = Async<int>(() async => 1);
      final err = Async<int>(() async => throw StateError('e'));
      final fb = Sync.okValue(99);
      expect(await err.errOr(fb).value, isA<Err>());
      expect((await ok.errOr(fb).value).unwrap(), 99);
    });

    test('ok() returns Future<Option<Ok<T>>>', () async {
      expect(await Async<int>(() async => 1).ok(), isA<Some<Ok<int>>>());
      expect(
        await Async<int>(() async => throw StateError('e')).ok(),
        isA<None<Ok<int>>>(),
      );
    });

    test('err() returns Future<Option<Err<T>>>', () async {
      expect(await Async<int>(() async => 1).err(), isA<None<Err<int>>>());
      expect(
        await Async<int>(() async => throw StateError('e')).err(),
        isA<Some<Err<int>>>(),
      );
    });

    test('unwrap returns Future<T> or throws Err', () async {
      expect(await Async<int>(() async => 1).unwrap(), 1);
      await expectLater(
        Async<int>(() async => throw StateError('e')).unwrap(),
        throwsA(isA<Err>()),
      );
    });

    test('unwrapOr returns value or fallback', () async {
      expect(await Async<int>(() async => 1).unwrapOr(99), 1);
      expect(
        await Async<int>(() async => throw StateError('e')).unwrapOr(99),
        99,
      );
    });

    test('map transforms Ok value, returns Async<R>', () async {
      final a = Async<int>(() async => 2).map((v) => v + 1);
      expect(a, isA<Async<int>>());
      expect((await a.value).unwrap(), 3);
    });

    test('then chains and absorbs synchronous throws into Err', () async {
      final a = Async<int>(() async => 2).then((v) => v + 1);
      expect((await a.value).unwrap(), 3);
      final bad = Async<int>(() async => 2).then<int>(
        (_) => throw StateError('boom'),
      );
      expect(await bad.value, isA<Err<int>>());
    });

    test('whenComplete runs continuation on Ok, surfaces Err', () async {
      var ran = 0;
      final ok = Async<int>(() async => 1).whenComplete<int>((s) {
        ran++;
        return Sync.okValue(s.value.unwrap() + 10);
      });
      expect((await ok.value).unwrap(), 11);
      expect(ran, 1);

      ran = 0;
      final err =
          Async<int>(() async => throw StateError('e')).whenComplete<int>((s) {
        ran++;
        return Sync.okValue(99);
      });
      expect(await err.value, isA<Err<int>>());
      expect(ran, 0);
    });

    test('transf casts T to R, failures become Err', () async {
      final ok = Async<Object>(() async => 42).transf<int>();
      expect((await ok.value).unwrap(), 42);
      final bad = Async<Object>(() async => 'not-int').transf<int>();
      expect(await bad.value, isA<Err<int>>());
    });

    test('end() returns void synchronously without throwing', () {
      expect(() => Async<int>(() async => 1).end(), returnsNormally);
      expect(
        () => Async<int>(() async => throw StateError('e')).end(),
        returnsNormally,
      );
    });
  });
}
