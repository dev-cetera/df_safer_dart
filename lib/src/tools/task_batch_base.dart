//.title
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//
// Dart/Flutter (DF) Packages by dev-cetera.com & contributors. The use of this
// source code is governed by an MIT-style license described in the LICENSE
// file located in this project's root directory.
//
// See: https://opensource.org/license/mit
//
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//.title~

import '/_common.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

abstract class TaskBatchBase<T extends Object> {
  /// The queue of tasks to be processed.
  /// Tasks are generally expected to be processed in FIFO order.
  @protected
  var tasks = Queue<Task<T>>.from([]);

  /// Creates a new task batch.
  TaskBatchBase();

  /// Abstract getter that subclasses must implement to indicate if
  /// tasks are currently being executed.
  ///
  /// This is used by modification methods to prevent changes during execution.
  bool get isExecuting;

  /// Returns `true` if tasks are not currently being executed.
  bool get isNotExecuting => !isExecuting;

  /// Abstract method that subclasses must implement to define how
  /// the batch of tasks is executed.
  ///
  /// Returns a [TResolvableOption] representing the outcome of the
  /// batch execution.
  TResolvableOption<T> executeTasks();

  /// Adds a new task to the batch by providing its handler and optional configurations.
  ///
  /// This is a convenience method that constructs a [Task] object internally.
  ///
  /// - [handler]: The function to execute for this task. It receives the
  ///   result of the previous task (or an initial state) and should return a
  ///   [TResolvableOption<T>].
  /// - [onError]: An optional error handler specific to this task.
  /// - [eagerError]: Specifies the error handling behavior for this task.
  ///   Subclasses might use their own defaults if this is `null`.
  /// - [minTaskDuration]: Specifies a minimum duration for this task.
  ///   Subclasses might use their own defaults if this is `null`.
  ///
  /// Throws an [AssertionError] if called while [isExecuting] is true.
  void add(
    @noFuturesAllowed TTaskHandler<T> handler, {
    @noFuturesAllowed TOnTaskError? onError,
    bool? eagerError, // Subclasses might provide defaults
    Duration? minTaskDuration, // Subclasses might provide defaults
  }) {
    // Subclasses might override this to inject their specific defaults for
    // eagerError or minTaskDuration if they have instance-level settings.
    final task = Task(
      handler: handler,
      onError: onError,
      eagerError: eagerError, // Relies on Task's default or what's passed
      minTaskDuration: minTaskDuration,
    );
    addTask(task);
  }

  /// Adds a pre-configured [Task] object to the end of the task queue.
  ///
  /// Throws an [AssertionError] if called while [isExecuting] is true.
  void addTask(Task<T> task) {
    _ifNotExecuting(() => tasks.add(task));
  }

  /// Removes a specific [task] from the queue.
  ///
  /// Returns `true` if the task was found and removed, `false` otherwise.
  /// Returns `null` (and asserts) if called while [isExecuting] is true.
  bool removeTask(Task<T> task) {
    return _ifNotExecuting(() => tasks.remove(task)) ?? false;
  }

  /// Adds multiple [Task] objects to the end of the task queue.
  ///
  /// Throws an [AssertionError] if called while [isExecuting] is true.
  void addAllTasks(Iterable<Task<T>> newTasks) {
    _ifNotExecuting(() => tasks.addAll(newTasks));
  }

  /// Clears all tasks from the queue.
  ///
  /// Returns `true` if tasks were cleared.
  /// Returns `null` (and asserts) if called while [isExecuting] is true.
  bool clearTasks() {
    return _ifNotExecuting(() {
          tasks.clear();
          return true;
        }) ??
        false;
  }

  /// Removes the first task from the queue.
  ///
  /// Returns `true` if a task was removed.
  /// Returns `null` (and asserts) if the batch was empty or if called
  /// during execution. Throws [StateError] if the queue is empty when called.
  bool removeFirstTask() {
    return _ifNotExecuting(() {
          tasks.removeFirst(); // Can throw StateError if empty
          return true;
        }) ??
        false;
  }

  /// Removes the last task from the queue.
  ///
  /// Returns `true` if a task was removed.
  /// Returns `null` (and asserts) if the batch was empty or if called
  /// during execution. Throws [StateError] if the queue is empty when called.
  bool removeLastTask() {
    return _ifNotExecuting(() {
          tasks.removeLast(); // Can throw StateError if empty
          return true;
        }) ??
        false;
  }

  /// Internal helper to ensure modifications to the task queue are not made
  /// while tasks are being executed.
  ///
  /// Asserts that `isNotExecuting` is `true`.
  /// If not executing, it calls the [caller] function and returns its result.
  /// Otherwise, it returns `null`.
  R? _ifNotExecuting<R>(R Function() caller) {
    assert(isNotExecuting, 'Cannot modify TaskBatch while tasks are executing.');
    if (isNotExecuting) {
      return caller();
    }
    return null;
  }
}
