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

// Chain-propagation matrix. The contract under test, for every supported
// shape of pipeline, is:
//
//   1. An error thrown from ANY step of the pipeline reaches the consumer at
//      the end of the chain as an `Err` — no throw escapes.
//   2. The originating step is identifiable from the final `Err` via the
//      `.named(label)` breadcrumb (first failing step wins, later `.named()`s
//      do not clobber it).
//   3. `statusCode` set at the throw site survives every intermediate
//      combinator (map / then / transf / flatMap / resultMap / fold / ifOk /
//      ifErr / whenComplete / reduce / combine* / Sync↔Async conversions /
//      type cast through `transf<R>()`).
//   4. The non-`Err`-typed throw (`StateError`, `FormatException`, custom
//      `Error`, raw `Object`) is wrapped into an `Err` whose `.error` keeps
//      the original instance — never silently swallowed.
//   5. After the failing step, no later step is executed — verified with
//      side-effect counters along the chain.
//
// The error-injection point is parameterized over the chain position. For a
// pipeline of N steps we run N separate test cases (one per injection index)
// and assert all the above on every one.
//
// Inline lambdas trip the `sendable` lint by design here.
// ignore_for_file: sendable, prefer_const_constructors

import 'package:df_safer_dart/df_safer_dart.dart';
import 'package:test/test.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
// Helpers
// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// Asserts [actual] is an `Err`, its `.error` matches [label] verbatim, its
/// `.statusCode` matches [code], and (when [breadcrumb] is provided) the
/// breadcrumb chain begins with [breadcrumb].
void expectFailure(
  Object actual, {
  required String label,
  required int code,
  String? breadcrumb,
}) {
  expect(actual, isA<Err>(), reason: 'expected Err but got $actual');
  final err = actual as Err;
  expect(err.error, label, reason: 'error payload mutated mid-chain');
  expect(
    err.statusCode.unwrap(),
    code,
    reason: 'statusCode must survive the whole pipeline',
  );
  if (breadcrumb != null) {
    expect(
      err.breadcrumbs,
      isNotEmpty,
      reason: 'breadcrumb missing — origin step is unrecoverable',
    );
    expect(
      err.breadcrumbs.first,
      breadcrumb,
      reason: 'breadcrumb must point at the originating step',
    );
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

void main() {
  // ───────────────────────────────────────────────────────────────────────────
  // Linear Sync pipeline: 8 steps, error injected at each k ∈ [0..7].
  // Verifies the Err reaches the end with breadcrumb identifying step k.
  // ───────────────────────────────────────────────────────────────────────────
  group('Linear Sync chain — error at every position', () {
    const stepCount = 8;
    for (var k = 0; k < stepCount; k++) {
      final injectAt = k;
      test('Sync chain: error injected at step $injectAt', () {
        // Track which steps actually ran. After the failing step nothing more
        // should execute — verified at the end.
        final executed = <int>[];

        var chain = Sync.okValue(0).named('s0');
        for (var i = 0; i < stepCount; i++) {
          final idx = i;
          chain = chain.map<int>((v) {
            executed.add(idx);
            if (idx == injectAt) {
              throw Err<int>(
                'failed-at-step-$idx',
                statusCode: 600 + idx,
              );
            }
            return v + 1;
          }).named('s${idx + 1}');
        }

        expectFailure(
          chain.value,
          label: 'failed-at-step-$injectAt',
          code: 600 + injectAt,
          breadcrumb: 's${injectAt + 1}',
        );
        // Every step up to and including the failing one ran; nothing after.
        expect(executed, List.generate(injectAt + 1, (i) => i));
      });
    }
  });

  // ───────────────────────────────────────────────────────────────────────────
  // Linear Async pipeline: same matrix, awaiting at the end.
  // ───────────────────────────────────────────────────────────────────────────
  group('Linear Async chain — error at every position', () {
    const stepCount = 8;
    for (var k = 0; k < stepCount; k++) {
      final injectAt = k;
      test('Async chain: error injected at step $injectAt', () async {
        final executed = <int>[];

        var chain = Async.okValue(0).named('a0');
        for (var i = 0; i < stepCount; i++) {
          final idx = i;
          chain = chain.then<int>((v) {
            executed.add(idx);
            if (idx == injectAt) {
              throw Err<int>(
                'async-fail-step-$idx',
                statusCode: 700 + idx,
              );
            }
            return v + 1;
          }).named('a${idx + 1}');
        }

        expectFailure(
          await chain.value,
          label: 'async-fail-step-$injectAt',
          code: 700 + injectAt,
          breadcrumb: 'a${injectAt + 1}',
        );
        expect(executed, List.generate(injectAt + 1, (i) => i));
      });
    }
  });

  // ───────────────────────────────────────────────────────────────────────────
  // Mixed Sync→Async chain — errors must cross the platform transition.
  // ───────────────────────────────────────────────────────────────────────────
  group('Mixed Sync↔Async chain — error at every position', () {
    const stepCount = 6;
    for (var k = 0; k < stepCount; k++) {
      final injectAt = k;
      test('Mixed chain: error at step $injectAt crosses sync↔async boundary',
          () async {
        final executed = <int>[];

        // Steps 0..2 are Sync, then toAsync() bridges into Async for 3..5.
        Resolvable<int> chain = Sync.okValue(0).named('m0');
        for (var i = 0; i < stepCount; i++) {
          final idx = i;
          // Bridge to async at the midpoint.
          if (idx == 3) {
            chain = chain.toAsync().named('bridge');
          }
          chain = chain.then<int>((v) {
            executed.add(idx);
            if (idx == injectAt) {
              throw Err<int>(
                'mixed-fail-step-$idx',
                statusCode: 800 + idx,
              );
            }
            return v + 1;
          }).named('m${idx + 1}');
        }

        final settled = chain.isAsync()
            ? await chain.async().unwrap().value
            : chain.sync().unwrap().value;
        expectFailure(
          settled,
          label: 'mixed-fail-step-$injectAt',
          code: 800 + injectAt,
          breadcrumb: 'm${injectAt + 1}',
        );
        expect(executed, List.generate(injectAt + 1, (i) => i));
      });
    }
  });

  // ───────────────────────────────────────────────────────────────────────────
  // Combinator variety — every supported callback shape on Sync surfaces the
  // throw as an Err, and the originating step is named.
  // ───────────────────────────────────────────────────────────────────────────
  group('Combinator variety on Sync — every shape absorbs and labels', () {
    test('map at position 1', () {
      final out = Sync.okValue(1)
          .named('start')
          .map<int>((v) => v + 1)
          .named('m')
          .map<int>((_) {
            throw Err<int>('map-explode', statusCode: 410);
          })
          .named('boom')
          .map<int>((v) => v + 1)
          .named('after');
      expectFailure(
        out.value,
        label: 'map-explode',
        code: 410,
        breadcrumb: 'boom',
      );
    });

    test('flatMap on Result step', () {
      final r = Ok<int>(1)
          .map((v) => v + 1)
          .flatMap<int>((_) => throw Err<int>('flatmap-bomb', statusCode: 411))
          .named('flatmap-step')
          .map((v) => v + 1);
      expectFailure(
        r,
        label: 'flatmap-bomb',
        code: 411,
        breadcrumb: 'flatmap-step',
      );
    });

    test('resultMap absorbs throw', () {
      final out = Sync.okValue(1)
          .resultMap<int>((_) => throw Err<int>('rm', statusCode: 412))
          .named('rm-step')
          .map((v) => v + 1)
          .named('after');
      expectFailure(out.value, label: 'rm', code: 412, breadcrumb: 'rm-step');
    });

    test('transf absorbs throw', () {
      final out = Sync.okValue(1)
          .transf<int>((_) => throw Err<int>('tr', statusCode: 413))
          .named('tr-step')
          .map((v) => v + 1);
      expectFailure(out.value, label: 'tr', code: 413, breadcrumb: 'tr-step');
    });

    test('ifOk side-effect absorbs throw', () {
      final out = Sync.okValue(1)
          .ifOk((_, __) => throw Err<int>('iok', statusCode: 414))
          .named('iok-step')
          .then((v) => v + 1);
      expectFailure(
        (out as Sync<int>).value,
        label: 'iok',
        code: 414,
        breadcrumb: 'iok-step',
      );
    });

    test('ifErr side-effect absorbs throw', () {
      final out = Sync<int>.errValue('seed', statusCode: 100)
          .ifErr((_, __) => throw Err<int>('ier', statusCode: 415))
          .named('ier-step');
      expectFailure(
        (out as Sync<int>).value,
        label: 'ier',
        code: 415,
        breadcrumb: 'ier-step',
      );
    });

    test('fold absorbs throw from onOk branch', () {
      final out = Sync.okValue(1).fold(
        (_) => throw Err<int>('fold-onok', statusCode: 416),
        (_) => null,
      );
      expectFailure(
        (out as Sync).value,
        label: 'fold-onok',
        code: 416,
      );
    });

    test('whenComplete absorbs throw', () {
      final out = Sync.okValue(1)
          .whenComplete<int>((_) => throw Err<int>('wc', statusCode: 417))
          .named('wc-step')
          .then((v) => v + 1);
      expectFailure(
        (out as Sync<int>).value,
        label: 'wc',
        code: 417,
        breadcrumb: 'wc-step',
      );
    });

    test('mapOk on Result absorbs throw', () {
      final out = Ok<int>(1)
          .mapOk((_) => throw Err<int>('mok', statusCode: 418))
          .named('mok-step');
      expectFailure(
        out,
        label: 'mok',
        code: 418,
        breadcrumb: 'mok-step',
      );
    });

    test('mapErr on Result absorbs throw', () {
      final out = Err<int>('seed', statusCode: 100)
          .mapErr((_) => throw Err<int>('merr', statusCode: 419))
          .named('merr-step');
      expectFailure(
        out,
        label: 'merr',
        code: 419,
        breadcrumb: 'merr-step',
      );
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // Combinator variety — Async path.
  // ───────────────────────────────────────────────────────────────────────────
  group('Combinator variety on Async — every shape absorbs and labels', () {
    test('then absorbs throw', () async {
      final out = await Async.okValue(1)
          .then<int>((_) => throw Err<int>('a-then', statusCode: 420))
          .named('a-then-step')
          .then((v) => v + 1)
          .value;
      expectFailure(
        out,
        label: 'a-then',
        code: 420,
        breadcrumb: 'a-then-step',
      );
    });

    test('resultMap absorbs throw', () async {
      final out = await Async.okValue(1)
          .resultMap<int>((_) => throw Err<int>('a-rm', statusCode: 421))
          .named('a-rm-step')
          .then((v) => v + 1)
          .value;
      expectFailure(
        out,
        label: 'a-rm',
        code: 421,
        breadcrumb: 'a-rm-step',
      );
    });

    test('transf absorbs throw', () async {
      final out = await Async.okValue(1)
          .transf<int>((_) => throw Err<int>('a-tr', statusCode: 422))
          .named('a-tr-step')
          .then((v) => v + 1)
          .value;
      expectFailure(
        out,
        label: 'a-tr',
        code: 422,
        breadcrumb: 'a-tr-step',
      );
    });

    test('ifOk absorbs throw', () async {
      final out = await Async.okValue(1)
          .ifOk((_, __) => throw Err<int>('a-iok', statusCode: 423))
          .named('a-iok-step')
          .async()
          .unwrap()
          .value;
      expectFailure(
        out,
        label: 'a-iok',
        code: 423,
        breadcrumb: 'a-iok-step',
      );
    });

    test('ifErr absorbs throw', () async {
      final out = await Async<int>.errValue(
        (error: 'seed', statusCode: 100),
      )
          .ifErr((_, __) => throw Err<int>('a-ier', statusCode: 424))
          .named('a-ier-step')
          .async()
          .unwrap()
          .value;
      expectFailure(
        out,
        label: 'a-ier',
        code: 424,
        breadcrumb: 'a-ier-step',
      );
    });

    test('whenComplete absorbs throw', () async {
      final out = await Async.okValue(1)
          .whenComplete<int>((_) => throw Err<int>('a-wc', statusCode: 425))
          .named('a-wc-step')
          .then((v) => v + 1)
          .value;
      expectFailure(
        out,
        label: 'a-wc',
        code: 425,
        breadcrumb: 'a-wc-step',
      );
    });

    test('fold absorbs throw from onAsync branch', () async {
      final out = Async.okValue(1).fold(
        (_) => null,
        (_) => throw Err<int>('a-fold', statusCode: 426),
      );
      expectFailure(
        await (out as Async).value,
        label: 'a-fold',
        code: 426,
      );
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // Non-Err throws are wrapped — `.error` keeps the original instance.
  // ───────────────────────────────────────────────────────────────────────────
  group('Non-Err throws are wrapped and reach the end of the chain', () {
    test('StateError in mid-chain Sync.map', () {
      final out = Sync.okValue(1)
          .map((v) => v + 1)
          .map<int>((_) => throw StateError('state-error-payload'))
          .named('state-step')
          .map((v) => v + 1);
      expect(out.value, isA<Err<int>>());
      final err = out.value as Err<int>;
      expect(err.error, isA<StateError>());
      expect((err.error as StateError).message, 'state-error-payload');
      expect(err.breadcrumbs, ['state-step']);
    });

    test('FormatException in mid-chain Async.then', () async {
      final out = await Async.okValue(1)
          .then((v) => v + 1)
          .then<int>((_) => throw FormatException('format-payload'))
          .named('fmt-step')
          .then((v) => v + 1)
          .value;
      expect(out, isA<Err<int>>());
      final err = out as Err<int>;
      expect(err.error, isA<FormatException>());
      expect(err.breadcrumbs, ['fmt-step']);
    });

    test('Custom Error subtype keeps its runtime type', () {
      final out = Sync.okValue(1)
          .map<int>((_) => throw _CustomError('custom-msg'))
          .named('custom-step');
      expect(out.value, isA<Err<int>>());
      final err = out.value as Err<int>;
      expect(err.error, isA<_CustomError>());
      expect((err.error as _CustomError).msg, 'custom-msg');
      expect(err.breadcrumbs, ['custom-step']);
    });

    test('Throwing a raw int does not crash; reaches end wrapped', () {
      // Yes, you can `throw 42` in Dart. The pipeline must still survive.
      final out =
          Sync.okValue(1).map<int>((_) => throw 42).named('int-throw-step');
      expect(out.value, isA<Err<int>>());
      expect((out.value as Err<int>).error, 42);
      expect((out.value as Err<int>).breadcrumbs, ['int-throw-step']);
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // Conversion errors — `transf<R>()` cast failure mid-chain.
  // ───────────────────────────────────────────────────────────────────────────
  group('Type conversion errors propagate through subsequent steps', () {
    test('transf<String>() on Sync<int> with incompatible payload', () {
      // No explicit transformer ⇒ falls back to `as R`; cast will fail at the
      // step and must reach the consumer as an Err.
      // ignore: unnecessary_cast
      final start = Sync.okValue(1) as Sync<int>;
      final out = start.transf<String>().named('cast-step').map((s) => '$s!');
      expect(out.value, isA<Err>());
      expect((out.value as Err).breadcrumbs, ['cast-step']);
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // reduce() — error introduced deep in a nested Option/Result/Resolvable
  // chain still surfaces, and an upstream `.named()` on an Err survives the
  // reduce(). The reduce contract intentionally drops breadcrumbs during the
  // flatten — but the *Err* itself (with its statusCode + stack trace) must
  // still reach the consumer.
  // ───────────────────────────────────────────────────────────────────────────
  group('reduce() — error mid-stack still reaches the consumer', () {
    test('Some(Some(Err)) reduces to an Err with statusCode intact', () async {
      final chain = Some(Some(Err<int>('deep-err', statusCode: 451)));
      final reduced = chain.reduce<int>();
      final settled = await reduced.value;
      expect(settled, isA<Err<Option<int>>>());
      final err = settled as Err<Option<int>>;
      expect(err.error, 'deep-err');
      expect(err.statusCode.unwrap(), 451);
    });

    test('Ok(Some(Sync(Err))) — error inside async-bridged layer', () async {
      final chain = Ok(Some(Sync.err(Err<int>('inner-err', statusCode: 452))));
      final reduced = chain.reduce<int>();
      final settled = await reduced.value;
      expect(settled, isA<Err<Option<int>>>());
      final err = settled as Err;
      expect(err.error, 'inner-err');
      expect(err.statusCode.unwrap(), 452);
    });

    test('Async(throw) wrapped in Some(Ok(...)) reduces to an Err', () async {
      // The Async absorbs its own throw into an Err, then reduce surfaces it.
      final inner = Async<int>(
        () async => throw Err<int>('async-deep', statusCode: 453),
      );
      final chain = Some(Ok(inner));
      final settled = await chain.reduce<int>().value;
      expect(settled, isA<Err<Option<int>>>());
      final err = settled as Err;
      expect(err.error, 'async-deep');
      expect(err.statusCode.unwrap(), 453);
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // combine* — a failing chain inside the combined list short-circuits to its
  // Err, with breadcrumbs identifying the failing branch.
  // ───────────────────────────────────────────────────────────────────────────
  group('combine* — failing branch identifies itself in the result', () {
    test('combineSync: one branch fails mid-pipeline, name reaches caller', () {
      Sync<int> okBranch(int seed, String label) =>
          Sync.okValue(seed).map((v) => v + 1).named(label);

      Sync<int> failingBranch() => Sync.okValue(1)
          .map((v) => v + 1)
          .map<int>((_) => throw Err<int>('branch-fail', statusCode: 460))
          .named('failing-branch');

      final combined = combineSync<int>([
        okBranch(1, 'b1'),
        failingBranch(),
        okBranch(3, 'b3'),
      ]);
      expectFailure(
        combined.value,
        label: 'branch-fail',
        code: 460,
        breadcrumb: 'failing-branch',
      );
    });

    test('combineAsync: failing branch carries its name through Future.wait',
        () async {
      Async<int> okBranch(int seed, String label) =>
          Async.okValue(seed).then((v) => v + 1).named(label);

      Async<int> failingBranch() => Async.okValue(1)
          .then((v) => v + 1)
          .then<int>(
              (_) => throw Err<int>('async-branch-fail', statusCode: 461))
          .named('async-failing-branch');

      final combined = combineAsync<int>([
        okBranch(10, 'ab1'),
        failingBranch(),
        okBranch(30, 'ab3'),
      ]);
      expectFailure(
        await combined.value,
        label: 'async-branch-fail',
        code: 461,
        breadcrumb: 'async-failing-branch',
      );
    });

    test('combineResolvable: mixed sync+async with failing async branch',
        () async {
      final combined = combineResolvable<int>([
        Sync.okValue(1).named('sync-leg'),
        Async.okValue(2)
            .then<int>(
                (_) => throw Err<int>('mixed-branch-fail', statusCode: 462))
            .named('async-leg'),
        Sync.okValue(3),
      ]);
      expectFailure(
        await combined.value,
        label: 'mixed-branch-fail',
        code: 462,
        breadcrumb: 'async-leg',
      );
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // Post-failure short-circuit — after the failing step, NOTHING downstream
  // observes the failure as a fresh value: counters confirm that subsequent
  // map/then bodies do not execute. Also re-checks .named() does not overwrite.
  // ───────────────────────────────────────────────────────────────────────────
  group('Short-circuit guarantees after the failing step', () {
    test('Sync chain: 5 downstream steps never execute', () {
      var afterCount = 0;
      final chain = Sync.okValue(1)
          .map<int>((_) => throw Err<int>('boom', statusCode: 470))
          .named('boom-step');
      final out = chain.map((v) {
        afterCount++;
        return v;
      }).map((v) {
        afterCount++;
        return v;
      }).map((v) {
        afterCount++;
        return v;
      }).map((v) {
        afterCount++;
        return v;
      }).map((v) {
        afterCount++;
        return v;
      }).named('never-runs');
      expect(afterCount, 0);
      expectFailure(
        out.value,
        label: 'boom',
        code: 470,
        breadcrumb: 'boom-step',
      );
    });

    test('Async chain: 5 downstream steps never execute', () async {
      var afterCount = 0;
      final chain = Async.okValue(1)
          .then<int>((_) => throw Err<int>('a-boom', statusCode: 471))
          .named('a-boom-step');
      final out = await chain
          .then((v) {
            afterCount++;
            return v;
          })
          .then((v) {
            afterCount++;
            return v;
          })
          .then((v) {
            afterCount++;
            return v;
          })
          .then((v) {
            afterCount++;
            return v;
          })
          .then((v) {
            afterCount++;
            return v;
          })
          .named('a-never-runs')
          .value;
      expect(afterCount, 0);
      expectFailure(
        out,
        label: 'a-boom',
        code: 471,
        breadcrumb: 'a-boom-step',
      );
    });

    test('Later .named() does not overwrite the originating step', () {
      final out = Sync.okValue(1)
          .map<int>((_) => throw Err<int>('first', statusCode: 480))
          .named('origin')
          .map((v) => v + 1)
          .named('after-1')
          .map((v) => v + 1)
          .named('after-2');
      expect(out.value, isA<Err<int>>());
      final err = out.value as Err<int>;
      expect(
        err.breadcrumbs,
        ['origin'],
        reason: 'first .named() to see the Err wins; later are no-ops',
      );
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // statusCode + stackTrace survive every kind of transformation along the
  // chain — including `transfErr<R>()` triggered by `map`/`transf`/`mapErr` on
  // an `Err` (which changes the generic type but should keep statusCode and
  // stackTrace).
  // ───────────────────────────────────────────────────────────────────────────
  group('statusCode + stackTrace survive every transformation', () {
    test('Err.transfErr through repeated type changes', () {
      final original = Err<int>('payload', statusCode: 490);
      final originalStack = original.stackTrace.toString();
      // Cast across many types: int → String → bool → double → List<int>.
      final r = original
          .transfErr<String>()
          .transfErr<bool>()
          .transfErr<double>()
          .transfErr<List<int>>();
      expect(r.error, 'payload');
      expect(r.statusCode.unwrap(), 490);
      expect(r.stackTrace.toString(), originalStack);
    });

    test('map on Err just passes through with statusCode preserved', () {
      final original = Err<int>('passthrough', statusCode: 491);
      final originalStack = original.stackTrace.toString();
      // Force the type through several maps — each .map on Err transferErr's.
      final out = (original as Result<int>)
          .map<String>((v) => '$v')
          .map((s) => s.length)
          .map((n) => n.toDouble());
      expect(out, isA<Err>());
      final err = out as Err;
      expect(err.error, 'passthrough');
      expect(err.statusCode.unwrap(), 491);
      expect(err.stackTrace.toString(), originalStack);
    });

    test('Sync→Async conversion preserves statusCode', () async {
      final out = await Sync<int>.errValue('seed-from-sync', statusCode: 492)
          .toAsync()
          .then((v) => v + 1)
          .value;
      expectFailure(out, label: 'seed-from-sync', code: 492);
    });

    test('Async→Sync attempt on real Async failure preserves statusCode',
        () async {
      // `Async.sync()` returns an Err (it's a no-op type-shift, not a wait).
      // The actual Err materializes via `await .value`. Either way the
      // statusCode survives.
      final a = Async<int>(
        () async => throw Err<int>('async-seed', statusCode: 493),
      );
      final viaValue = await a.value;
      expectFailure(viaValue, label: 'async-seed', code: 493);
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // Worst-case pipeline: a long chain mixing every combinator (map / transf /
  // resultMap / fold / ifOk / whenComplete / toAsync / then) with the error
  // thrown by a deeply nested helper. The single Err must reach the consumer
  // identified by the `.named()` of the first failing step.
  // ───────────────────────────────────────────────────────────────────────────
  group('Worst-case mixed-combinator chain', () {
    int nestedThrower(int v) {
      // Three function frames deep.
      int level3() => throw Err<int>('nested-deep', statusCode: 599);
      int level2() => level3();
      int level1() => level2();
      return level1();
    }

    test('Sync side: nested thrower at step 4 of 8', () {
      final out = Sync.okValue(0)
          .map((v) => v + 1)
          .named('s1')
          .resultMap<int>((r) => Ok(r.unwrap() + 1))
          .named('s2')
          .transf<int>((v) => v + 1)
          .named('s3')
          .map<int>(nestedThrower)
          .named('s4-throws')
          .ifOk((_, __) {})
          .named('s5')
          .then((v) => v + 1)
          .named('s6')
          .whenComplete<int>((s) => s)
          .named('s7')
          .then((v) => v + 1)
          .named('s8');
      // After the `whenComplete`, we have a Resolvable<int>; cast through Sync.
      final settled = (out as Sync<int>).value;
      expectFailure(
        settled,
        label: 'nested-deep',
        code: 599,
        breadcrumb: 's4-throws',
      );
    });

    test('Async side: nested thrower with toAsync bridge', () async {
      final out = await Sync.okValue(0)
          .map((v) => v + 1)
          .named('a1')
          .transf<int>((v) => v + 1)
          .named('a2')
          .toAsync()
          .named('a-bridge')
          .then((v) => v + 1)
          .named('a3')
          .then<int>(nestedThrower)
          .named('a4-throws')
          .then((v) => v + 1)
          .named('a5')
          .then((v) => v + 1)
          .named('a6')
          .value;
      expectFailure(
        out,
        label: 'nested-deep',
        code: 599,
        breadcrumb: 'a4-throws',
      );
    });
  });
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

class _CustomError extends Error {
  _CustomError(this.msg);
  final String msg;
  @override
  String toString() => 'CustomError($msg)';
}
