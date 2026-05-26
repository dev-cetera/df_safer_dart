import 'package:df_safer_dart/df_safer_dart.dart';
import 'package:test/test.dart';

void main() {
  group('_result', () {
    test('Result.combine2 — all Ok produces tuple', () {
      const r1 = Ok<int>(1);
      const r2 = Ok<String>('two');
      final combined = Result.combine2<int, String>(r1, r2);
      expect(combined.isOk(), isTrue);
      expect(combined.unwrap(), (1, 'two'));
    });

    test('Result.combine2 — Err short-circuits without onErr', () {
      final r1 = Err<int>('boom');
      const r2 = Ok<String>('two');
      final combined = Result.combine2<int, String>(r1, r2);
      expect(combined.isErr(), isTrue);
    });

    test('Result.combine2 — custom onErr is invoked', () {
      final r1 = Err<int>('e1');
      final r2 = Err<String>('e2');
      var called = false;
      final combined = Result.combine2<int, String>(
        r1,
        r2,
        (a, b) {
          called = true;
          return Err<(int, String)>('joined');
        },
      );
      expect(called, isTrue);
      expect(combined.isErr(), isTrue);
      final err = combined.err().unwrap();
      expect(err.error, 'joined');
    });

    test('Result.combine3 — all Ok produces tuple', () {
      const r1 = Ok<int>(1);
      const r2 = Ok<String>('two');
      const r3 = Ok<bool>(true);
      final combined = Result.combine3<int, String, bool>(r1, r2, r3);
      expect(combined.isOk(), isTrue);
      expect(combined.unwrap(), (1, 'two', true));
    });

    test('Result.combine3 — first Err short-circuits', () {
      final r1 = Err<int>('boom');
      const r2 = Ok<String>('two');
      const r3 = Ok<bool>(true);
      final combined = Result.combine3<int, String, bool>(r1, r2, r3);
      expect(combined.isErr(), isTrue);
    });

    test('Result.combine3 — custom onErr is invoked', () {
      final r1 = Err<int>('e1');
      const r2 = Ok<String>('two');
      final r3 = Err<bool>('e3');
      final combined = Result.combine3<int, String, bool>(
        r1,
        r2,
        r3,
        (a, b, c) => Err<(int, String, bool)>('joined'),
      );
      expect(combined.isErr(), isTrue);
      expect(combined.err().unwrap().error, 'joined');
    });

    test('asResult returns this widened to Result<T>', () {
      const ok = Ok<int>(7);
      final r = ok.asResult();
      expect(identical(r, ok), isTrue);
      expect(r, isA<Result<int>>());
    });

    test('isOk / isErr discriminate Ok vs Err', () {
      const Result<int> ok = Ok<int>(1);
      final Result<int> err = Err<int>('x');
      expect(ok.isOk(), isTrue);
      expect(ok.isErr(), isFalse);
      expect(err.isOk(), isFalse);
      expect(err.isErr(), isTrue);
    });

    test('ifOk / ifErr — base abstract members reachable via subtypes', () {
      var okCalls = 0;
      var errCalls = 0;
      const Result<int> ok = Ok<int>(1);
      final Result<int> err = Err<int>('x');
      ok.ifOk((_, __) => okCalls++).end();
      ok.ifErr((_, __) => errCalls++).end();
      err.ifOk((_, __) => okCalls++).end();
      err.ifErr((_, __) => errCalls++).end();
      expect(okCalls, 1);
      expect(errCalls, 1);
    });

    test('err() / ok() — Option projections', () {
      const Result<int> ok = Ok<int>(7);
      final Result<int> err = Err<int>('boom');
      expect(ok.ok(), isA<Some<Ok<int>>>());
      expect(ok.err(), isA<None<Err<int>>>());
      expect(err.ok(), isA<None<Ok<int>>>());
      expect(err.err(), isA<Some<Err<int>>>());
    });

    test('orNull — Ok returns value, Err returns null', () {
      const Result<int> ok = Ok<int>(7);
      final Result<int> err = Err<int>('boom');
      expect(ok.orNull(), 7);
      expect(err.orNull(), isNull);
    });

    test('flatMap — Ok chains, Err short-circuits', () {
      const Result<int> ok = Ok<int>(2);
      final Result<int> err = Err<int>('boom');
      final r1 = ok.flatMap<int>((v) => Ok(v * 3));
      final r2 = err.flatMap<int>((v) => Ok(v * 3));
      expect(r1.unwrap(), 6);
      expect(r2.isErr(), isTrue);
    });

    test('mapOk — only Ok transforms', () {
      const Result<int> ok = Ok<int>(2);
      final Result<int> err = Err<int>('boom');
      final r1 = ok.mapOk((o) => Ok<int>(o.value + 10));
      final r2 = err.mapOk((o) => Ok<int>(o.value + 10));
      expect(r1.unwrap(), 12);
      expect(r2.isErr(), isTrue);
    });

    test('mapErr — only Err transforms', () {
      const Result<int> ok = Ok<int>(2);
      final Result<int> err = Err<int>('boom');
      final r1 = ok.mapErr((e) => Err<int>('replaced'));
      final r2 = err.mapErr((e) => Err<int>('replaced'));
      expect(r1.unwrap(), 2);
      expect(r2.err().unwrap().error, 'replaced');
    });

    test('fold — invokes correct branch', () {
      const Result<int> ok = Ok<int>(2);
      final Result<int> err = Err<int>('boom');
      final r1 = ok.fold((o) => Ok<int>(o.value + 1), (e) => null);
      final r2 = err.fold((o) => null, (e) => const Ok<int>(999));
      expect(r1, isA<Result<Object>>());
      expect(r2.unwrap(), 999);
    });

    test('okOr — Ok keeps, Err falls back', () {
      const Result<int> ok = Ok<int>(1);
      final Result<int> err = Err<int>('boom');
      const Result<int> other = Ok<int>(2);
      expect(ok.okOr(other).unwrap(), 1);
      expect(err.okOr(other).unwrap(), 2);
    });

    test('errOr — Err keeps, Ok falls back', () {
      const Result<int> ok = Ok<int>(1);
      final Result<int> err = Err<int>('boom');
      const Result<int> other = Ok<int>(2);
      expect(ok.errOr(other).unwrap(), 2);
      expect(err.errOr(other).err().unwrap().error, 'boom');
    });

    test('unwrap — Ok returns value, Err throws', () {
      const Result<int> ok = Ok<int>(7);
      final Result<int> err = Err<int>('boom');
      expect(ok.unwrap(), 7);
      expect(err.unwrap, throwsA(isA<Err<int>>()));
    });

    test('unwrapOr — Ok ignores fallback, Err uses it', () {
      const Result<int> ok = Ok<int>(7);
      final Result<int> err = Err<int>('boom');
      expect(ok.unwrapOr(42), 7);
      expect(err.unwrapOr(42), 42);
    });

    test('map — Ok transforms, Err passes through', () {
      const Result<int> ok = Ok<int>(2);
      final Result<int> err = Err<int>('boom');
      expect(ok.map<String>((v) => 'v=$v').unwrap(), 'v=2');
      expect(err.map<String>((v) => 'v=$v').isErr(), isTrue);
    });

    test('transf — widens generic; Ok casts, Err preserves', () {
      const Result<Object> ok = Ok<Object>(5);
      final Result<Object> err = Err<Object>('boom');
      expect(ok.transf<int>().unwrap(), 5);
      expect(err.transf<int>().isErr(), isTrue);
    });

    test('end — returns void without throwing', () {
      const Result<int> ok = Ok<int>(1);
      final Result<int> err = Err<int>('boom');
      expect(ok.end, returnsNormally);
      expect(err.end, returnsNormally);
    });
  });
}
