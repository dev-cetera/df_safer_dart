// ignore_for_file: must_use_outcome_or_error
import 'dart:async';

import 'package:df_safer_dart/df_safer_dart.dart';
import 'package:test/test.dart';

void main() {
  group('TaskSequencer', () {
    test('should execute tasks sequentially', () async {
      final sequencer = TaskSequencer<int>();
      final executionOrder = <int>[];

      sequencer.then((_) {
        executionOrder.add(1);
        return Sync.okValue(const Some(1));
      });

      sequencer.then((_) {
        executionOrder.add(2);
        return Sync.okValue(const Some(2));
      });

      await sequencer.then((_) {
        executionOrder.add(3);
        return Sync.okValue(const Some(3));
      }).value;

      expect(executionOrder, [1, 2, 3]);
    });

    test('should handle re-entrant tasks without deadlock', () async {
      final sequencer = TaskSequencer<int>();
      final executionOrder = <String>[];

      Resolvable<Option<int>> handlerC(Result<Option<int>> previous) {
        executionOrder.add('C starts and ends');
        return Sync.okValue(const Some(3));
      }

      Resolvable<Option<int>> handlerB(Result<Option<int>> previous) {
        executionOrder.add('B starts');
        // Re-entrant call: Schedule C to run after B is done.
        return sequencer.then(handlerC).then((e) {
          executionOrder.add('B ends');
          return e;
        });
      }

      Resolvable<Option<int>> handlerA(Result<Option<int>> previous) {
        executionOrder.add('A starts');
        // Re-entrant call: Schedule B to run after A is done.
        return sequencer.then(handlerB).then((e) {
          executionOrder.add('A ends');
          return e;
        });
      }

      await sequencer.then(handlerA).value;

      expect(executionOrder, [
        'A starts',
        'A ends',
        'B starts',
        'B ends',
        'C starts and ends',
      ]);
    });

    test('should propagate errors and call onError handlers', () async {
      final sequencer = TaskSequencer<int>(eagerError: false);
      final executionOrder = <String>[];
      Err? caughtError;

      sequencer.then((_) {
        executionOrder.add('task 1');
        return Sync.okValue(const Some(1));
      });

      sequencer.then((_) {
        return Sync(() {
          executionOrder.add('task 2 (throws)');
          throw Exception('Something went wrong');
        });
      });

      await sequencer
          .then(
            (prev) {
              executionOrder.add('task 3');
              expect(prev, isA<Err>());
              return Sync.okValue(const Some(3));
            },
            onPrevError: (err) {
              caughtError = err;
              executionOrder.add('onError');
              return Sync.okValue(const None());
            },
          )
          .value;

      expect(executionOrder, [
        'task 1',
        'task 2 (throws)',
        'onError',
        'task 3',
      ]);
      expect(caughtError, isA<Err>());
      expect(
        (caughtError!.error as Exception).toString(),
        'Exception: Something went wrong',
      );
    });

    test('should short-circuit with eagerError', () async {
      final sequencer = TaskSequencer<int>(eagerError: true);
      final executionOrder = <String>[];

      sequencer.then((_) {
        executionOrder.add('task 1');
        return Sync.okValue(const Some(1));
      });

      sequencer.then((_) {
        return Sync(() {
          executionOrder.add('task 2 (throws)');
          throw Exception('Something went wrong');
        });
      });

      final result = await sequencer.then((_) {
        executionOrder.add('task 3 (should not run)');
        return Sync.okValue(const Some(3));
      }).value;

      expect(executionOrder, ['task 1', 'task 2 (throws)']);
      expect(result, isA<Err>());
      final error = (result as Err).error as Exception;
      expect(error.toString(), 'Exception: Something went wrong');
    });

    test('should handle mixed sync and async tasks', () async {
      final sequencer = TaskSequencer<int>();
      final executionOrder = <String>[];
      final completer = Completer<void>();

      sequencer.then((_) {
        executionOrder.add('sync 1');
        return Sync.okValue(const Some(1));
      });

      sequencer.then((_) {
        return Async(() async {
          await Future<void>.delayed(const Duration(milliseconds: 10));
          executionOrder.add('async 2');
          return const Some(2);
        });
      });

      sequencer.then((_) {
        executionOrder.add('sync 3');
        completer.complete();
        return Sync.okValue(const Some(3));
      });

      await completer.future;

      expect(executionOrder, ['sync 1', 'async 2', 'sync 3']);
    });
  });
}
