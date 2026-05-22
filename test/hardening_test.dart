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
  group('letIntOrNone — abuse cases', () {
    test('returns None for double.infinity', () {
      expect(letIntOrNone(double.infinity), isA<None<int>>());
    });

    test('returns None for double.negativeInfinity', () {
      expect(letIntOrNone(double.negativeInfinity), isA<None<int>>());
    });

    test('returns None for double.nan', () {
      expect(letIntOrNone(double.nan), isA<None<int>>());
    });

    test('returns None for "Infinity" string', () {
      expect(letIntOrNone('Infinity'), isA<None<int>>());
    });

    test('returns None for value beyond int64 range', () {
      // 1e30 cannot fit in int64 (max ~9.22e18).
      expect(letIntOrNone(1e30), isA<None<int>>());
    });

    test('still accepts finite int-representable doubles', () {
      final result = letIntOrNone(42.0);
      expect(result, isA<Some<int>>());
      expect(result.unwrap(), 42);
    });
  });

  group('combineResolvable — single-pass iterable', () {
    test('handles single-pass generators without losing elements', () {
      Iterable<Sync<int>> gen() sync* {
        yield Sync.okValue(1);
        yield Sync.okValue(2);
        yield Sync.okValue(3);
      }

      final combined = combineResolvable<int>(gen());
      expect(combined, isA<Sync<List<int>>>());
      final list = combined.sync().unwrap().value.unwrap();
      expect(list, [1, 2, 3]);
    });

    test(
      'handles single-pass generator with one Async without losing elements',
      () async {
        Iterable<Resolvable<int>> gen() sync* {
          yield Sync.okValue(10);
          yield Async(() async => 20);
          yield Sync.okValue(30);
        }

        final combined = combineResolvable<int>(gen());
        final list = (await combined.value).unwrap();
        expect(list, [10, 20, 30]);
      },
    );
  });

  group('Err — stack trace preservation', () {
    test('transfErr preserves the original stack trace', () {
      Err<int> makeOriginal() {
        return Err<int>('boom');
      }

      final original = makeOriginal();
      final transformed = original.transfErr<String>();
      expect(
        transformed.stackTrace.toString(),
        equals(original.stackTrace.toString()),
        reason: 'transfErr must not lose origin frames',
      );
    });

    test('transfErr preserves explicit stackTrace argument', () {
      final st = StackTrace.current;
      final original = Err<int>('boom', stackTrace: st);
      final transformed = original.transfErr<String>();
      expect(
        transformed.stackTrace.toString(),
        equals(original.stackTrace.toString()),
      );
    });

    test('transfErr preserves statusCode', () {
      final original = Err<int>('not found', statusCode: 404);
      final transformed = original.transfErr<String>();
      expect(transformed.statusCode.unwrap(), 404);
    });
  });

  group('TaskSequencer — reentrant queue abuse', () {
    test('drains a large synchronous reentrant queue without stack overflow', () async {
      // From inside a running task, enqueue N more sync tasks.
      // A naive recursive drain stack-overflows; an iterative drain does not.
      // Large enough to overflow the default Dart stack without the iterative
      // drain fix. Sized to be punitive: an O(N)-deep recursion at this count
      // exceeds the default ~256 KiB stack.
      const N = 200000;
      final seq = TaskSequencer<int>();
      final completed = <int>[];

      seq.then((_) {
        for (var i = 0; i < N; i++) {
          final captured = i;
          seq.then((_) {
            completed.add(captured);
            return Sync.okValue(Some(captured));
          }).end();
        }
        return Sync.okValue(const Some(0));
      }).end();

      // Allow microtasks to drain.
      (await seq.completion.value).end();
      // Wait one extra event-loop turn so the reentrant queue can drain.
      await Future<void>.delayed(Duration.zero);
      expect(completed.length, N);
    });
  });

  group('SafeCompleter — race window', () {
    test('isCompleted reports true once resolve() has accepted the work', () async {
      final completer = SafeCompleter<int>();
      final pending = Future<int>.delayed(
        const Duration(milliseconds: 30),
        () => 7,
      );
      completer.complete(pending).end();

      // The spec contract: once a non-Err resolve() has been accepted, the
      // completer is "committed" — a second resolve must fail.
      // Therefore isCompleted should report true even while the future is in
      // flight, otherwise observers can race and submit a second resolution.
      expect(
        completer.isCompleted,
        isTrue,
        reason: 'isCompleted must report true once a resolve is in flight',
      );

      final value = await completer.resolvable().unwrap();
      expect(value, 7);
    });

    test('rejects a second resolve while the first is still in flight', () async {
      final completer = SafeCompleter<int>();
      final slow = Future<int>.delayed(
        const Duration(milliseconds: 20),
        () => 1,
      );
      completer.complete(slow).end();

      final secondTry = completer.complete(2);
      final r = await secondTry.value;
      expect(r, isA<Err<int>>());

      final settled = await completer.resolvable().unwrap();
      expect(settled, 1);
    });
  });

  group('Outcome.reduce — depth bomb', () {
    test('handles deeply nested Some without stack overflow', () {
      // Build Some(Some(Some(...Some(42)...))) 10000 deep.
      const depth = 10000;
      Outcome<Object> chain = const Some(42);
      for (var i = 0; i < depth; i++) {
        chain = Some(chain);
      }
      final reduced = chain.reduce<int>();
      expect(reduced, isA<Sync<Option<int>>>());
      final innermost = reduced.sync().unwrap().value.unwrap().unwrap();
      expect(innermost, 42);
    });
  });

  group('fold — release-build survivability', () {
    test(
      'fold on Ok captures callback errors as Err even when asserts are disabled',
      () {
        // Mimic the release-mode behavior: ensure that even if asserts are
        // stripped, the callback error is converted into an Err with the
        // original error preserved.
        final result = const Ok<int>(1).fold(
          (ok) => throw StateError('boom'),
          (err) => null,
        );
        expect(result, isA<Err>());
        expect((result as Err).error, isA<StateError>());
      },
    );

    test(
      'fold on Err captures callback errors as Err even when asserts are disabled',
      () {
        final original = Err<int>('original');
        final result = original.fold(
          (ok) => null,
          (err) => throw StateError('boom'),
        );
        expect(result, isA<Err>());
        expect((result as Err).error, isA<StateError>());
      },
    );
  });
}
