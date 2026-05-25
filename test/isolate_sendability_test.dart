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

// Phase-1 sendability baseline. The goal is NOT to make anything pass — it is
// to record exactly which data types survive `Isolate.run` today, so the next
// phase has a concrete list of things to fix.
//
// All worker entrypoints MUST be top-level functions: `Isolate.run`'s closure
// must itself be sendable, which only works for static/top-level refs.

import 'dart:isolate';

import 'package:df_safer_dart/df_safer_dart.dart';
import 'package:test/test.dart';

// ░░░ Worker entrypoints (top-level so they can cross isolate boundary) ░░░

Ok<int> _identityOk(Ok<int> input) => input;
Some<String> _identitySome(Some<String> input) => input;
None<int> _identityNone(None<int> input) => input;
Err<int> _identityErr(Err<int> input) => input;
Result<int> _identityResult(Result<int> input) => input;
Option<String> _identityOption(Option<String> input) => input;
Sync<int> _identitySync(Sync<int> input) => input;
Unit _identityUnit(Unit input) => input;

Sync<int> _produceSyncFromClosure() => Sync(() => 123);
Sync<int> _produceSyncThatThrows() => Sync<int>(() => throw StateError('x'));

// Top-level constructor used by Lazy round-trip tests. Lazy demands a
// `@sendable` constructor (top-level / static fn) — that is precisely what
// makes a Lazy itself shippable through SendPort.
Sync<int> _lazyMake42() => Sync.okValue(42);

Lazy<int> _identityLazy(Lazy<int> input) => input;

Lazy<int> _materializeLazyOnWorker() {
  final lazy = Lazy<int>(_lazyMake42);
  // Force-cache the singleton so the receiver sees a populated Lazy.
  lazy.singleton.end();
  return lazy;
}

// Sequencer handler entrypoints (must be top-level for @sendable).
TResolvableOption<int> _seqHandlerPlusOne(TResultOption<int> prev) {
  final n = prev.orNull()?.orNull() ?? 0;
  return Sync.okValue(Some(n + 1));
}

TResolvableOption<int> _seqHandlerDouble(TResultOption<int> prev) {
  final n = prev.orNull()?.orNull() ?? 0;
  return Sync.okValue(Some(n * 2));
}

TaskSequencer<int> _produceSequencerOnWorker() {
  final seq = TaskSequencer<int>();
  seq.then(_seqHandlerPlusOne).end();
  seq.then(_seqHandlerDouble).end();
  return seq;
}

void main() {
  group('isolate sendability — data types', () {
    test('Ok<int> round-trips', () async {
      final result = await Isolate.run(() => _identityOk(const Ok(42)));
      expect(result, isA<Ok<int>>());
      expect(result.value, 42);
    });

    test('Some<String> round-trips', () async {
      final result =
          await Isolate.run(() => _identitySome(const Some('hello')));
      expect(result, isA<Some<String>>());
      expect(result.value, 'hello');
    });

    test('None<int> round-trips', () async {
      final result = await Isolate.run(() => _identityNone(const None<int>()));
      expect(result, isA<None<int>>());
    });

    test('Err<int> round-trips (with String error, no statusCode)', () async {
      final result = await Isolate.run(
        () => _identityErr(Err<int>('boom')),
      );
      expect(result, isA<Err<int>>());
      expect(result.error, 'boom');
    });

    test('Err<int> round-trips (with statusCode)', () async {
      final result = await Isolate.run(
        () => _identityErr(Err<int>('boom', statusCode: 500)),
      );
      expect(result, isA<Err<int>>());
      expect(result.statusCode.orNull(), 500);
    });

    test('Err<int> round-trips (with breadcrumbs)', () async {
      final result = await Isolate.run(
        () => _identityErr(Err<int>('boom', breadcrumbs: const ['a', 'b'])),
      );
      expect(result, isA<Err<int>>());
      expect(result.breadcrumbs, ['a', 'b']);
    });

    test('Result<int> Ok round-trips', () async {
      final Result<int> input = const Ok(7);
      final result = await Isolate.run(() => _identityResult(input));
      expect(result, isA<Ok<int>>());
    });

    test('Result<int> Err round-trips', () async {
      final Result<int> input = Err<int>('nope');
      final result = await Isolate.run(() => _identityResult(input));
      expect(result, isA<Err<int>>());
    });

    test('Option<String> Some round-trips', () async {
      final Option<String> input = const Some('s');
      final result = await Isolate.run(() => _identityOption(input));
      expect(result, isA<Some<String>>());
    });

    test('Option<String> None round-trips', () async {
      const Option<String> input = None<String>();
      final result = await Isolate.run(() => _identityOption(input));
      expect(result, isA<None<String>>());
    });

    test('Sync<int>.okValue round-trips', () async {
      final result = await Isolate.run(() => _identitySync(Sync.okValue(99)));
      expect(result, isA<Sync<int>>());
      expect(result.value.unwrap(), 99);
    });

    test('Sync<int>.errValue round-trips', () async {
      final result =
          await Isolate.run(() => _identitySync(Sync<int>.errValue('x')));
      expect(result, isA<Sync<int>>());
      expect(result.value.err().orNull()?.error, 'x');
    });

    test('Unit.instance round-trips', () async {
      final result = await Isolate.run(() => _identityUnit(Unit.instance));
      expect(result, isA<Unit>());
    });

    test('Sync.new(() => value) round-trips (closure runs in producer)',
        () async {
      // The closure executes on the worker isolate; only the resulting Sync
      // (which holds the materialized Result<int>) crosses back.
      final result = await Isolate.run(_produceSyncFromClosure);
      expect(result, isA<Sync<int>>());
      expect(result.value.unwrap(), 123);
    });

    test('Sync.new with throwing closure absorbs the error and round-trips',
        () async {
      final result = await Isolate.run(_produceSyncThatThrows);
      expect(result, isA<Sync<int>>());
      expect(result.value.isErr(), isTrue);
    });
  });

  group('isolate sendability — Lazy', () {
    test('fresh Lazy (never used) round-trips via Isolate.run', () async {
      final result =
          await Isolate.run(() => _identityLazy(Lazy<int>(_lazyMake42)));
      expect(result, isA<Lazy<int>>());
      // Receiver can still materialize via its own constructor on this side.
      expect((result.singleton as Sync<int>).value.unwrap(), 42);
    });

    test('Lazy with cached Sync singleton round-trips', () async {
      final result = await Isolate.run(_materializeLazyOnWorker);
      expect(result, isA<Lazy<int>>());
      // The cached Resolvable<int> survived the trip (it was a Sync).
      expect((result.singleton as Sync<int>).value.unwrap(), 42);
    });

    test('Lazy can be sent directly through a SendPort', () async {
      final port = ReceivePort();
      try {
        // ignore: sendable, the constructor IS a top-level fn ref.
        port.sendPort.send(Lazy<int>(_lazyMake42));
        final received = await port.first as Lazy<int>;
        expect(received, isA<Lazy<int>>());
        expect((received.singleton as Sync<int>).value.unwrap(), 42);
      } finally {
        port.close();
      }
    });
  });

  group('isolate sendability — TaskSequencer', () {
    test('fresh TaskSequencer (no tasks) round-trips via Isolate.run',
        () async {
      final result = await Isolate.run(TaskSequencer<int>.new);
      expect(result, isA<TaskSequencer<int>>());
      expect(result.isExecuting, isFalse);
    });

    test(
        'TaskSequencer with completed sync chain round-trips, '
        'and receiver can append more work', () async {
      final received = await Isolate.run(_produceSequencerOnWorker);
      expect(received, isA<TaskSequencer<int>>());
      // The completion should reflect the final state of the chain
      // (Some(0) -> +1 -> *2 = Some(2)) computed on the worker.
      final settled = received.completion;
      expect((settled as Sync<Option<int>>).value.unwrap().orNull(), 2);

      // Receiver appends another sendable handler — sequencer must still
      // function in this isolate.
      received.then(_seqHandlerPlusOne).end();
      final next = received.completion;
      expect((next as Sync<Option<int>>).value.unwrap().orNull(), 3);
    });
  });

  group('isolate sendability — negative cases', () {
    test('Async<int> CANNOT be sent (wraps a Future)', () async {
      // Direct attempt to send an Async should fail because its `value` is a
      // Future. Use SendPort to force the failure synchronously rather than
      // hide it behind Isolate.run.
      final port = ReceivePort();
      try {
        expect(
          () => port.sendPort.send(Async<int>(() async => 1)),
          throwsArgumentError,
        );
      } finally {
        port.close();
      }
    });

    test('SafeCompleter<int> CANNOT be sent (wraps a Completer)', () async {
      // Locks in current state for Phase 5b: replacing the internal Completer
      // with a SendPort broker will make this test fail — flip the assertion
      // to `returnsNormally` and add a positive round-trip test at that time.
      final port = ReceivePort();
      try {
        expect(
          () => port.sendPort.send(SafeCompleter<int>()),
          throwsArgumentError,
        );
      } finally {
        port.close();
      }
    });
  });
}
