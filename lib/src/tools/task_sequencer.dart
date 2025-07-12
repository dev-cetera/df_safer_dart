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

// ignore_for_file: no_future_outcome_type_or_error

import '/_common.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// Manages a chain of dependent tasks, ensuring they execute sequentially.
///
/// A `TaskSequencer` processes tasks one after another, passing the result of
/// the completed task to the next one in the chain. It supports both sync and
/// async tasks and includes a re-entrant queue to handle new tasks that are
/// added while an existing sequence is already running.
class TaskSequencer<T extends Object> {
  static TTaskHandler<T> convertHandler<T extends Object>(
    FutureOr<T?> Function(T? prev, Err? err) handler,
  ) {
    return (prev) {
      return Resolvable(() {
        final prevValue = prev.orNull()?.orNull();
        final err = prev.err().orNull();
        final nextValue = handler(prevValue, err);
        if (nextValue is Future<T?>) {
          return nextValue.then((e) => Option.from(e));
        }
        return Option.from(nextValue);
      });
    };
  }

  TaskSequencer({
    @noFutures TOnTaskError? onPrevError,
    bool eagerError = false,
    Duration? minTaskDuration,
  })  : _onPrevError = onPrevError,
        _eagerError = eagerError,
        _minTaskDuration = minTaskDuration;

  /// A global error handler for the sequence.
  final TOnTaskError? _onPrevError;

  /// The default error-handling strategy for the sequence.
  final bool _eagerError;

  /// The default minimum duration for tasks in the sequence.
  final Duration? _minTaskDuration;

  /// A [Resolvable] that represents the final result of the entire sequence.
  TResolvableOption<T> get completion => _current;

  /// The current state of the sequence, initialized to an empty success state.
  late TResolvableOption<T> _current = Sync.okValue(const None());

  /// A counter to track active task executions.
  int _executionCount = 0;
  bool get isExecuting => _executionCount > 0;
  bool get isNotExecuting => !isExecuting;

  /// A queue for tasks added via `then()` while the sequencer is busy.
  final _reentrantQueue = Queue<Task<T>>();

  /// Creates a new [SequencedTaskBatch] that is bound to this sequencer.
  SequencedTaskBatch<T> newBatch() => SequencedTaskBatch(sequencer: this);

  /// Appends a new task to the sequence.
  ///
  /// If the sequencer is already running, the task is added to a re-entrant
  /// queue to be processed after the current task completes. Otherwise, it is
  /// executed immediately.
  TResolvableOption<T> then(
    @noFutures TTaskHandler<T> handler, {
    @noFutures TOnTaskError? onPrevError,
    bool? eagerError,
    Duration? minTaskDuration,
  }) {
    final task = Task<T>(
      handler: handler,
      onError: onPrevError,
      eagerError: eagerError,
      minTaskDuration: minTaskDuration,
    );
    if (isExecuting) {
      _reentrantQueue.add(task);
      return _current;
    }
    return _chainTask(task);
  }

  /// Chains a new task to the current sequence's result.
  TResolvableOption<T> _chainTask(Task<T> task) {
    _executionCount++;
    final value = _current.value;

    // Determine if the next step needs to be async. If the previous result is
    // a future, the entire chain from this point must also be async.
    if (value is TResultOption<T>) {
      _current = _executeStep(task, value);
    } else {
      _current = Async(() async => _executeStep(task, await value)).flatten();
    }

    final currentValue = _current.value;
    // Decrement the execution counter and process the re-entrant queue
    // once the current task has fully completed (sync or async).
    if (currentValue is Future<TResultOption<T>>) {
      currentValue.whenComplete(() {
        _executionCount--;
        _processReentrantQueue();
      });
    } else {
      _executionCount--;
      _processReentrantQueue();
    }

    return _current;
  }

  /// Executes a single task, handling error propagation and side effects.
  TResolvableOption<T> _executeStep(
    Task<T> task,
    TResultOption<T> previousResult,
  ) {
    Resolvable errorResolvable;
    errorResolvable = resolvableNone();
    // If the previous task failed, run error handlers as side effects.
    if (previousResult case Err err) {
      final a = Option.from(
        _onPrevError,
      ).map((e) => Resolvable(() => e(err)).flatten());
      final b = Option.from(
        task.onError,
      ).map((e) => Resolvable(() => e(err)).flatten());
      if ((a, b)
          case (
            Some(value: final someValueA),
            Some(value: final someValueB),
          )) {
        errorResolvable = Resolvable.combine2(someValueA, someValueB);
      } else if (a case Some(value: final someValueA)) {
        errorResolvable = someValueA;
      } else if (b case Some(value: final someValueB)) {
        errorResolvable = someValueB;
      }

      // If eager error is enabled, short-circuit the sequence immediately,
      // but still allow the error handlers to complete.
      if (task.eagerError ?? _eagerError) {
        final output = Sync.result(previousResult);
        return Resolvable.combine2(output, errorResolvable).then((e) => e.$1);
      }
    }

    // Execute the main task handler.
    final output =
        task.handler(previousResult).withMinDuration(task.minTaskDuration ?? _minTaskDuration);
    // Combine the task's result with any error-handling side effects.
    return Resolvable.combine2(output, errorResolvable).then((e) => e.$1);
  }

  /// Processes the next task from the re-entrant queue if available.
  void _processReentrantQueue() {
    if (_reentrantQueue.isNotEmpty) {
      final nextTask = _reentrantQueue.removeFirst();
      _chainTask(nextTask).end();
    }
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// A function that defines a step in a task sequence.
/// It receives the result of the `previous` task.
typedef TTaskHandler<T extends Object> = TResolvableOption<T> Function(
  TResultOption<T> previous, //,
);

/// A function that handles an error from a previous task as a side-effect.
typedef TOnTaskError = Resolvable Function(Err err);

/// A data class representing a single, configured task in a sequence.
final class Task<T extends Object> {
  /// The core logic of the task.
  @noFutures
  final TTaskHandler<T> handler;

  /// An error handler specific to this task.
  @noFutures
  final TOnTaskError? onError;

  /// Overrides the sequencer's `eagerError` behavior for this task.
  final bool? eagerError;

  /// Overrides the sequencer's `minTaskDuration` for this task.
  final Duration? minTaskDuration;

  const Task({
    required this.handler,
    required this.onError,
    required this.eagerError,
    required this.minTaskDuration,
  });
}
