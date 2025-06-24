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

/// Manages a collection of [Task] objects that are intended to be executed
/// sequentially using a [TaskSequencer].
class SequencedTaskBatch<T extends Object> extends TaskBatchBase<T> {
  final TaskSequencer<T> _sequencer;

  @override
  bool get isExecuting => _sequencer.isExecuting;

  SequencedTaskBatch({
    TaskSequencer<T>? sequencer,
  })  : _sequencer = sequencer ?? TaskSequencer<T>(),
        super(); // Call base constructor

  factory SequencedTaskBatch.from(
    SequencedTaskBatch<T> other, {
    TaskSequencer<T>? sequencer,
  }) {
    // If a sequencer is provided, use it, otherwise, use the 'other's sequencer
    // or create a new one if 'other' also didn't have a specific one (though TaskSequencer default is new())
    final effectiveSequencer =
        sequencer ?? (other._sequencer); // Or just TaskSequencer<T>() if preferred
    final newBatch = SequencedTaskBatch<T>(sequencer: effectiveSequencer);
    newBatch.tasks = Queue.from(other.tasks); 
    return newBatch;
  }

  // The 'add' method from _TaskBatchBase can be inherited directly if its
  // parameter handling for eagerError/minTaskDuration is acceptable.
  // If SequencedTaskBatch needs to inject defaults based on _sequencer properties,
  // it would override 'add' like ConcurrentTaskBatch does.
  // For now, let's assume TaskSequencer's `then` method handles these defaults.

  @override
  TResolvableOption<T> executeTasks() {
    while (tasks.isNotEmpty) {
      _executeTask(tasks.removeFirst()).end();
    }
    return _sequencer.completion;
  }

  TResolvableOption<T> _executeTask(Task<T> task) {
    return _sequencer.then(
      task.handler,
      onPrevError: task.onError,
      eagerError: task.eagerError, // Pass through task's eagerError setting
      minTaskDuration: task.minTaskDuration, // Pass through task's duration setting
    );
  }
}
