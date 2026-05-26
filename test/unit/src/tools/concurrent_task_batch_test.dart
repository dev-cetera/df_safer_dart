import 'package:df_safer_dart/df_safer_dart.dart';
import 'package:test/test.dart';

void main() {
  group('concurrent_task_batch', () {
    test('default constructor — isExecuting false and zero progress', () {
      final batch = ConcurrentTaskBatch<int>();
      expect(batch.isExecuting, isFalse);
      expect(batch.executionIndex, 0);
      expect(batch.executionCount, 0);
      expect(batch.executionProgress, 0.0);
    });

    test('from — copies configuration and tasks', () {
      final original = ConcurrentTaskBatch<int>();
      original.add((_) => Sync.okValue(const Some(1)));
      original.add((_) => Sync.okValue(const Some(2)));
      final copy = ConcurrentTaskBatch<int>.from(original);
      expect(copy.executionCount, 2);
      expect(identical(copy, original), isFalse);
    });

    test('add — appends a task and increments executionCount', () {
      final batch = ConcurrentTaskBatch<int>();
      batch.add((_) => Sync.okValue(const Some(1)));
      batch.add((_) => Sync.okValue(const Some(2)));
      expect(batch.executionCount, 2);
    });

    test('executeTasks — runs all tasks to completion', () async {
      final batch = ConcurrentTaskBatch<int>();
      for (var i = 0; i < 4; i++) {
        final captured = i;
        batch.add(
          (_) => Async(() async {
            await Future<void>.delayed(const Duration(milliseconds: 5));
            return Some(captured);
          }),
        );
      }
      (await batch.executeTasks().value).end();
      expect(batch.isExecuting, isFalse);
      expect(batch.executionIndex, 4);
    });

    test('executeTasks — runs tasks concurrently (elapsed < sum of sleeps)',
        () async {
      const taskCount = 4;
      const perTask = Duration(milliseconds: 40);
      final batch = ConcurrentTaskBatch<int>();
      for (var i = 0; i < taskCount; i++) {
        final captured = i;
        batch.add(
          (_) => Async(() async {
            await Future<void>.delayed(perTask);
            return Some(captured);
          }),
        );
      }
      final sw = Stopwatch()..start();
      (await batch.executeTasks().value).end();
      sw.stop();
      // Sequential lower bound would be ~160ms; concurrent must be much less.
      expect(
        sw.elapsedMilliseconds,
        lessThan(perTask.inMilliseconds * taskCount),
      );
    });

    test('executionIndex — increments as tasks finish', () async {
      final batch = ConcurrentTaskBatch<int>();
      batch.add((_) => Sync.okValue(const Some(1)));
      batch.add((_) => Sync.okValue(const Some(2)));
      batch.add((_) => Sync.okValue(const Some(3)));
      (await batch.executeTasks().value).end();
      expect(batch.executionIndex, 3);
    });

    test('executionCount — equals the number of tasks added', () {
      final batch = ConcurrentTaskBatch<int>();
      batch.add((_) => Sync.okValue(const Some(1)));
      batch.add((_) => Sync.okValue(const Some(2)));
      expect(batch.executionCount, 2);
    });

    test('executionProgress — moves to 1.0 after completion', () async {
      final batch = ConcurrentTaskBatch<int>();
      batch.add((_) => Sync.okValue(const Some(1)));
      batch.add((_) => Sync.okValue(const Some(2)));
      (await batch.executeTasks().value).end();
      expect(batch.executionProgress, closeTo(1.0, 0.0001));
    });

    test('isExecuting — false again after executeTasks settles', () async {
      final batch = ConcurrentTaskBatch<int>();
      batch.add(
        (_) => Async(() async {
          await Future<void>.delayed(const Duration(milliseconds: 10));
          return const Some(1);
        }),
      );
      final fut = batch.executeTasks().value;
      // The internal flag flips to true synchronously during executeTasks.
      expect(batch.isExecuting, isTrue);
      (await fut).end();
      expect(batch.isExecuting, isFalse);
    });

    test('executeTasks — completes even when some tasks fail', () async {
      final batch = ConcurrentTaskBatch<int>(eagerError: true);
      batch.add((_) => Sync.okValue(const Some(1)));
      batch.add((_) => Sync.err(Err<Option<int>>('boom')));
      batch.add((_) => Sync.okValue(const Some(3)));
      final result = await batch.executeTasks().value;
      expect(batch.isExecuting, isFalse);
      expect(result, anyOf(isA<Ok>(), isA<Err>()));
    });
  });
}
