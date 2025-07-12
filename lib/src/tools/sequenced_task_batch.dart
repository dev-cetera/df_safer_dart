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

import '/_common.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

// NOTE: See https://pub.dev/packages/synchronized

/// A batch of tasks designed to be executed sequentially by a [TaskSequencer].
///
/// This class holds a collection of [Task] objects and delegates their
/// execution to a [TaskSequencer], ensuring that each task runs only after the
/// previous one has completed.
class SequencedTaskBatch<T extends Object> extends TaskBatchBase<T> {
  final TaskSequencer<T> _sequencer;

  @override
  bool get isExecuting => _sequencer.isExecuting;

  @override
  int get executionIndex => _executionIndex;
  int _executionIndex = 0;

  @override
  int get executionCount => tasks.length; // _executionCount will not always equal tasks.length
  int _executionCount = 0;

  @override
  double get executionProgress {
    if (_executionCount == 0.0) return 0.0;
    return _executionIndex / _executionCount;
  }

  final TOnTaskConpletedCallback<T>? _onTaskCompleted;

  SequencedTaskBatch({
    TaskSequencer<T>? sequencer,
    TOnTaskConpletedCallback<T>? onTaskCompleted,
  })  : _onTaskCompleted = onTaskCompleted,
        _sequencer = sequencer ?? TaskSequencer<T>();

  /// Creates a new batch from an existing one, sharing its configuration.
  ///
  /// The new batch will contain a copy of the original tasks but can be
  /// assigned a different [TaskSequencer]. If no sequencer is provided, it
  /// reuses the one from the `other` batch.
  factory SequencedTaskBatch.from(
    SequencedTaskBatch<T> other, {
    TaskSequencer<T>? sequencer,
  }) {
    final newBatch = SequencedTaskBatch<T>(
      sequencer: sequencer ?? other._sequencer,
    );
    // Create a new independent queue with the same tasks.
    newBatch.tasks.addAll(other.tasks);
    return newBatch;
  }

  /// Schedules all tasks in the queue for sequential execution.
  ///
  /// This operation is non-blocking; it enqueues the tasks in the underlying
  /// [TaskSequencer] and returns immediately.
  ///
  /// The final result of all tasks can be retrieved from the returned
  /// [Resolvable] or by accessing the `completion` property of the sequencer.
  @override
  TResolvableOption<T> executeTasks() {
    _executionCount = tasks.length;
    _executionIndex = 0;
    while (tasks.isNotEmpty) {
      final task = tasks.removeFirst();
      _executeTask(task)
          .then((e) {
            _executionIndex++;
            return _onTaskCompleted?.call(task, executionProgress) ?? syncUnit();
          })
          .flatten()
          .end();
    }
    return _sequencer.completion;
  }

  TResolvableOption<T> _executeTask(Task<T> task) {
    return _sequencer.then(
      task.handler,
      onPrevError: task.onError,
      eagerError: task.eagerError,
      minTaskDuration: task.minTaskDuration,
    );
  }
}
