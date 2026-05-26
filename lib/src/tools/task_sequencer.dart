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

/// Manages a chain of dependent tasks, ensuring they execute sequentially.
///
/// A `TaskSequencer` processes tasks one after another, passing the result of
/// the completed task to the next one in the chain. It supports both sync and
/// async tasks and includes a re-entrant queue to handle new tasks that are
/// added while an existing sequence is already running.
///
/// ### Isolate sendability
///
/// A [TaskSequencer] is sendable through `SendPort` iff:
///
/// 1. Every handler ever passed to [then] / [TaskSequencer.new] (including
///    `onPrevError`) is a top-level function or static method — enforced by
///    the `@sendable` lint.
/// 2. The current [_current] result is a [Sync] (synchronous) outcome — the
///    moment any handler returns an [Async], `_current` becomes
///    isolate-local until that future settles. A freshly-constructed
///    sequencer satisfies this trivially.
class TaskSequencer<T extends Object> {
  static TTaskHandler<T> convertHandler<T extends Object>(
    @sendable FutureOr<T?> Function(T? prev, Err? err) handler,
  ) {
    return (prev) {
      return Resolvable(() {
        final prevValue = prev.orNull()?.orNull();
        final err = prev.err().orNull();
        final nextValue = handler(prevValue, err);
        if (nextValue is Future<T?>) {
          return nextValue.then(Option.from);
        }
        return Option.from(nextValue);
      });
    };
  }

  TaskSequencer({
    @noFutures @sendable TOnTaskError? onPrevError,
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
  @pragma('vm:prefer-inline')
  TResolvableOption<T> get completion => _current;

  /// The current state of the sequence, initialized to an empty success state.
  late TResolvableOption<T> _current = Sync.okValue(const None());

  /// A counter to track active task executions.
  int _executionCount = 0;
  @pragma('vm:prefer-inline')
  bool get isExecuting => _executionCount > 0;
  @pragma('vm:prefer-inline')
  bool get isNotExecuting => !isExecuting;

  /// A queue for tasks added via `then()` while the sequencer is busy.
  final _reentrantQueue = Queue<Task<T>>();

  /// Re-entrancy guard for [_processReentrantQueue]. Without this, a long
  /// chain of synchronous tasks would recurse one stack frame per task and
  /// stack-overflow under abusive enqueue patterns.
  bool _draining = false;

  /// Creates a new [SequencedTaskBatch] that is bound to this sequencer.
  @pragma('vm:prefer-inline')
  SequencedTaskBatch<T> newBatch() => SequencedTaskBatch(sequencer: this);

  /// Appends a new task to the sequence.
  ///
  /// If the sequencer is already running, the task is added to a re-entrant
  /// queue to be processed after the current task completes. Otherwise, it is
  /// executed immediately.
  TResolvableOption<T> then(
    @noFutures @sendable TTaskHandler<T> handler, {
    @noFutures @sendable TOnTaskError? onPrevError,
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
      unawaited(
        currentValue.whenComplete(() {
          _executionCount--;
          _processReentrantQueue();
        }),
      );
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
    // Fast path: previous task succeeded, no error handlers can fire. Run the
    // task handler and return its output directly — the previous form here
    // always allocated a `resolvableNone()` plus a `Resolvable.combine2(...)
    // .then((e) => e.$1)` even though both sides were no-ops on the Ok path.
    if (previousResult is! Err) {
      try {
        return task
            .handler(previousResult)
            .withMinDuration(task.minTaskDuration ?? _minTaskDuration);
      } on Err catch (err) {
        // Preserve a user-thrown Err verbatim — statusCode and breadcrumbs
        // are load-bearing in life-critical pipelines and must not be
        // silently wrapped by an outer Err.
        return Sync.err(err.transfErr<Option<T>>());
      } catch (error, stackTrace) {
        return Sync.err(Err<Option<T>>(error, stackTrace: stackTrace));
      }
    }

    // Error path: build up an optional `errorResolvable` running each
    // configured error handler as a side effect. Direct null checks avoid the
    // `Option.from(...).map(...)` round-trip of the previous implementation.
    final err = previousResult as Err<Option<T>>;
    Resolvable<Object>? errorResolvable;
    final onPrevError = _onPrevError;
    if (onPrevError != null) {
      errorResolvable = Resolvable(() => onPrevError(err)).flatten();
    }
    final taskOnError = task.onError;
    if (taskOnError != null) {
      final b = Resolvable(() => taskOnError(err)).flatten();
      errorResolvable =
          errorResolvable == null ? b : Resolvable.combine2(errorResolvable, b);
    }

    // If eager error is enabled, short-circuit the sequence immediately but
    // still allow the error handlers to complete.
    if (task.eagerError ?? _eagerError) {
      final shortCircuit = Sync.result(previousResult);
      if (errorResolvable == null) return shortCircuit;
      return Resolvable.combine2(shortCircuit, errorResolvable)
          .then((e) => e.$1);
    }

    // Execute the main task handler. Catch synchronous throws so they cannot
    // escape and leave _executionCount in a corrupt state — the contract is
    // "throws become Err on the chain". `on Err catch` preserves user-thrown
    // Err verbatim (statusCode/breadcrumbs intact).
    TResolvableOption<T> output;
    try {
      output = task
          .handler(previousResult)
          .withMinDuration(task.minTaskDuration ?? _minTaskDuration);
    } on Err catch (err) {
      output = Sync.err(err.transfErr<Option<T>>());
    } catch (error, stackTrace) {
      output = Sync.err(Err<Option<T>>(error, stackTrace: stackTrace));
    }
    if (errorResolvable == null) return output;
    return Resolvable.combine2(output, errorResolvable).then((e) => e.$1);
  }

  /// Drains the re-entrant queue iteratively.
  ///
  /// `_chainTask` synchronously re-invokes this method for sync tasks, so a
  /// naïve recursive implementation would consume one stack frame per
  /// enqueued task. The [_draining] guard keeps the recursive entry a no-op
  /// and lets the outer loop pick up the next task instead.
  void _processReentrantQueue() {
    if (_draining) return;
    _draining = true;
    try {
      while (_reentrantQueue.isNotEmpty && !isExecuting) {
        final nextTask = _reentrantQueue.removeFirst();
        _chainTask(nextTask).end();
      }
    } finally {
      _draining = false;
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
    @sendable required this.handler,
    @sendable required this.onError,
    required this.eagerError,
    required this.minTaskDuration,
  });
}
