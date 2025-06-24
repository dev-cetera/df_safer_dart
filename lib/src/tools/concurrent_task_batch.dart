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

// ignore_for_file: must_use_unsafe_wrapper_or_error

import '/_common.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// Manages and executes a batch of tasks concurrently.
class ConcurrentTaskBatch<T extends Object> {
  //
  //
  //

  ConcurrentTaskBatch({
    bool eagerError = true,
    Duration? minTaskDuration,
    @noFuturesAllowed TOnTaskError? onError,
  })  : _minTaskDuration = minTaskDuration,
        _eagerError = eagerError,
        _onError = onError;

  /// Creates a new [ConcurrentTaskBatch] instance by copying tasks from another.
  factory ConcurrentTaskBatch.from(ConcurrentTaskBatch<T> other) {
    return ConcurrentTaskBatch<T>(eagerError: other._eagerError).._tasks = Queue.from(other._tasks);
  }

  var _tasks = Queue<Task<T>>.from([]);
  final Duration? _minTaskDuration;
  final bool _eagerError;
  final TOnTaskError? _onError;

  bool _isExecuting = false;

  /// Returns `true` if tasks are currently being executed.
  bool get isExecuting => _isExecuting;

  /// Returns `true` if tasks are not currently being executed.
  bool get isNotExecuting => !isExecuting;

  /// Adds a new task to the batch.
  ///
  /// - [handler]: The function to execute for this task.
  /// - [onError]: A specific error handler for this task.
  /// - [eagerError]: Overrides the batch's `eagerError` behavior for this task.
  /// - [minTaskDuration]: Overrides the batch's `minTaskDuration` for this task.
  void add(
    @noFuturesAllowed TTaskHandler<T> handler, {
    @noFuturesAllowed TOnTaskError? onError,
    bool? eagerError,
    Duration? minTaskDuration,
  }) {
    final task = Task(
      handler: handler,
      onError: onError,
      eagerError: eagerError ?? eagerError,
      minTaskDuration: minTaskDuration,
    );
    addTask(task);
  }

  /// Adds a pre-configured [Task] object to the batch.
  void addTask(Task<T> task) {
    _ifNotExecuting(() => _tasks.add(task));
  }

  /// Removes a specific [task] from the batch.
  /// Returns `true` if the task was found and removed, `false` otherwise.
  bool removeTask(Task<T> task) {
    return _ifNotExecuting(() => _tasks.remove(task)) ?? false;
  }

  /// Adds multiple [Task] objects to the batch.
  void addAllTasks(Iterable<Task<T>> tasks) {
    _ifNotExecuting(() => _tasks.addAll(tasks));
  }

  /// Clears all tasks from the batch.
  ///
  /// Returns `true` if tasks were cleared, `false` if called during execution.
  bool clearTasks() {
    return _ifNotExecuting(() {
          _tasks.clear();
          return true;
        }) ??
        false;
  }

  /// Removes the first task from the batch.
  ///
  /// Returns `true` if a task was removed, `false` if the batch was empty or
  /// if called during execution.
  bool removeFirstTask() {
    return _ifNotExecuting(() {
          _tasks.removeFirst();
          return true;
        }) ??
        false;
  }

  /// Removes the last task from the batch.
  ///
  /// Returns `true` if a task was removed, `false` if the batch was empty or
  /// if called during execution.
  bool removeLastTask() {
    return _ifNotExecuting(() {
          _tasks.removeLast();
          return true;
        }) ??
        false;
  }

  /// Internal helper to ensure modifications are not made while the sequencer
  /// is busy.
  R? _ifNotExecuting<R>(R Function() caller) {
    assert(!_isExecuting);
    if (!_isExecuting) {
      return caller();
    }
    return null;
  }

  /// Executes all tasks in the batch concurrently.
  TResolvableOption<T> executeTasks() {
    final itemFactories = _tasks.map(
      (task) => () => task
          .handler(Ok(None<T>()))
          .withMinDuration(_minTaskDuration ?? task.minTaskDuration)
          .value,
    );
    _isExecuting = true;
    return Resolvable(
      () => waitF<Option<T>>(
        itemFactories,
        (_) => const None(),
        eagerError: _eagerError,
        onError: (error, stackTrace) {
          return _onError
              ?.call(
                Err(
                  error,
                  stackTrace: stackTrace,
                ),
              )
              .value;
        },
      ),
    ).whenComplete((e) {
      _isExecuting = false;
      return e;
    });
  }
}
