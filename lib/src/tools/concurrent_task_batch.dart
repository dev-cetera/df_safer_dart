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

/// A task batch that executes its collection of tasks concurrently.
///
/// All tasks are started at the same time and run in parallel. The batch-level
/// `onError` and `eagerError` settings control how failures are handled across
/// the entire set of parallel operations.
class ConcurrentTaskBatch<T extends Object> extends TaskBatchBase<T> {
  final Duration? _minTaskDuration;
  final bool _eagerError;
  final TOnTaskError? _onError;

  bool _internalIsExecuting = false;

  @override
  bool get isExecuting => _internalIsExecuting;

  ConcurrentTaskBatch({
    bool eagerError = true,
    Duration? minTaskDuration,
    TOnTaskError? onError,
  })  : _eagerError = eagerError,
        _minTaskDuration = minTaskDuration,
        _onError = onError,
        super();

  /// Creates a new batch from an existing one, copying its configuration and tasks.
  factory ConcurrentTaskBatch.from(ConcurrentTaskBatch<T> other) {
    final newBatch = ConcurrentTaskBatch<T>(
      eagerError: other._eagerError,
      minTaskDuration: other._minTaskDuration,
      onError: other._onError,
    );
    newBatch.tasks = Queue.from(other.tasks);
    return newBatch;
  }

  /// Adds a task, applying batch-level defaults for any unspecified parameters.
  @override
  void add(
    @noFutures TTaskHandler<T> handler, {
    @noFutures TOnTaskError? onError,
    bool? eagerError,
    Duration? minTaskDuration,
  }) {
    final task = Task(
      handler: handler,
      onError: onError,
      eagerError: eagerError ?? _eagerError,
      minTaskDuration: minTaskDuration,
    );
    addTask(task);
  }

  /// Executes all tasks in the queue concurrently using a custom wait utility.
  ///
  /// The tasks are started in parallel, and this method returns a [Resolvable]
  /// that will complete once all tasks have finished.
  @override
  TResolvableOption<T> executeTasks() {
    final itemFactories = tasks.map(
      (task) => () => task
          .handler(Ok(None<T>()))
          .withMinDuration(_minTaskDuration ?? task.minTaskDuration)
          .value,
    );
    _internalIsExecuting = true;
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
      _internalIsExecuting = false;
      return e;
    });
  }
}
