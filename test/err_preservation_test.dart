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
// The 2026-05-26 optimisation pass refactored several of these methods to use
// inline `try/catch` blocks instead of going through `Sync(...)` / `Async(...)`
// factories. The factories distinguish `on Err catch (err)` from generic
// `catch (error, stackTrace)` so that a user `throw Err('boom', statusCode:
// 404)` arrives at the consumer with statusCode + breadcrumbs + stack trace
// intact. The naïve `try { … } catch (error, stackTrace) { Err<T>(error, …) }`
// form drops all of that — it wraps the original `Err` inside *another* `Err`,
// hiding statusCode / breadcrumbs / original stack from the consumer.
//
// In life-critical pipelines a lost statusCode can change the operator's
// response (e.g. retry vs. escalate), so these tests are non-negotiable.

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
