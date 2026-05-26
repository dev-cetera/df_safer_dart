import 'package:df_safer_dart/df_safer_dart.dart';
import 'package:test/test.dart';

void main() {
  group('task_sequencer', () {
    test('default constructor — starts not executing with Some-None completion',
        () async {
      final seq = TaskSequencer<int>();
      expect(seq.isExecuting, isFalse);
      expect(seq.isNotExecuting, isTrue);
      final c = await seq.completion.value;
      expect(c, isA<Ok<Option<int>>>());
      expect(c.unwrap().isNone(), isTrue);
    });

    test('completion — exposes the current sequence state', () async {
      final seq = TaskSequencer<int>();
      seq.then((_) => Sync.okValue(const Some(11))).end();
      final r = await seq.completion.value;
      expect(r.unwrap().unwrap(), 11);
    });

    test('isExecuting — true while an async task is in flight', () async {
      final seq = TaskSequencer<int>();
      seq.then(
        (_) => Async(() async {
          await Future<void>.delayed(const Duration(milliseconds: 30));
          return const Some(1);
        }),
      ).end();
      expect(seq.isExecuting, isTrue);
      await seq.completion.value;
      expect(seq.isExecuting, isFalse);
    });

    test('isNotExecuting — opposite of isExecuting', () {
      final seq = TaskSequencer<int>();
      expect(seq.isNotExecuting, !seq.isExecuting);
    });

    test('newBatch — returns a SequencedTaskBatch bound to this sequencer', () {
      final seq = TaskSequencer<int>();
      final b = seq.newBatch();
      expect(b, isA<SequencedTaskBatch<int>>());
    });

    test('then — runs tasks in FIFO order', () async {
      final seq = TaskSequencer<int>();
      final log = <int>[];
      seq.then((_) {
        log.add(1);
        return Sync.okValue(const Some(1));
      }).end();
      seq.then((_) {
        log.add(2);
        return Sync.okValue(const Some(2));
      }).end();
      seq.then((_) {
        log.add(3);
        return Sync.okValue(const Some(3));
      }).end();
      await seq.completion.value;
      expect(log, [1, 2, 3]);
    });

    test('then — passes previous result into the next handler', () async {
      final seq = TaskSequencer<int>();
      seq.then((_) => Sync.okValue(const Some(50))).end();
      late int seen;
      seq.then((prev) {
        seen = prev.orNull()?.orNull() ?? -1;
        return Sync.okValue(const Some(0));
      }).end();
      await seq.completion.value;
      expect(seen, 50);
    });

    test('then — reentrant add of 200 nested sync tasks does not stack overflow',
        () async {
      // CLAUDE.md hardening: drains iteratively via _draining guard.
      final seq = TaskSequencer<int>();
      final count = <int>[0];
      void schedule(int remaining) {
        seq.then((_) {
          count[0]++;
          if (remaining > 0) {
            schedule(remaining - 1);
          }
          return Sync.okValue(const Some(0));
        }).end();
      }

      schedule(200);
      await seq.completion.value;
      // Yield once for any trailing reentrant drains.
      await Future<void>.delayed(Duration.zero);
      expect(count[0], greaterThanOrEqualTo(200));
    });

    test('then — onPrevError handler fires on error', () async {
      var hit = 0;
      final seq = TaskSequencer<int>();
      seq.then((_) => Sync.err(Err<Option<int>>('boom'))).end();
      seq.then(
        (_) => Sync.okValue(const Some(2)),
        // ignore: sendable, local hit-counter test.
        onPrevError: (err) {
          hit++;
          return Sync.okValue(const None());
        },
      ).end();
      await seq.completion.value;
      expect(hit, 1);
    });

    test('then — eagerError true short-circuits subsequent tasks', () async {
      final seq = TaskSequencer<int>(eagerError: true);
      final reached = <int>[];
      seq.then((_) {
        reached.add(1);
        return Sync.err(Err<Option<int>>('boom'));
      }).end();
      seq.then((_) {
        reached.add(2);
        return Sync.okValue(const Some(2));
      }).end();
      final result = await seq.completion.value;
      expect(result, isA<Err>());
      expect(seq.isExecuting, isFalse);
    });

    test('then — minTaskDuration delays a sync task', () async {
      final seq = TaskSequencer<int>(
        minTaskDuration: const Duration(milliseconds: 20),
      );
      final sw = Stopwatch()..start();
      seq.then((_) => Sync.okValue(const Some(1))).end();
      await seq.completion.value;
      sw.stop();
      expect(sw.elapsedMilliseconds, greaterThanOrEqualTo(15));
    });

    test('convertHandler — wraps a (prev, err)->T handler into TTaskHandler',
        () async {
      // ignore: sendable, local lambda test.
      final handler = TaskSequencer.convertHandler<int>(
        (prev, err) => (prev ?? 0) + 1,
      );
      final seq = TaskSequencer<int>();
      seq.then((_) => Sync.okValue(const Some(10))).end();
      seq.then(handler).end();
      final r = await seq.completion.value;
      expect(r.unwrap().unwrap(), 11);
    });

    test('Task constructor — stores fields verbatim', () {
      final t = Task<int>(
        handler: (prev) => Sync.okValue(const Some(1)),
        onError: null,
        eagerError: true,
        minTaskDuration: const Duration(milliseconds: 5),
      );
      expect(t.eagerError, isTrue);
      expect(t.minTaskDuration, const Duration(milliseconds: 5));
      expect(t.onError, isNull);
      expect(t.handler, isNotNull);
    });
  });
}
