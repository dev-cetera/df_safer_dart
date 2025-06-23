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

import 'dart:collection' show Queue;

import 'package:df_safer_dart_annotations/df_safer_dart_annotations.dart' show noFuturesAllowed;

import '/df_safer_dart.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

class SafeSequencer<T extends Object> {
  final _TOnPrevErr? _onPrevErr;
  final bool _eagerError;
  Resolvable<Option<T>> get current => _current;
  late var _current = Resolvable<Option<T>>(() => const None());
  bool _isExecutingHandler = false;
  final _reentrantQueue = Queue<_Task<T>>();

  SafeSequencer({
    _TOnPrevErr? onPrevErr,
    bool eagerError = false,
  })  : _onPrevErr = onPrevErr,
        _eagerError = eagerError;

  @pragma('vm:prefer-inline')
  Resolvable<Option<T>> get last => pushTask((e) => Sync.unsafe(e));

  /// Pushes a new task onto the end of the sequence.
  Resolvable<Option<T>> pushTask(
    @noFuturesAllowed _THandler<T> handler, {
    _TOnPrevErr? onPrevErr,
    bool? eagerError,
  }) {
    final task = _Task<T>(
      handler: handler,
      onPrevErr: onPrevErr,
      eagerError: eagerError,
    );
    if (_isExecutingHandler) {
      _reentrantQueue.add(task);
      return _current;
    }
    // Chain the new task onto the sequence.
    return _chainTask(task);
  }

  /// The **Scheduler**. Its role is to determine *when* to execute the next
  /// task, handling the sync/async nature of the sequence's current state.
  Resolvable<Option<T>> _chainTask(_Task<T> task) {
    final value = _current.value;

    if (value is Future<Result<Option<T>>>) {
      // Async Path: Schedule the next step to execute after the current Future completes.
      _current = Async(() async => _executeStep(task, await value)).flatten();
    } else {
      // Sync Path: Execute the next step immediately with the current value.
      _current = _executeStep(task, value);
    }
    return _current;
  }

  /// The **Executor**. Its role is to take the resolved value from the previous
  /// step and run the logic for the current task.
  Resolvable<Option<T>> _executeStep(
    _Task<T> task,
    Result<Option<T>> previousResult,
  ) {
    // Check if the previous step resulted in an error.
    switch (previousResult) {
      case Err err:
        _onPrevErr?.call(err);
        task.onPrevErr?.call(err);
        // If eager error is enabled, halt the chain by returning the current
        // state (which holds the error we just received) instead of executing
        // the next handler.
        if (task.eagerError ?? _eagerError) {
          return _current;
        }
      default:
      // No error, or not in eager mode, so proceed to execution.
    }
    // Execute the handler for the current task.
    return _executeHandler(task.handler, previousResult) ?? _current;
  }

  /// Safely executes the handler, managing re-entrant state.
  Resolvable<Option<T>>? _executeHandler(
    _THandler<T> handler,
    Result<Option<T>> previousValue,
  ) {
    _isExecutingHandler = true;
    try {
      return handler(previousValue);
    } finally {
      _isExecutingHandler = false;
      _processReentrantQueue();
    }
  }

  /// Processes tasks that were queued while a handler was executing.
  void _processReentrantQueue() {
    while (_reentrantQueue.isNotEmpty) {
      final task = _reentrantQueue.removeFirst();
      pushTask(
        task.handler,
        onPrevErr: task.onPrevErr,
        eagerError: task.eagerError,
      ).end();
    }
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

typedef _THandler<T extends Object> = Resolvable<Option<T>>? Function(Result<Option<T>> previous);

typedef _TOnPrevErr = void Function(Err err);

final class _Task<T extends Object> {
  final _THandler<T> handler;
  final _TOnPrevErr? onPrevErr;
  final bool? eagerError;

  const _Task({
    required this.handler,
    required this.onPrevErr,
    required this.eagerError,
  });
}
