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

// Locks in the medical-grade contract that **a user-thrown `Err` is
// preserved verbatim** through every absorbing method on `Sync`/`Async`.
//
// These methods distinguish `on Err catch (err)` from generic
// `catch (error, stackTrace)` so that a user `throw Err('boom', statusCode:
// 404)` arrives at the consumer with statusCode + breadcrumbs + stack trace
// intact. A naïve `try { … } catch (error, stackTrace) { Err<T>(error, …) }`
// form would drop all of that — wrapping the original `Err` inside another
// `Err`, hiding statusCode / breadcrumbs / original stack from the consumer.
//
// In life-critical pipelines a lost statusCode can change the operator's
// response (e.g. retry vs. escalate), so these tests are non-negotiable.
//
// The Lazy tests use inline lambdas (which the `@sendable` lint flags)
// because they exercise local construct-fault behaviour, not isolate
// sendability.
// ignore_for_file: sendable, unnecessary_lambdas

import 'package:df_safer_dart/df_safer_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Sync.ifSync — Err preservation', () {
    test('user-thrown Err with statusCode is preserved verbatim', () {
      final s = Sync.okValue(1).ifSync((_, __) {
        throw Err<int>('clinical-alarm', statusCode: 503);
      });
      expect(s.value, isA<Err<int>>());
      final err = s.value as Err<int>;
      expect(err.error, 'clinical-alarm');
      expect(
        err.statusCode.unwrap(),
        503,
        reason: 'statusCode must survive — drops would mis-trigger alarms',
      );
    });

    test('non-Err throw is wrapped (existing behaviour)', () {
      final s = Sync.okValue(1).ifSync((_, __) {
        throw StateError('boom');
      });
      expect(s.value, isA<Err<int>>());
      expect((s.value as Err).error, isA<StateError>());
    });
  });

  group('Sync.ifOk — Err preservation', () {
    test('user-thrown Err with statusCode is preserved verbatim', () {
      final s = Sync.okValue(1).ifOk((_, __) {
        throw Err<int>('sensor-fault', statusCode: 422);
      });
      expect(s, isA<Resolvable<int>>());
      final result = (s as Sync<int>).value;
      expect(result, isA<Err<int>>());
      expect((result as Err<int>).statusCode.unwrap(), 422);
      expect(result.error, 'sensor-fault');
    });
  });

  group('Sync.ifErr — Err preservation', () {
    test('user-thrown Err with statusCode replaces the original Err', () {
      final s = Sync<int>.errValue('original').ifErr((_, __) {
        throw Err<int>('escalation', statusCode: 504);
      });
      final result = (s as Sync<int>).value;
      expect(result, isA<Err<int>>());
      // The user explicitly threw a new Err — that must surface, not the
      // wrapped form.
      expect((result as Err<int>).error, 'escalation');
      expect(result.statusCode.unwrap(), 504);
    });
  });

  group('Sync.resultMap — Err preservation', () {
    test('user-thrown Err with statusCode is preserved verbatim', () {
      final s = Sync.okValue(1).resultMap<int>((_) {
        throw Err<int>('mapper-fault', statusCode: 410);
      });
      expect(s.value, isA<Err<int>>());
      expect((s.value as Err).statusCode.unwrap(), 410);
      expect((s.value as Err).error, 'mapper-fault');
    });
  });

  group('Sync.whenComplete — Err preservation', () {
    test('user-thrown Err with statusCode is preserved verbatim', () {
      final r = Sync.okValue(1).whenComplete<int>((_) {
        throw Err<int>('cleanup-fail', statusCode: 500);
      });
      // The receiver is Resolvable<int>; whenComplete on Sync returns
      // Resolvable<R> which for our throwing callback is Sync.err.
      expect(r, isA<Sync<int>>());
      final result = (r as Sync<int>).value;
      expect(result, isA<Err<int>>());
      expect((result as Err<int>).statusCode.unwrap(), 500);
      expect(result.error, 'cleanup-fail');
    });

    test('Err originating from receiver value is preserved too', () {
      final source = Sync<int>.err(
        Err<int>('upstream', statusCode: 418),
      );
      // The callback never runs because value.unwrap() throws first.
      var callbackRan = false;
      final r = source.whenComplete<int>((_) {
        callbackRan = true;
        return Sync.okValue(0);
      });
      expect(callbackRan, isFalse);
      final result = (r as Sync<int>).value;
      expect(result, isA<Err<int>>());
      expect((result as Err<int>).statusCode.unwrap(), 418);
      expect(result.error, 'upstream');
    });
  });

  group('Async.ifAsync — Err preservation', () {
    test('user-thrown Err with statusCode is preserved verbatim', () async {
      final a = Async.okValue(1).ifAsync((_, __) {
        throw Err<int>('ifAsync-fault', statusCode: 503);
      });
      final result = await a.value;
      expect(result, isA<Err<int>>());
      expect((result as Err<int>).statusCode.unwrap(), 503);
      expect(result.error, 'ifAsync-fault');
    });
  });

  // Sanity checks for the methods that go through Sync()/Async() factories
  // already — they should keep working the same way.

  group('Async.ifOk (factory-routed) — Err preservation', () {
    test('user-thrown Err preserved through Async factory', () async {
      final a = Async.okValue(1).ifOk((_, __) {
        throw Err<int>('via-async-factory', statusCode: 409);
      });
      final result = await a.value;
      expect(result, isA<Err<int>>());
      expect((result as Err<int>).statusCode.unwrap(), 409);
      expect(result.error, 'via-async-factory');
    });
  });

  group('Async.ifErr (factory-routed) — Err preservation', () {
    test('user-thrown Err preserved through Async factory', () async {
      final a = Async<int>.errValue(
        (error: 'original', statusCode: null),
      ).ifErr((_, __) {
        throw Err<int>('replacement', statusCode: 504);
      });
      final result = await a.value;
      expect(result, isA<Err<int>>());
      expect((result as Err<int>).statusCode.unwrap(), 504);
      expect(result.error, 'replacement');
    });
  });

  group('Async.whenComplete — Err preservation', () {
    test('user-thrown Err preserved through Async factory', () async {
      final a = Async.okValue(1).whenComplete<int>((_) {
        throw Err<int>('async-cleanup', statusCode: 500);
      });
      final result = await a.value;
      expect(result, isA<Err<int>>());
      expect((result as Err<int>).statusCode.unwrap(), 500);
      expect(result.error, 'async-cleanup');
    });
  });

  group('Sync.new onError — Err preservation', () {
    test('onError that throws Err preserves statusCode', () {
      final s = Sync<int>(
        () => throw StateError('primary'),
        onError: (_, __) => throw Err<int>('recovery-fault', statusCode: 503),
      );
      expect(s.value, isA<Err<int>>());
      expect((s.value as Err<int>).statusCode.unwrap(), 503);
      expect((s.value as Err<int>).error, 'recovery-fault');
    });
  });

  group('Async.new onError — Err preservation', () {
    test('onError that throws Err preserves statusCode', () async {
      final a = Async<int>(
        () async => throw StateError('primary'),
        onError: (_, __) => throw Err<int>(
          'async-recovery-fault',
          statusCode: 504,
        ),
      );
      final result = await a.value;
      expect(result, isA<Err<int>>());
      expect((result as Err<int>).statusCode.unwrap(), 504);
      expect(result.error, 'async-recovery-fault');
    });
  });

  group('Ok.map / Ok.flatMap / Ok.fold / Ok.transf — Err preservation', () {
    test('Ok.map preserves user-thrown Err statusCode', () {
      final r = const Ok<int>(1).map<int>(
        (_) => throw Err<int>('ok-map-fault', statusCode: 410),
      );
      expect(r, isA<Err<int>>());
      expect((r as Err<int>).statusCode.unwrap(), 410);
      expect(r.error, 'ok-map-fault');
    });

    test('Ok.flatMap preserves user-thrown Err statusCode', () {
      final r = const Ok<int>(1).flatMap<int>(
        (_) => throw Err<int>('ok-flatmap-fault', statusCode: 411),
      );
      expect(r, isA<Err<int>>());
      expect((r as Err<int>).statusCode.unwrap(), 411);
      expect(r.error, 'ok-flatmap-fault');
    });

    test('Ok.fold preserves user-thrown Err statusCode', () {
      final r = const Ok<int>(1).fold(
        (_) => throw Err<int>('ok-fold-fault', statusCode: 412),
        (_) => null,
      );
      expect(r, isA<Err>());
      expect((r as Err).statusCode.unwrap(), 412);
      expect(r.error, 'ok-fold-fault');
    });

    test('Ok.transf preserves user-thrown Err statusCode', () {
      final r = const Ok<int>(1).transf<int>(
        (_) => throw Err<int>('ok-transf-fault', statusCode: 413),
      );
      expect(r, isA<Err<int>>());
      expect((r as Err<int>).statusCode.unwrap(), 413);
      expect(r.error, 'ok-transf-fault');
    });
  });

  group('Some.fold / Some.transf / None.fold — Err preservation', () {
    test('Some.fold preserves user-thrown Err statusCode', () {
      final r = const Some<int>(1).fold(
        (_) => throw Err<int>('some-fold-fault', statusCode: 420),
        (_) => null,
      );
      expect(r, isA<Err>());
      final err = r as Err;
      expect(err.statusCode.unwrap(), 420);
      expect(err.error, 'some-fold-fault');
    });

    test('Some.transf preserves user-thrown Err statusCode', () {
      final r = const Some<int>(1).transf<int>(
        (_) => throw Err<int>('some-transf-fault', statusCode: 421),
      );
      expect(r, isA<Err>());
      final err = r as Err;
      expect(err.statusCode.unwrap(), 421);
      expect(err.error, 'some-transf-fault');
    });

    test('None.fold preserves user-thrown Err statusCode', () {
      final r = const None<int>().fold(
        (_) => null,
        (_) => throw Err<int>('none-fold-fault', statusCode: 430),
      );
      expect(r, isA<Err>());
      final err = r as Err;
      expect(err.statusCode.unwrap(), 430);
      expect(err.error, 'none-fold-fault');
    });
  });

  group('Resolvable.new — Err preservation', () {
    test('user-thrown Err statusCode survives Resolvable factory', () {
      final r = Resolvable<int>(
        () => throw Err<int>('resolvable-new-fault', statusCode: 599),
      );
      expect(r, isA<Sync<int>>());
      final result = (r as Sync<int>).value;
      expect(result, isA<Err<int>>());
      expect((result as Err<int>).statusCode.unwrap(), 599);
      expect(result.error, 'resolvable-new-fault');
    });

    test('non-Err throw routes through caller-provided onError', () {
      final r = Resolvable<int>(
        () => throw StateError('primary'),
        onError: (e, s) => Err<int>('handled-by-onError', statusCode: 451),
      );
      expect(r, isA<Sync<int>>());
      final result = (r as Sync<int>).value;
      expect(result, isA<Err<int>>());
      expect((result as Err<int>).error, 'handled-by-onError');
      expect(result.statusCode.unwrap(), 451);
    });

    test('onError that itself throws Err preserves statusCode', () {
      final r = Resolvable<int>(
        () => throw StateError('primary'),
        onError: (e, s) => throw Err<int>('onError-rethrow', statusCode: 452),
      );
      final result = (r as Sync<int>).value;
      expect(result, isA<Err<int>>());
      expect((result as Err<int>).error, 'onError-rethrow');
      expect(result.statusCode.unwrap(), 452);
    });

    test('onFinalize fires on every throw path', () {
      var finalizeHits = 0;
      void hit() => finalizeHits++;

      // Path 1: synchronous Err throw.
      Resolvable<int>(
        () => throw Err<int>('e'),
        onFinalize: hit,
      ).end();
      expect(finalizeHits, 1);

      // Path 2: synchronous non-Err throw, no onError.
      Resolvable<int>(
        () => throw StateError('x'),
        onFinalize: hit,
      ).end();
      expect(finalizeHits, 2);

      // Path 3: synchronous non-Err throw + onError returns Result.
      Resolvable<int>(
        () => throw StateError('x'),
        onError: (e, s) => Err<int>('handled'),
        onFinalize: hit,
      ).end();
      expect(finalizeHits, 3);

      // Path 4: onError itself throws.
      Resolvable<int>(
        () => throw StateError('x'),
        onError: (e, s) => throw StateError('y'),
        onFinalize: hit,
      ).end();
      expect(finalizeHits, 4);
    });
  });

  group('Sync.fold / Async.fold — Err preservation', () {
    test('Sync.fold preserves user-thrown Err statusCode', () {
      final r = Sync.okValue(1).fold(
        (_) => throw Err<int>('sync-fold-fault', statusCode: 460),
        (_) => null,
      );
      expect(r, isA<Sync>());
      final result = (r as Sync).value;
      expect(result, isA<Err>());
      expect((result as Err).statusCode.unwrap(), 460);
      expect(result.error, 'sync-fold-fault');
    });

    test('Async.fold preserves user-thrown Err statusCode', () async {
      final r = Async.okValue(1).fold(
        (_) => null,
        (_) => throw Err<int>('async-fold-fault', statusCode: 461),
      );
      expect(r, isA<Async>());
      final result = await (r as Async).value;
      expect(result, isA<Err>());
      expect((result as Err).statusCode.unwrap(), 461);
      expect(result.error, 'async-fold-fault');
    });
  });

  group('onFinalize that throws — absorbed, never escapes', () {
    test('Sync.new: finalize-thrown Err overrides Ok result', () {
      final s = Sync<int>(
        () => 1,
        onFinalize: () => throw Err<int>('cleanup-fault', statusCode: 503),
      );
      expect(s.value, isA<Err<int>>());
      expect((s.value as Err<int>).statusCode.unwrap(), 503);
      expect((s.value as Err<int>).error, 'cleanup-fault');
    });

    test('Sync.new: finalize-thrown non-Err overrides Ok result', () {
      final s = Sync<int>(
        () => 1,
        onFinalize: () => throw StateError('cleanup-boom'),
      );
      expect(s.value, isA<Err<int>>());
      expect((s.value as Err<int>).error, isA<StateError>());
    });

    test('Async.new: finalize-thrown Err overrides Ok result', () async {
      final a = Async<int>(
        () async => 1,
        onFinalize: () =>
            throw Err<int>('async-cleanup-fault', statusCode: 504),
      );
      final r = await a.value;
      expect(r, isA<Err<int>>());
      expect((r as Err<int>).statusCode.unwrap(), 504);
      expect(r.error, 'async-cleanup-fault');
    });

    test('Async.new: finalize-thrown non-Err overrides Ok result', () async {
      final a = Async<int>(
        () async => 1,
        onFinalize: () => throw StateError('async-cleanup-boom'),
      );
      final r = await a.value;
      expect(r, isA<Err<int>>());
      expect((r as Err<int>).error, isA<StateError>());
    });

    test('Resolvable.new: finalize-thrown Err overrides Ok result', () {
      final r = Resolvable<int>(
        () => 1,
        onFinalize: () =>
            throw Err<int>('resolvable-cleanup-fault', statusCode: 505),
      );
      final result = (r as Sync<int>).value;
      expect(result, isA<Err<int>>());
      expect((result as Err<int>).statusCode.unwrap(), 505);
      expect(result.error, 'resolvable-cleanup-fault');
    });

    test('Resolvable.new with sync throw: finalize-throw still absorbed', () {
      final r = Resolvable<int>(
        () => throw StateError('primary'),
        onFinalize: () => throw Err<int>('finalize-fault', statusCode: 506),
      );
      final result = (r as Sync<int>).value;
      expect(result, isA<Err<int>>());
      // Finalize error overrides the primary StateError-derived Err.
      expect((result as Err<int>).statusCode.unwrap(), 506);
      expect(result.error, 'finalize-fault');
    });
  });

  group('Lazy — never throws (constructor faults become Sync.err)', () {
    test('singleton absorbs a non-Err throw into Sync.err', () {
      final lazy = Lazy<int>(() => throw StateError('boot-fail'));
      final s = lazy.singleton;
      expect(s, isA<Sync<int>>());
      expect((s as Sync<int>).value, isA<Err<int>>());
      expect(((s).value as Err<int>).error, isA<StateError>());
    });

    test('singleton preserves a user-thrown Err verbatim', () {
      final lazy = Lazy<int>(
        () => throw Err<int>('config-missing', statusCode: 412),
      );
      final s = lazy.singleton;
      final err = (s as Sync<int>).value;
      expect(err, isA<Err<int>>());
      expect((err as Err<int>).statusCode.unwrap(), 412);
      expect(err.error, 'config-missing');
    });

    test('singleton caches the failed Sync.err just like a successful one', () {
      var calls = 0;
      final lazy = Lazy<int>(() {
        calls++;
        throw StateError('boot-fail');
      });
      final a = lazy.singleton;
      final b = lazy.singleton;
      expect(identical(a, b), isTrue);
      expect(calls, 1, reason: 'constructor must run exactly once');
    });

    test('factory absorbs a throw into Sync.err on every read', () {
      var calls = 0;
      final lazy = Lazy<int>(() {
        calls++;
        throw Err<int>('factory-fault', statusCode: 503);
      });
      final a = lazy.factory;
      final b = lazy.factory;
      expect((a as Sync<int>).value, isA<Err<int>>());
      expect((b as Sync<int>).value, isA<Err<int>>());
      expect(calls, 2, reason: 'factory runs every access');
      expect((a.value as Err<int>).statusCode.unwrap(), 503);
    });

    test('resetSingleton lets a previously-failed Lazy retry', () {
      var attempt = 0;
      final lazy = Lazy<int>(() {
        attempt++;
        if (attempt == 1) throw StateError('first-boot-fail');
        return Sync.okValue(42);
      });
      final first = (lazy.singleton as Sync<int>).value;
      expect(first, isA<Err<int>>());
      lazy.resetSingleton();
      final second = (lazy.singleton as Sync<int>).value;
      expect(second, isA<Ok<int>>());
      expect((second as Ok<int>).value, 42);
    });
  });

  group('SafeCompleter.transf — Err preservation', () {
    test('user-thrown Err in transform callback preserves statusCode',
        () async {
      final c = SafeCompleter<int>();
      c.complete(7).end();
      final transformed = c.transf<int>(
        (_) => throw Err<int>('completer-transf-fault', statusCode: 503),
      );
      // The transformed completer should resolve to an Err with intact code.
      final r = await transformed.resolvable().value;
      expect(r, isA<Err<int>>());
      expect((r as Err<int>).statusCode.unwrap(), 503);
      expect(r.error, 'completer-transf-fault');
    });
  });

  group('Err.mapErr — Err preservation', () {
    test('user-thrown Err with statusCode preserved', () {
      final r = Err<int>('original').mapErr(
        (_) => throw Err<int>('replacement', statusCode: 470),
      );
      expect(r, isA<Err<int>>());
      expect(r.statusCode.unwrap(), 470);
      expect(r.error, 'replacement');
    });

    test('non-Err throw becomes Err', () {
      final r = Err<int>('original').mapErr((_) => throw StateError('boom'));
      expect(r, isA<Err<int>>());
      expect(r.error, isA<StateError>());
    });

    test('non-throwing mapErr replaces error', () {
      final r = Err<int>('original').mapErr(
        (e) => Err<int>('transformed', statusCode: 200),
      );
      expect(r.error, 'transformed');
      expect(r.statusCode.unwrap(), 200);
    });
  });

  group('Async.end() — never throws', () {
    test('end() on a future-erroring Async does not escape', () async {
      // Future erroring asynchronously: `.end()` must absorb the error
      // entirely rather than letting it propagate up.
      final a = Async<int>(() async {
        await Future<void>.delayed(const Duration(milliseconds: 1));
        throw StateError('rejected');
      });
      expect(() => a.end(), returnsNormally);
      // Give the swallowed error time to flow through the unawaited future.
      await Future<void>.delayed(const Duration(milliseconds: 5));
    });

    test('end() on a normal Async does not throw', () {
      final a = Async<int>(() async => 1);
      expect(() => a.end(), returnsNormally);
    });

    test('end() on an Err Async does not throw', () {
      final a = Async<int>.errValue((error: 'x', statusCode: null));
      expect(() => a.end(), returnsNormally);
    });
  });

  group('Cross-platform: WASM-safe stack traces', () {
    test('Err.stackTrace.toString() never crashes', () {
      // Locks in the dart2wasm safety fix: even if the platform can't parse
      // its own stack format, `Err.stackTrace.toString()` must return a
      // String (possibly empty) — never crash the isolate.
      final err = Err<int>('x', stackTrace: StackTrace.current);
      expect(() => err.stackTrace.toString(), returnsNormally);
      expect(err.stackTrace.toString(), isA<String>());
    });

    test('Err.toJson() never crashes regardless of trace format', () {
      final err = Err<int>('x', stackTrace: StackTrace.current);
      final json = err.toJson();
      expect(json['type'], 'Err<int>');
      expect(json['stackTrace'], isA<List<String>>());
    });

    test('Err.toString() never crashes regardless of trace format', () {
      final err = Err<int>('x', stackTrace: StackTrace.current);
      expect(() => err.toString(), returnsNormally);
      expect(err.toString(), contains('Err'));
    });

    test('Err with malformed StackTrace.fromString still constructs', () {
      // Adversarial: a totally bogus stack trace string. `_safeStackTrace`
      // must catch `Trace.parse`'s `FormatException` and fall back to empty.
      expect(
        () => Err<int>('x', stackTrace: StackTrace.fromString('garbage{[]}')),
        returnsNormally,
      );
    });
  });

  group('Lazy — re-entrance from inside constructor is detected', () {
    test('singleton re-entrance produces Sync.err, not stack overflow', () {
      // The constructor reaches back to read `singleton` on the same Lazy.
      // Without re-entrance detection this would recurse forever and
      // stack-overflow the isolate. The detection short-circuits to a
      // structured `Sync.err(...)`.
      late final Lazy<int> lazy;
      lazy = Lazy<int>(() {
        // Touching `singleton` here is the circular dependency.
        return lazy.singleton;
      });
      final result = (lazy.singleton as Sync<int>).value;
      expect(result, isA<Err<int>>());
      expect(
        (result as Err<int>).error.toString(),
        contains('re-entrantly'),
      );
    });

    test('factory re-entrance produces Sync.err, not stack overflow', () {
      late final Lazy<int> lazy;
      lazy = Lazy<int>(() {
        return lazy.factory;
      });
      final result = (lazy.factory as Sync<int>).value;
      expect(result, isA<Err<int>>());
      expect(
        (result as Err<int>).error.toString(),
        contains('re-entrantly'),
      );
    });
  });

  group('Err.new — never throws on construction', () {
    test('Err with empty StackTrace constructs without throwing', () {
      // Direct exercise of the defensive `_safeStackTrace` path: a
      // `StackTrace.empty` is unusual but well-formed; the constructor
      // must complete without throwing.
      expect(
        () => Err<int>('x', stackTrace: StackTrace.empty),
        returnsNormally,
      );
    });

    test('Err with non-empty but unusual StackTrace still constructs', () {
      expect(
        () => Err<int>('x', stackTrace: StackTrace.fromString('garbage')),
        returnsNormally,
      );
    });
  });

  group('TaskSequencer task.handler — Err preservation', () {
    test('user-thrown Err keeps statusCode through the sequencer', () async {
      final seq = TaskSequencer<int>();
      seq
          .then(
            (_) => throw Err<Option<int>>(
              'pump-stalled',
              statusCode: 503,
            ),
          )
          .end();
      final completion = await seq.completion.value;
      expect(completion, isA<Err<Option<int>>>());
      expect((completion as Err<Option<int>>).statusCode.unwrap(), 503);
      expect(completion.error, 'pump-stalled');
    });

    test(
      'user-thrown Err keeps statusCode on the error path too (after prev Err)',
      () async {
        final seq = TaskSequencer<int>();
        seq.then((_) => Sync.err(Err<Option<int>>('first'))).end();
        seq
            .then(
              (_) => throw Err<Option<int>>(
                'second-step-fault',
                statusCode: 504,
              ),
            )
            .end();
        final completion = await seq.completion.value;
        expect(completion, isA<Err<Option<int>>>());
        expect((completion as Err<Option<int>>).statusCode.unwrap(), 504);
        expect(completion.error, 'second-step-fault');
      },
    );
  });
}
