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
    @noFutures TTaskHandler<T> handler, {
    @noFutures TOnTaskError? onError,
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
  void addTask(Task<T> task) {
    _ifNotExecuting(() => tasks.add(task));
  }

  /// Adds multiple [Task] objects to the end of the queue.
  ///
  /// Throws an [AssertionError] if the batch is currently executing.
  void addAllTasks(Iterable<Task<T>> newTasks) {
    _ifNotExecuting(() => tasks.addAll(newTasks));
  }

  /// Removes a specific [task] from the queue.
  ///
  /// Returns `true` if the task was found and removed, `false` otherwise.
  bool removeTask(Task<T> task) {
    return _ifNotExecuting(() => tasks.remove(task)) ?? false;
  }

  /// Clears all tasks from the queue.
  ///
  /// Returns `true` if the queue was not empty before clearing, `false` otherwise.
  bool clearTasks() {
    return _ifNotExecuting(() {
          final wasNotEmpty = tasks.isNotEmpty;
          if (wasNotEmpty) {
            tasks.clear();
          }
          return wasNotEmpty;
        }) ??
        false;
  }

  /// Removes the first task from the queue.
  ///
  /// Returns `true` if a task was removed, `false` if the queue was empty.
  bool removeFirstTask() {
    return _ifNotExecuting(() {
          if (tasks.isNotEmpty) {
            tasks.removeFirst();
            return true;
          }
          return false;
        }) ??
        false;
  }

  /// Removes the last task from the queue.
  ///
  /// Returns `true` if a task was removed, `false` if the queue was empty.
  bool removeLastTask() {
    return _ifNotExecuting(() {
          if (tasks.isNotEmpty) {
            tasks.removeLast();
            return true;
          }
          return false;
        }) ??
        false;
  }

  /// A guard that runs [caller] only if [isNotExecuting] is true.
  ///
  /// Asserts against modification during execution and returns `null` if the
  /// guard condition is not met, preventing the call.
  R? _ifNotExecuting<R>(R Function() caller) {
    assert(isNotExecuting, 'Cannot modify while tasks are executing.');
    if (isNotExecuting) {
      return caller();
    }
    return null;
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

typedef TOnTaskConpletedCallback<T extends Object> =
    Resolvable<Unit> Function(
      Task<T> task,
      double executionProgress, //,
    );
