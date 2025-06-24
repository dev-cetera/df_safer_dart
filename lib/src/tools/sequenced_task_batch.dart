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

class SequencedTaskBatch<T extends Object> {
  //
  //
  //

  SequencedTaskBatch({
    TaskSequencer<T>? sequencer,
  }) : _sequencer = sequencer ?? TaskSequencer<T>();

  factory SequencedTaskBatch.from(
    SequencedTaskBatch<T> other, {
    TaskSequencer<T>? sequencer,
  }) {
    return SequencedTaskBatch<T>(sequencer: sequencer).._tasks = Queue.from(other._tasks);
  }

  final TaskSequencer<T> _sequencer;
  var _tasks = Queue<Task<T>>.from([]);

  void add(
    @noFuturesAllowed TTaskHandler<T> handler, {
    @noFuturesAllowed TOnTaskError? onError,
    bool? eagerError,
    Duration? minTaskDuration,
  }) {
    final task = Task(
      handler: handler,
      onError: onError,
      eagerError: eagerError,
      minTaskDuration: minTaskDuration,
    );
    addTask(task);
  }

  void addTask(Task<T> task) {
    _ifNotExecuting(() => _tasks.add(task));
  }

  bool removeTask(Task<T> task) {
    return _ifNotExecuting(() => _tasks.remove(task)) ?? false;
  }

  void addAllTasks(Iterable<Task<T>> tasks) {
    _ifNotExecuting(() => _tasks.addAll(tasks));
  }

  bool clearTasks() {
    return _ifNotExecuting(() {
          _tasks.clear();
          return true;
        }) ??
        false;
  }

  bool removeFirstTask() {
    return _ifNotExecuting(() {
          _tasks.removeFirst();
          return true;
        }) ??
        false;
  }

  bool removeLastTask() {
    return _ifNotExecuting(() {
          _tasks.removeLast();
          return true;
        }) ??
        false;
  }

  R? _ifNotExecuting<R>(R Function() caller) {
    assert(_sequencer.isNotExecuting);
    if (_sequencer.isNotExecuting) {
      return caller();
    }
    return null;
  }

  TResolvableOption<T> executeTasks() {
    while (_tasks.isNotEmpty) {
      _executeTask(_tasks.removeFirst()).end();
    }
    return _sequencer.completion;
  }

  TResolvableOption<T> _executeTask(Task<T> task) {
    return _sequencer.then(
      task.handler,
      onPrevError: task.onError,
      eagerError: task.eagerError,
    );
  }
}
