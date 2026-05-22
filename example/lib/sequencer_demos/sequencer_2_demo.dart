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

// A runnable walkthrough of TaskSequencer behaviour. The previous version of
// this file was a `package:test` file that lived outside `test/`. The cases it
// covered now live in `test/abuse_tools_test.dart` / `test/hardening_test.dart`
// — this file is a demo, intended to be run with `dart run`.

import 'dart:async';

import 'package:df_safer_dart/df_safer_dart.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

Future<void> main() async {
  await _demoSequentialExecution();
  await _demoReentrantNoDeadlock();
  await _demoErrorPropagation();
  await _demoEagerError();
  await _demoMixedSyncAsync();
  print('\n=== sequencer_2_demo finished ===');
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

Future<void> _demoSequentialExecution() async {
  print('\n--- sequential execution ---');
  final sequencer = TaskSequencer<int>();
  final order = <int>[];

  sequencer.then((_) {
    order.add(1);
    return Sync.okValue(const Some(1));
  }).end();
  sequencer.then((_) {
    order.add(2);
    return Sync.okValue(const Some(2));
  }).end();
  await sequencer.then((_) {
    order.add(3);
    return Sync.okValue(const Some(3));
  }).value;

  _check('order is [1,2,3]', order.toString() == '[1, 2, 3]');
}

Future<void> _demoReentrantNoDeadlock() async {
  print('\n--- re-entrant tasks ---');
  final sequencer = TaskSequencer<int>();
  final order = <String>[];

  Resolvable<Option<int>> handlerC(Result<Option<int>> _) {
    order.add('C starts and ends');
    return Sync.okValue(const Some(3));
  }

  Resolvable<Option<int>> handlerB(Result<Option<int>> _) {
    order.add('B starts');
    return sequencer.then(handlerC).then((e) {
      order.add('B ends');
      return e;
    });
  }

  Resolvable<Option<int>> handlerA(Result<Option<int>> _) {
    order.add('A starts');
    return sequencer.then(handlerB).then((e) {
      order.add('A ends');
      return e;
    });
  }

  await sequencer.then(handlerA).value;

  _check(
    'A→B→C interleave is in order',
    order.toString() ==
        '[A starts, A ends, B starts, B ends, C starts and ends]',
  );
}

Future<void> _demoErrorPropagation() async {
  print('\n--- error propagation with onPrevError ---');
  final sequencer = TaskSequencer<int>(eagerError: false);
  final order = <String>[];
  Err<Object>? caught;

  sequencer.then((_) {
    order.add('task 1');
    return Sync.okValue(const Some(1));
  }).end();
  sequencer.then((_) {
    return Sync(() {
      order.add('task 2 (throws)');
      throw Exception('Something went wrong');
    });
  }).end();

  await sequencer.then(
    (prev) {
      order.add('task 3');
      return Sync.okValue(const Some(3));
    },
    onPrevError: (err) {
      caught = err;
      order.add('onError');
      return Sync.okValue(const None());
    },
  ).value;

  _check(
    'order matches expected',
    order.toString() == '[task 1, task 2 (throws), onError, task 3]',
  );
  _check('caught is non-null Err', caught != null);
}

Future<void> _demoEagerError() async {
  print('\n--- eagerError short-circuits ---');
  final sequencer = TaskSequencer<int>(eagerError: true);
  final order = <String>[];

  sequencer.then((_) {
    order.add('task 1');
    return Sync.okValue(const Some(1));
  }).end();
  sequencer.then((_) {
    return Sync(() {
      order.add('task 2 (throws)');
      throw Exception('boom');
    });
  }).end();
  final result = await sequencer.then((_) {
    order.add('task 3 (should NOT run)');
    return Sync.okValue(const Some(3));
  }).value;

  _check(
    'task 3 was skipped under eagerError',
    order.toString() == '[task 1, task 2 (throws)]',
  );
  _check('terminal result is an Err', result is Err);
}

Future<void> _demoMixedSyncAsync() async {
  print('\n--- mixed sync + async tasks ---');
  final sequencer = TaskSequencer<int>();
  final order = <String>[];
  final done = Completer<void>();

  sequencer.then((_) {
    order.add('sync 1');
    return Sync.okValue(const Some(1));
  }).end();
  sequencer.then((_) {
    return Async(() async {
      await Future<void>.delayed(const Duration(milliseconds: 10));
      order.add('async 2');
      return const Some(2);
    });
  }).end();
  sequencer.then((_) {
    order.add('sync 3');
    done.complete();
    return Sync.okValue(const Some(3));
  }).end();

  await done.future;

  _check(
    'mixed sequence ran in order',
    order.toString() == '[sync 1, async 2, sync 3]',
  );
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

void _check(String label, bool condition) {
  if (!condition) {
    throw StateError('  ✗ FAIL: $label');
  }
  print('  ✓ $label');
}
