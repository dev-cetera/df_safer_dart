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

/// Provides a foundational structure for managing a collection of tasks.
///
/// This class handles queue management and provides guards to prevent unsafe
/// modifications. Subclasses are responsible for implementing the execution
/// strategy (e.g., sequential or concurrent).
abstract class TaskBatchBase<T extends Object> {
  /// A protected queue of tasks awaiting processing, typically in FIFO order.
  @protected
  var tasks = Queue<Task<T>>();

  TaskBatchBase();

  /// Indicates if the batch is actively processing tasks.
  ///
  /// This is used as a guard to prevent queue modifications during execution.
  bool get isExecuting;

  @pragma('vm:prefer-inline')
  bool get isNotExecuting => !isExecuting;

  /// The index of the currently executing task. Zero-based.
  int get executionIndex;

  /// The total number of tasks to be executed in the current batch.
  int get executionCount;

  /// The execution progress as a value between 0.0 and 1.0.
  /// Returns 0.0 if `executionCount` is zero.
  double get executionProgress;

  /// Defines the task execution strategy for the batch.
  ///
  /// Returns a [TResolvableOption] that completes with the batch's final result.
  TResolvableOption<T> executeTasks();

  /// A convenience method to construct a [Task] and add it to the queue.
  ///
  /// - [handler]: The function to execute for this task.
  /// - [onError]: An optional error handler specific to this task.
  /// - [eagerError]: Overrides the default error handling for this task.
  /// - [minTaskDuration]: Overrides the default minimum duration for this task.
  ///
  /// Throws an [AssertionError] if the batch is currently executing.
  void add(
    @noFutures @sendable TTaskHandler<T> handler, {
    @noFutures @sendable TOnTaskError? onError,
    bool? eagerError,
    Duration? minTaskDuration,
  }) {
    // Subclasses can override this to inject their specific defaults.
    final task = Task(
      handler: handler,
      onError: onError,
      eagerError: eagerError,
      minTaskDuration: minTaskDuration,
    );
    addTask(task);
  }

  /// Adds a pre-configured [Task] to the end of the queue.
  ///
  /// Throws an [AssertionError] if the batch is currently executing.
  @pragma('vm:prefer-inline')
  void addTask(Task<T> task) {
    // Inline the guard directly instead of `_ifNotExecuting(() => ...)`. The
    // helper is convenient but it allocates a closure per call; the inline
    // form is identical in semantics and allocates nothing.
    assert(isNotExecuting, 'Cannot modify while tasks are executing.');
    if (isNotExecuting) tasks.add(task);
  }

  /// Adds multiple [Task] objects to the end of the queue.
  ///
  /// Throws an [AssertionError] if the batch is currently executing.
  @pragma('vm:prefer-inline')
  void addAllTasks(Iterable<Task<T>> newTasks) {
    assert(isNotExecuting, 'Cannot modify while tasks are executing.');
    if (isNotExecuting) tasks.addAll(newTasks);
  }

  /// Removes a specific [task] from the queue.
  ///
  /// Returns `true` if the task was found and removed, `false` otherwise.
  @pragma('vm:prefer-inline')
  bool removeTask(Task<T> task) {
    assert(isNotExecuting, 'Cannot modify while tasks are executing.');
    if (isNotExecuting) return tasks.remove(task);
    return false;
  }

  /// Clears all tasks from the queue.
  ///
  /// Returns `true` if the queue was not empty before clearing, `false` otherwise.
  @pragma('vm:prefer-inline')
  bool clearTasks() {
    assert(isNotExecuting, 'Cannot modify while tasks are executing.');
    if (!isNotExecuting) return false;
    final wasNotEmpty = tasks.isNotEmpty;
    if (wasNotEmpty) tasks.clear();
    return wasNotEmpty;
  }

  /// Removes the first task from the queue.
  ///
  /// Returns `true` if a task was removed, `false` if the queue was empty.
  @pragma('vm:prefer-inline')
  bool removeFirstTask() {
    assert(isNotExecuting, 'Cannot modify while tasks are executing.');
    if (!isNotExecuting || tasks.isEmpty) return false;
    tasks.removeFirst();
    return true;
  }

  /// Removes the last task from the queue.
  ///
  /// Returns `true` if a task was removed, `false` if the queue was empty.
  @pragma('vm:prefer-inline')
  bool removeLastTask() {
    assert(isNotExecuting, 'Cannot modify while tasks are executing.');
    if (!isNotExecuting || tasks.isEmpty) return false;
    tasks.removeLast();
    return true;
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

typedef TOnTaskConpletedCallback<T extends Object> = Resolvable<Unit> Function(
  Task<T> task,
  double executionProgress, //,
);
