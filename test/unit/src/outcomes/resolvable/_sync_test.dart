import 'package:df_safer_dart/df_safer_dart.dart';
import 'package:test/test.dart';

void main() {
  group('_sync', () {
    test('Sync.combine2 produces Ok tuple when both Ok', () {
      final s = Sync.combine2(Sync.okValue(1), Sync.okValue('a'));
      expect((s.value as Ok<(int, String)>).value, (1, 'a'));
    });

    test('Sync.combine2 short-circuits to Err', () {
      final s = Sync.combine2<int, int>(Sync.okValue(1), Sync.errValue('e'));
      expect(s.value, isA<Err>());
    });

    test('Sync.combine2 onErr combiner is invoked on failure', () {
      final s = Sync.combine2<int, int>(
        Sync.errValue('a'),
        Sync.errValue('b'),
        (l, r) => Err<(int, int)>('combined'),
      );
      expect((s.value as Err<(int, int)>).error, 'combined');
    });

    test('Sync.combine3 produces Ok tuple when all Ok', () {
      final s = Sync.combine3(
        Sync.okValue(1),
        Sync.okValue('x'),
        Sync.okValue(true),
      );
      expect((s.value as Ok<(int, String, bool)>).value, (1, 'x', true));
    });

    test('Sync.combine3 short-circuits to Err', () {
      final s = Sync.combine3<int, int, int>(
        Sync.okValue(1),
        Sync.errValue('e'),
        Sync.okValue(3),
      );
      expect(s.value, isA<Err>());
    });

    test('value getter returns a Result<T>, never a Future', () {
      final v = Sync.okValue(7).value;
      expect(v, isA<Result<int>>());
      expect(v, isNot(isA<Future<dynamic>>()));
    });

    test('Sync.result wraps a Result', () {
      final s = Sync.result(const Ok(5));
      expect((s.value as Ok<int>).value, 5);
    });

    test('Sync.ok wraps an Ok', () {
      final s = Sync.ok(const Ok(6));
      expect((s.value as Ok<int>).value, 6);
    });

    test('Sync.okValue wraps a value as Ok', () {
      final s = Sync.okValue(7);
      expect((s.value as Ok<int>).value, 7);
    });

    test('Sync.err wraps an Err', () {
      final s = Sync.err(Err<int>('boom'));
      expect(s.value, isA<Err<int>>());
    });

    test('Sync.errValue constructs an Err from raw error', () {
      final s = Sync<int>.errValue('boom', statusCode: 500);
      expect(s.value, isA<Err<int>>());
      expect((s.value as Err<int>).error, 'boom');
      expect((s.value as Err<int>).statusCode.unwrap(), 500);
    });

    test('Sync() factory wraps return value as Ok', () {
      final s = Sync(() => 42);
      expect((s.value as Ok<int>).value, 42);
    });

    test('Sync() factory absorbs throws into Err', () {
      final s = Sync<int>(() => throw StateError('boom'));
      expect(s.value, isA<Err<int>>());
    });

    test('Sync() factory preserves user-thrown Err verbatim', () {
      final s = Sync<int>(() => throw Err<String>('keep me'));
      expect((s.value as Err<int>).error, 'keep me');
    });

    test('Sync() factory routes non-Err throw via onError', () {
      final s = Sync<int>(
        () => throw StateError('boom'),
        onError: (e, st) => Err<int>('handled'),
      );
      expect((s.value as Err<int>).error, 'handled');
    });

    test('Sync() factory runs onFinalize and absorbs its throws', () {
      var ran = 0;
      final ok = Sync(() => 1, onFinalize: () => ran++);
      expect(ran, 1);
      expect((ok.value as Ok<int>).value, 1);
      final bad = Sync<int>(
        () => 1,
        onFinalize: () => throw StateError('cleanup'),
      );
      expect(bad.value, isA<Err<int>>());
    });

    test('isSync returns true', () {
      expect(Sync.okValue(1).isSync(), true);
    });

    test('isAsync returns false', () {
      expect(Sync.okValue(1).isAsync(), false);
    });

    test('sync() returns Ok wrapping self', () {
      final s = Sync.okValue(1);
      final wrapped = s.sync();
      expect(wrapped, isA<Ok<Sync<int>>>());
      expect(identical(wrapped.unwrap(), s), true);
    });

    test('async() returns Err describing the misuse', () {
      final s = Sync.okValue(1);
      final wrapped = s.async();
      expect(wrapped, isA<Err<Async<int>>>());
    });

    test('ifSync runs callback and absorbs throws into Err', () {
      var ran = 0;
      final s = Sync.okValue(1).ifSync((self, sync) => ran++);
      expect(ran, 1);
      expect((s.value as Ok<int>).value, 1);
      final bad = Sync.okValue(1).ifSync(
        (self, sync) => throw StateError('x'),
      );
      expect(bad.value, isA<Err<int>>());
    });

    test('ifAsync is a no-op on Sync', () {
      var ran = 0;
      final s = Sync.okValue(1);
      final out = s.ifAsync((self, async) => ran++);
      expect(ran, 0);
      expect(identical(out, s), true);
    });

    test('mapSync transforms the Sync, absorbs throws', () {
      final s = Sync.okValue(1).mapSync(
        (self) => Sync.okValue(self.value.unwrap() * 3),
      );
      expect((s.value as Ok<int>).value, 3);
      final bad = Sync.okValue(1).mapSync(
        (self) => throw StateError('boom'),
      );
      expect(bad.value, isA<Err<int>>());
    });

    test('mapAsync is a no-op on Sync', () {
      final s = Sync.okValue(1);
      final out = s.mapAsync((a) => Async<int>(() async => 99));
      expect(identical(out, s), true);
    });

    test('flatMap chains, returns Err of unchanged when receiver is Err', () {
      final ok = Sync.okValue(2).flatMap((v) => Sync.okValue(v + 1));
      expect((ok.value as Ok<int>).value, 3);
      final err = Sync<int>.errValue('e').flatMap((v) => Sync.okValue(v + 1));
      expect(err.value, isA<Err>());
      final thrown = Sync.okValue(2).flatMap<int>(
        (v) => throw StateError('boom'),
      );
      expect(thrown.value, isA<Err<int>>());
    });

    test('ifOk side-effect on Ok, no-op on Err', () {
      var ran = 0;
      Sync.okValue(2).ifOk((self, ok) => ran++);
      Sync<int>.errValue('e').ifOk((self, ok) => ran++);
      expect(ran, 1);
    });

    test('ifErr side-effect on Err, no-op on Ok', () {
      var ran = 0;
      Sync.okValue(2).ifErr((self, err) => ran++);
      Sync<int>.errValue('e').ifErr((self, err) => ran++);
      expect(ran, 1);
    });

    test('resultMap maps inner Result, absorbs throws', () {
      final ok = Sync.okValue(2).resultMap<int>((r) => Ok(r.unwrap() * 5));
      expect((ok.value as Ok<int>).value, 10);
      final bad = Sync.okValue(2).resultMap<int>(
        (r) => throw StateError('boom'),
      );
      expect(bad.value, isA<Err<int>>());
    });

    test('mapFutureOr returns Sync for sync mapper, Async for Future mapper',
        () async {
      final s = Sync.okValue(2).mapFutureOr<int>((v) => v + 1);
      expect(s, isA<Sync<int>>());
      expect((s.value as Ok<int>).value, 3);
      final a = Sync.okValue(2).mapFutureOr<int>((v) async => v + 5);
      expect(a, isA<Async<int>>());
      expect((await a.value).unwrap(), 7);
    });

    test('fold invokes onSync, absorbs throws', () {
      final s = Sync.okValue(1).fold(
        (sync) => Sync.okValue('sync-branch'),
        (async) => Sync.okValue('async-branch'),
      );
      // fold's inferred R is Object since branches return different generic
      // arguments — runtime payload is Ok<Object> wrapping a String.
      expect((s.value as Ok).value, 'sync-branch');
      final bad = Sync.okValue(1).fold(
        (sync) => throw StateError('boom'),
        (async) => Sync.okValue('async-branch'),
      );
      expect(bad.value, isA<Err>());
    });

    test('foldResult dispatches by Result variant', () {
      final ok = Sync.okValue(1).foldResult(
        (o) => const Ok<String>('was-ok'),
        (e) => const Ok<String>('was-err'),
      );
      expect((ok.value as Ok<String>).value, 'was-ok');
      final err = Sync<int>.errValue('e').foldResult(
        (o) => const Ok<String>('was-ok'),
        (e) => const Ok<String>('was-err'),
      );
      expect((err.value as Ok<String>).value, 'was-err');
    });

    test('toAsync converts to Async wrapping same Result', () async {
      final a = Sync.okValue(1).toAsync();
      expect(a, isA<Async<int>>());
      expect((await a.value).unwrap(), 1);
    });

    test('orNull returns Future<T?>', () async {
      expect(await Sync.okValue(1).orNull(), 1);
      expect(await Sync<int>.errValue('e').orNull(), isNull);
    });

    test('syncOr returns this', () {
      final s = Sync.okValue(1);
      final fb = Sync.okValue(99);
      expect(identical(s.syncOr(fb), s), true);
    });

    test('asyncOr returns other', () {
      final s = Sync.okValue(1);
      final fb = Async<int>(() async => 99);
      expect(identical(s.asyncOr(fb), fb), true);
    });

    test('okOr returns this on Ok, other on Err', () {
      final ok = Sync.okValue(1);
      final err = Sync<int>.errValue('e');
      final fb = Sync.okValue(99);
      expect(identical(ok.okOr(fb), ok), true);
      expect(identical(err.okOr(fb), fb), true);
    });

    test('errOr returns this on Err, other on Ok', () {
      final ok = Sync.okValue(1);
      final err = Sync<int>.errValue('e');
      final fb = Sync.okValue(99);
      expect(identical(err.errOr(fb), err), true);
      expect(identical(ok.errOr(fb), fb), true);
    });

    test('ok() returns Option<Ok<T>>', () {
      expect(Sync.okValue(1).ok(), isA<Some<Ok<int>>>());
      expect(Sync<int>.errValue('e').ok(), isA<None<Ok<int>>>());
    });

    test('err() returns Option<Err<T>>', () {
      expect(Sync.okValue(1).err(), isA<None<Err<int>>>());
      expect(Sync<int>.errValue('e').err(), isA<Some<Err<int>>>());
    });

    test('unwrap returns value or throws Err', () {
      expect(Sync.okValue(1).unwrap(), 1);
      expect(() => Sync<int>.errValue('e').unwrap(), throwsA(isA<Err>()));
    });

    test('unwrapOr returns value or fallback', () {
      expect(Sync.okValue(1).unwrapOr(99), 1);
      expect(Sync<int>.errValue('e').unwrapOr(99), 99);
    });

    test('map transforms Ok value, returns Sync<R>', () {
      final s = Sync.okValue(2).map((v) => v + 1);
      expect(s, isA<Sync<int>>());
      expect((s.value as Ok<int>).value, 3);
    });

    test('then delegates to map (callable via Resolvable interface)', () {
      // `Sync.then` is `@protected`; call through the public base type.
      final Resolvable<int> s = Sync.okValue(2);
      final out = s.then((v) => v + 1);
      expect(out, isA<Sync<int>>());
      expect((out.value as Ok<int>).value, 3);
    });

    test('whenComplete runs continuation on Ok, short-circuits on Err', () {
      var ran = 0;
      final ok = Sync.okValue(1).whenComplete<int>((s) {
        ran++;
        return Sync.okValue(s.value.unwrap() + 10);
      });
      expect(ran, 1);
      expect((ok.value as Ok<int>).value, 11);

      ran = 0;
      final err = Sync<int>.errValue('e').whenComplete<int>((s) {
        ran++;
        return Sync.okValue(99);
      });
      expect(ran, 0);
      expect(err.value, isA<Err<int>>());
    });

    test('transf casts T to R, failures become Err', () {
      final ok = Sync<Object>.okValue(42).transf<int>();
      expect((ok.value as Ok<int>).value, 42);
      final bad = Sync<Object>.okValue('not-int').transf<int>();
      expect(bad.value, isA<Err<int>>());
    });

    test('end() returns void without throwing', () {
      expect(() => Sync.okValue(1).end(), returnsNormally);
      expect(() => Sync<int>.errValue('e').end(), returnsNormally);
    });
  });
}
