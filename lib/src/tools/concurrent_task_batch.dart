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
class ConcurrentTaskBatch<T extends Object> extends TaskBatchBase<T> {
  final Duration? _minTaskDuration;
  final bool _eagerError; // Batch-level default for eagerError
  final TOnTaskError? _onError; // Batch-level default onError

  bool _internalIsExecuting = false; // Renamed to avoid conflict

  @override
  bool get isExecuting => _internalIsExecuting;

  ConcurrentTaskBatch({
    bool eagerError = true,
    Duration? minTaskDuration,
    TOnTaskError? onError,
  })  : _eagerError = eagerError,
        _minTaskDuration = minTaskDuration,
        _onError = onError,
        super(); // Call base constructor

  factory ConcurrentTaskBatch.from(ConcurrentTaskBatch<T> other) {
    final newBatch = ConcurrentTaskBatch<T>(
      eagerError: other._eagerError,
      minTaskDuration: other._minTaskDuration,
      onError: other._onError,
    );
    newBatch.tasks = Queue.from(other.tasks); // Copy tasks
    return newBatch;
  }

  /// Adds a new task to the batch, using batch-level defaults if specific
  /// parameters are not provided.
  @override
  void add(
    @noFutures TTaskHandler<T> handler, {
    @noFutures TOnTaskError? onError,
    bool? eagerError,
    Duration? minTaskDuration,
  }) {
    final task = Task(
      handler: handler,
      onError: onError, // Task-specific onError
      eagerError: eagerError ?? _eagerError, // Use batch default if null
      minTaskDuration: minTaskDuration, // Task-specific, no batch default here directly for 'Task'
    );
    addTask(task); // Calls base.addTask
  }

  @override
  TResolvableOption<T> executeTasks() {
    // Ensure tasks is accessible, might need to make it protected in base or use a getter
    final itemFactories = tasks.map(
      (task) => () => task
          .handler(Ok(None<T>())) // Concurrent tasks run independently initially
          .withMinDuration(_minTaskDuration ?? task.minTaskDuration)
          .value,
    );
    _internalIsExecuting = true;
    return Resolvable(
      () => waitF<Option<T>>(
        // Assuming waitF is a utility you have
        itemFactories,
        (_) => const None(), // Default value for each task if it succeeds with None
        eagerError: _eagerError, // Global eager error for the batch of futures
        onError: (error, stackTrace) {
          // This is for errors from waitF itself, or uncaught ones if eagerError=false
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
      _internalIsExecuting = false;
      return e; // Return the result of the whenComplete (which is the original result)
    });
  }
}
