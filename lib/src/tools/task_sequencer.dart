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

class TaskSequencer<T extends Object> {
  //
  //
  //

  TaskSequencer({
    @noFutures TOnTaskError? onPrevError,
    bool eagerError = false,
    Duration? minTaskDuration,
  })  : _onPrevError = onPrevError,
        _eagerError = eagerError,
        _minTaskDuration = minTaskDuration;

  final TOnTaskError? _onPrevError;
  final bool _eagerError;
  final Duration? _minTaskDuration;

  //
  //
  //

  TResolvableOption<T> get completion => _current;
  late TResolvableOption<T> _current = Sync.okValue(const None());

  int _executionCount = 0;
  bool get isExecuting => _executionCount > 0;
  bool get isNotExecuting => !isExecuting;

  final _reentrantQueue = Queue<Task<T>>();

  //
  //
  //

  SequencedTaskBatch<T> newBatch() => SequencedTaskBatch(sequencer: this);

  //
  //
  //

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

  TResolvableOption<T> _chainTask(Task<T> task) {
    _executionCount++;
    final value = _current.value;
    if (value is TResultOption<T>) {
      _current = _executeStep(task, value);
    } else {
      _current = Async(() async => _executeStep(task, await value)).flatten();
    }

    final currentValue = _current.value;
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

  TResolvableOption<T> _executeStep(
    Task<T> task,
    TResultOption<T> previousResult,
  ) {
    Resolvable errorResolvable = resolvableNone();
    if (previousResult case Err err) {
      final a = Option.from(_onPrevError).map((e) => Resolvable(() => e(err)).flatten());
      final b = Option.from(task.onError).map((e) => Resolvable(() => e(err)).flatten());
      if ((a, b) case (Some(value: final someValueA), Some(value: final someValueB))) {
        errorResolvable = Resolvable.zip2(someValueA, someValueB);
      } else if (a case Some(value: final someValueA)) {
        errorResolvable = someValueA;
      } else if (b case Some(value: final someValueB)) {
        errorResolvable = someValueB;
      }
      if (task.eagerError ?? _eagerError) {
        final output = Sync.result(previousResult);
        return Resolvable.zip2(output, errorResolvable).then((e) => e.$1);
      }
    }
    final output = task.handler(previousResult).withMinDuration(
          task.minTaskDuration ?? _minTaskDuration,
        );
    return Resolvable.zip2(output, errorResolvable).then((e) => e.$1);
  }

  void _processReentrantQueue() {
    if (_reentrantQueue.isNotEmpty) {
      final nextTask = _reentrantQueue.removeFirst();
      _chainTask(nextTask).end();
    }
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

typedef TTaskHandler<T extends Object> = TResolvableOption<T> Function(TResultOption<T> previous);

typedef TOnTaskError = Resolvable Function(Err err);

final class Task<T extends Object> {
  @noFutures
  final TTaskHandler<T> handler;
  @noFutures
  final TOnTaskError? onError;
  final bool? eagerError;
  final Duration? minTaskDuration;

  const Task({
    required this.handler,
    required this.onError,
    required this.eagerError,
    required this.minTaskDuration,
  });
}
