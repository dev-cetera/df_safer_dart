import 'package:df_safer_dart/df_safer_dart.dart';
import 'package:test/test.dart';

void main() {
  group('sequenced_task_batch', () {
    test('default constructor — fresh sequencer, isExecuting false', () {
      final batch = SequencedTaskBatch<int>();
      expect(batch.isExecuting, isFalse);
      expect(batch.executionIndex, 0);
      expect(batch.executionCount, 0);
      expect(batch.executionProgress, 0.0);
    });

    test('constructor — accepts a provided sequencer', () async {
      final seq = TaskSequencer<int>();
      final batch = SequencedTaskBatch<int>(sequencer: seq);
      batch.add((_) => Sync.okValue(const Some(1)));
      batch.executeTasks().end();
      (await seq.completion.value).end();
      expect(seq.isExecuting, isFalse);
    });

    test('from — produces an independent batch with the same tasks', () {
      final original = SequencedTaskBatch<int>();
      original.add((_) => Sync.okValue(const Some(1)));
      original.add((_) => Sync.okValue(const Some(2)));
      final copy = SequencedTaskBatch<int>.from(original);
      expect(copy.executionCount, 2);
      expect(identical(copy, original), isFalse);
    });

    test('from — overriding sequencer parameter', () {
      final batch = SequencedTaskBatch<int>();
      batch.add((_) => Sync.okValue(const Some(1)));
      final newSeq = TaskSequencer<int>();
      final copy = SequencedTaskBatch<int>.from(batch, sequencer: newSeq);
      expect(copy.executionCount, 1);
    });

    test('executeTasks — runs tasks in FIFO order', () async {
      final log = <int>[];
      final seq = TaskSequencer<int>();
      final batch = SequencedTaskBatch<int>(sequencer: seq);
      batch.add((_) {
        log.add(1);
        return Sync.okValue(const Some(1));
      });
      batch.add((_) {
        log.add(2);
        return Sync.okValue(const Some(2));
      });
      batch.add((_) {
        log.add(3);
        return Sync.okValue(const Some(3));
      });
      batch.executeTasks().end();
      (await seq.completion.value).end();
      expect(log, [1, 2, 3]);
    });

    test('executionIndex — increments as tasks complete', () async {
      final seq = TaskSequencer<int>();
      final batch = SequencedTaskBatch<int>(sequencer: seq);
      batch.add((_) => Sync.okValue(const Some(1)));
      batch.add((_) => Sync.okValue(const Some(2)));
      batch.executeTasks().end();
      (await seq.completion.value).end();
      expect(batch.executionIndex, 2);
    });

    test('executionCount — equals the number of enqueued tasks', () {
      final batch = SequencedTaskBatch<int>();
      batch.add((_) => Sync.okValue(const Some(1)));
      batch.add((_) => Sync.okValue(const Some(2)));
      batch.add((_) => Sync.okValue(const Some(3)));
      expect(batch.executionCount, 3);
    });

    test('executionProgress — reaches 1.0 after the run completes', () async {
      final seq = TaskSequencer<int>();
      final batch = SequencedTaskBatch<int>(sequencer: seq);
      batch.add((_) => Sync.okValue(const Some(1)));
      batch.add((_) => Sync.okValue(const Some(2)));
      batch.executeTasks().end();
      (await seq.completion.value).end();
      expect(batch.executionProgress, closeTo(1.0, 0.0001));
    });

    test('isExecuting — mirrors the underlying sequencer', () async {
      final seq = TaskSequencer<int>();
      final batch = SequencedTaskBatch<int>(sequencer: seq);
      batch.add(
        (_) => Async(() async {
          await Future<void>.delayed(const Duration(milliseconds: 20));
          return const Some(1);
        }),
      );
      batch.executeTasks().end();
      expect(batch.isExecuting, seq.isExecuting);
      (await seq.completion.value).end();
      expect(batch.isExecuting, isFalse);
    });
  });
}
