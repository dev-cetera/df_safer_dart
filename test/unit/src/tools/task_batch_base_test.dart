import 'package:df_safer_dart/df_safer_dart.dart';
import 'package:test/test.dart';

// Top-level sendable handler shared by the Task() construction tests below.
// `@sendable` requires a top-level function or static method, and tests of
// Task wiring don't care about handler internals — only that a valid handler
// can be stored, removed, or iterated.
TResolvableOption<int> _okSome1(TResultOption<int> previous) =>
    Sync.okValue(const Some(1));

void main() {
  group('task_batch_base', () {
    // TaskBatchBase is abstract — exercise its public surface via the
    // concrete ConcurrentTaskBatch subclass.

    test('isExecuting — false on a freshly-constructed subclass', () {
      final batch = ConcurrentTaskBatch<int>();
      expect(batch.isExecuting, isFalse);
    });

    test('isNotExecuting — true on a freshly-constructed subclass', () {
      final batch = ConcurrentTaskBatch<int>();
      expect(batch.isNotExecuting, isTrue);
    });

    test('executionIndex — starts at zero', () {
      expect(ConcurrentTaskBatch<int>().executionIndex, 0);
    });

    test('executionCount — starts at zero with no tasks added', () {
      expect(ConcurrentTaskBatch<int>().executionCount, 0);
    });

    test('executionProgress — returns 0.0 when executionCount is zero', () {
      expect(ConcurrentTaskBatch<int>().executionProgress, 0.0);
    });

    test('executeTasks — returns a TResolvableOption that settles', () async {
      final batch = ConcurrentTaskBatch<int>();
      batch.add((_) => Sync.okValue(const Some(1)));
      final r = batch.executeTasks();
      expect(r, isA<Resolvable<Option<int>>>());
      (await r.value).end();
    });

    test('add — appends a task to the queue', () {
      final batch = ConcurrentTaskBatch<int>();
      expect(batch.executionCount, 0);
      batch.add((_) => Sync.okValue(const Some(1)));
      expect(batch.executionCount, 1);
    });

    test('addTask — appends a pre-built Task to the queue', () {
      final batch = ConcurrentTaskBatch<int>();
      final t = const Task<int>(
        handler: _okSome1,
        onError: null,
        eagerError: false,
        minTaskDuration: null,
      );
      batch.addTask(t);
      expect(batch.executionCount, 1);
    });

    test('addAllTasks — appends an iterable of Task objects', () {
      final batch = ConcurrentTaskBatch<int>();
      final tasks = List<Task<int>>.generate(
        3,
        (_) => const Task<int>(
          handler: _okSome1,
          onError: null,
          eagerError: false,
          minTaskDuration: null,
        ),
      );
      batch.addAllTasks(tasks);
      expect(batch.executionCount, 3);
    });

    test('removeTask — removes a previously-added task', () {
      final batch = ConcurrentTaskBatch<int>();
      final t = const Task<int>(
        handler: _okSome1,
        onError: null,
        eagerError: false,
        minTaskDuration: null,
      );
      batch.addTask(t);
      expect(batch.removeTask(t), isTrue);
      expect(batch.executionCount, 0);
    });

    test('removeTask — returns false for an unknown task', () {
      final batch = ConcurrentTaskBatch<int>();
      final t = const Task<int>(
        handler: _okSome1,
        onError: null,
        eagerError: false,
        minTaskDuration: null,
      );
      expect(batch.removeTask(t), isFalse);
    });

    test('clearTasks — clears non-empty queue and reports true', () {
      final batch = ConcurrentTaskBatch<int>();
      batch.add((_) => Sync.okValue(const Some(1)));
      batch.add((_) => Sync.okValue(const Some(2)));
      expect(batch.clearTasks(), isTrue);
      expect(batch.executionCount, 0);
    });

    test('clearTasks — returns false on an empty queue', () {
      final batch = ConcurrentTaskBatch<int>();
      expect(batch.clearTasks(), isFalse);
    });

    test('removeFirstTask — removes the head and returns true', () {
      final batch = ConcurrentTaskBatch<int>();
      batch.add((_) => Sync.okValue(const Some(1)));
      batch.add((_) => Sync.okValue(const Some(2)));
      expect(batch.removeFirstTask(), isTrue);
      expect(batch.executionCount, 1);
    });

    test('removeFirstTask — returns false on an empty queue', () {
      expect(ConcurrentTaskBatch<int>().removeFirstTask(), isFalse);
    });

    test('removeLastTask — removes the tail and returns true', () {
      final batch = ConcurrentTaskBatch<int>();
      batch.add((_) => Sync.okValue(const Some(1)));
      batch.add((_) => Sync.okValue(const Some(2)));
      expect(batch.removeLastTask(), isTrue);
      expect(batch.executionCount, 1);
    });

    test('removeLastTask — returns false on an empty queue', () {
      expect(ConcurrentTaskBatch<int>().removeLastTask(), isFalse);
    });
  });
}
