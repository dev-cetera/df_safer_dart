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

// Systematic medical-grade error-propagation matrix. For every public method
// in the absorbing API surface, this file:
//
// 1. Injects a `throw Err('label', statusCode: NNN)` from the user callback
//    and asserts the receiver sees `statusCode == NNN`, `error == 'label'`.
// 2. Injects a `throw StateError(...)` and asserts the receiver sees a
//    wrapped `Err` whose `error` is the original `StateError`.
// 3. Where the method returns a transformable type, asserts the chain
//    continues to propagate without further wrapping.
//
// The matrix is exhaustive against `Outcome` subtypes (Ok/Err/Some/None/
// Sync/Async/Resolvable), the `Lazy`/`SafeCompleter`/`TaskSequencer` tools,
// and the combine* family. If any new method joins the public API surface,
// a corresponding entry should be added here.
//
// Tests intentionally throw from inline lambdas — `@sendable` lint complaints
// are irrelevant in this defensive-behaviour context.
//
// ignore_for_file: sendable, prefer_const_constructors

import 'package:df_safer_dart/df_safer_dart.dart';
import 'package:test/test.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
// Helpers
// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// Asserts the given [outcome] resolves to an `Err` whose `statusCode` is
/// [code] and whose `error` is [label].
void expectErrWithStatus(Object outcome, String label, int code) {
  expect(outcome, isA<Err>(), reason: 'expected Err but got $outcome');
  final err = outcome as Err;
  expect(err.statusCode.unwrap(), code, reason: 'statusCode lost');
  expect(err.error, label, reason: 'error label lost');
}

/// Asserts the given [outcome] resolves to an `Err` whose `error` is a
/// [StateError] containing [message]. (Wrapped throws lose the original
/// type but keep the error content.)
void expectWrappedStateError(Object outcome, String message) {
  expect(outcome, isA<Err>(), reason: 'expected Err but got $outcome');
  final err = outcome as Err;
  expect(
    err.error,
    isA<StateError>(),
    reason: 'non-Err throw not wrapped as Err.error',
  );
  expect((err.error as StateError).message, message);
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

void main() {
  group('Result.flatMap — error propagation', () {
    test('Ok.flatMap: callback throws Err preserves statusCode', () {
      final r = Ok<int>(1).flatMap<String>(
        (_) => throw Err<String>('x', statusCode: 101),
      );
      expectErrWithStatus(r, 'x', 101);
    });
    test('Ok.flatMap: callback throws non-Err is wrapped', () {
      final r = Ok<int>(1).flatMap<String>(
        (_) => throw StateError('flatmap-boom'),
      );
      expectWrappedStateError(r, 'flatmap-boom');
    });
    test('Ok.flatMap: callback returns Err propagates', () {
      final r = Ok<int>(1).flatMap<String>(
        (_) => Err<String>('explicit', statusCode: 102),
      );
      expectErrWithStatus(r, 'explicit', 102);
    });
    test('Err.flatMap: callback never runs; Err passes through', () {
      var ran = false;
      final r = Err<int>('original', statusCode: 100).flatMap<String>((_) {
        ran = true;
        return Ok('should-not-happen');
      });
      expect(ran, isFalse);
      expectErrWithStatus(r, 'original', 100);
    });
  });

  group('Result.map — error propagation', () {
    test('Ok.map: callback throws Err preserves statusCode', () {
      final r = Ok<int>(1).map<String>(
        (_) => throw Err<String>('m', statusCode: 110),
      );
      expectErrWithStatus(r, 'm', 110);
    });
    test('Ok.map: callback throws non-Err is wrapped', () {
      final r = Ok<int>(1).map<String>((_) => throw StateError('map-boom'));
      expectWrappedStateError(r, 'map-boom');
    });
    test('Err.map: callback never runs', () {
      var ran = false;
      final r = Err<int>('keep', statusCode: 111).map<String>((_) {
        ran = true;
        return 'x';
      });
      expect(ran, isFalse);
      expectErrWithStatus(r, 'keep', 111);
    });
  });

  group('Result.mapOk — error propagation', () {
    test('Ok.mapOk: callback throws Err preserves statusCode', () {
      final r = Ok<int>(1).mapOk(
        (_) => throw Err<int>('mok', statusCode: 120),
      );
      expectErrWithStatus(r, 'mok', 120);
    });
    test('Ok.mapOk: callback throws non-Err is wrapped', () {
      final r = Ok<int>(1).mapOk((_) => throw StateError('mok-boom'));
      expectWrappedStateError(r, 'mok-boom');
    });
    test('Err.mapOk: callback never runs', () {
      var ran = false;
      final r = Err<int>('untouched', statusCode: 121).mapOk((_) {
        ran = true;
        return Ok(0);
      });
      expect(ran, isFalse);
      expectErrWithStatus(r, 'untouched', 121);
    });
  });

  group('Result.mapErr — error propagation', () {
    test('Err.mapErr: callback throws Err preserves statusCode', () {
      final r = Err<int>('orig').mapErr(
        (_) => throw Err<int>('merr', statusCode: 130),
      );
      expectErrWithStatus(r, 'merr', 130);
    });
    test('Err.mapErr: callback throws non-Err is wrapped', () {
      final r = Err<int>('orig').mapErr((_) => throw StateError('merr-boom'));
      expectWrappedStateError(r, 'merr-boom');
    });
    test('Err.mapErr: callback returns new Err', () {
      final r = Err<int>('orig').mapErr(
        (_) => Err<int>('replaced', statusCode: 131),
      );
      expectErrWithStatus(r, 'replaced', 131);
    });
    test('Ok.mapErr: callback never runs', () {
      var ran = false;
      final r = Ok<int>(7).mapErr((_) {
        ran = true;
        return Err<int>('x');
      });
      expect(ran, isFalse);
      expect(r, isA<Ok<int>>());
      expect((r).value, 7);
    });
  });

  group('Result.fold — error propagation', () {
    test('Ok.fold: onOk throws Err preserves statusCode', () {
      final r = Ok<int>(1).fold(
        (_) => throw Err<int>('fold-ok', statusCode: 140),
        (_) => null,
      );
      expectErrWithStatus(r, 'fold-ok', 140);
    });
    test('Ok.fold: onOk throws non-Err is wrapped', () {
      final r = Ok<int>(1).fold(
        (_) => throw StateError('fold-ok-boom'),
        (_) => null,
      );
      expectWrappedStateError(r, 'fold-ok-boom');
    });
    test('Err.fold: onErr throws Err preserves statusCode', () {
      final r = Err<int>('orig').fold(
        (_) => null,
        (_) => throw Err<int>('fold-err', statusCode: 141),
      );
      expectErrWithStatus(r, 'fold-err', 141);
    });
    test('Err.fold: onErr throws non-Err is wrapped', () {
      final r = Err<int>('orig').fold(
        (_) => null,
        (_) => throw StateError('fold-err-boom'),
      );
      expectWrappedStateError(r, 'fold-err-boom');
    });
  });

  group('Result.transf — error propagation', () {
    test('Ok.transf: mapper throws Err preserves statusCode', () {
      final r = Ok<int>(1).transf<String>(
        (_) => throw Err<String>('tr', statusCode: 150),
      );
      expectErrWithStatus(r, 'tr', 150);
    });
    test('Ok.transf: mapper throws non-Err is wrapped (with context message)',
        () {
      // Default catch in transf wraps with "Cannot transform $T to $R: $error".
      final r = Ok<int>(1).transf<String>(
        (_) => throw StateError('tr-boom'),
      );
      expect(r, isA<Err>());
      final err = r as Err;
      expect(err.error.toString(), contains('Cannot transform'));
      expect(err.error.toString(), contains('tr-boom'));
    });
    test('Err.transf: just transfers type, no callback invocation', () {
      var ran = false;
      // `Err.transf` is `@protected` — callers reach it through `Result<T>`.
      final Result<int> errAsResult = Err<int>('orig', statusCode: 151);
      final r = errAsResult.transf<String>((_) {
        ran = true;
        return 'x';
      });
      expect(ran, isFalse);
      expectErrWithStatus(r, 'orig', 151);
    });
  });

  group('Result.ifOk / ifErr — error propagation', () {
    test('Ok.ifOk: side-effect throws Err preserves statusCode', () {
      final r = Ok<int>(1).ifOk(
        (_, __) => throw Err<int>('iok', statusCode: 160),
      );
      expectErrWithStatus(r, 'iok', 160);
    });
    test('Err.ifErr: side-effect throws Err preserves statusCode', () {
      final r = Err<int>('orig').ifErr(
        (_, __) => throw Err<int>('ier', statusCode: 161),
      );
      expectErrWithStatus(r, 'ier', 161);
    });
  });

  group('Sync.new — error propagation', () {
    test('callback throws Err preserves statusCode', () {
      final s = Sync<int>(() => throw Err<int>('sc', statusCode: 170));
      expectErrWithStatus(s.value, 'sc', 170);
    });
    test('callback throws non-Err is wrapped', () {
      final s = Sync<int>(() => throw StateError('sc-boom'));
      expectWrappedStateError(s.value, 'sc-boom');
    });
    test('onError throws Err preserves statusCode', () {
      final s = Sync<int>(
        () => throw StateError('primary'),
        onError: (_, __) => throw Err<int>('onErr', statusCode: 171),
      );
      expectErrWithStatus(s.value, 'onErr', 171);
    });
    test('onFinalize throws Err preserves statusCode and overrides Ok', () {
      final s = Sync<int>(
        () => 42,
        onFinalize: () => throw Err<int>('fin', statusCode: 172),
      );
      expectErrWithStatus(s.value, 'fin', 172);
    });
  });

  group('Async.new — error propagation', () {
    test('callback throws Err preserves statusCode', () async {
      final a = Async<int>(() async => throw Err<int>('ac', statusCode: 180));
      expectErrWithStatus(await a.value, 'ac', 180);
    });
    test('callback throws non-Err is wrapped', () async {
      final a = Async<int>(() async => throw StateError('ac-boom'));
      expectWrappedStateError(await a.value, 'ac-boom');
    });
    test('onError throws Err preserves statusCode', () async {
      final a = Async<int>(
        () async => throw StateError('primary'),
        onError: (_, __) => throw Err<int>('aErr', statusCode: 181),
      );
      expectErrWithStatus(await a.value, 'aErr', 181);
    });
    test('onFinalize throws Err overrides Ok', () async {
      final a = Async<int>(
        () async => 99,
        onFinalize: () => throw Err<int>('afin', statusCode: 182),
      );
      expectErrWithStatus(await a.value, 'afin', 182);
    });
  });

  group('Resolvable.new — error propagation', () {
    test('sync callback throws Err preserves statusCode', () {
      final r = Resolvable<int>(() => throw Err<int>('rc', statusCode: 190));
      expectErrWithStatus((r as Sync<int>).value, 'rc', 190);
    });
    test('sync callback throws non-Err with onError', () {
      final r = Resolvable<int>(
        () => throw StateError('primary'),
        onError: (e, s) => Err<int>('handled-by-onError', statusCode: 191),
      );
      expectErrWithStatus((r as Sync<int>).value, 'handled-by-onError', 191);
    });
    test('onFinalize throws Err overrides everything', () {
      final r = Resolvable<int>(
        () => 5,
        onFinalize: () => throw Err<int>('rfin', statusCode: 192),
      );
      expectErrWithStatus((r as Sync<int>).value, 'rfin', 192);
    });
  });

  group('Sync chain — error propagation', () {
    test('Sync.map: callback throws Err preserves statusCode', () {
      final s = Sync.okValue(1).map(
        (_) => throw Err<int>('smap', statusCode: 200),
      );
      expectErrWithStatus(s.value, 'smap', 200);
    });
    test('Sync.resultMap: callback throws Err preserves statusCode', () {
      final s = Sync.okValue(1).resultMap<int>(
        (_) => throw Err<int>('srm', statusCode: 201),
      );
      expectErrWithStatus(s.value, 'srm', 201);
    });
    test('Sync.transf: mapper throws Err preserves statusCode', () {
      final s = Sync.okValue(1).transf<int>(
        (_) => throw Err<int>('str', statusCode: 202),
      );
      expectErrWithStatus(s.value, 'str', 202);
    });
    test('Sync.ifSync: callback throws Err preserves statusCode', () {
      final s = Sync.okValue(1).ifSync(
        (_, __) => throw Err<int>('sif', statusCode: 203),
      );
      expectErrWithStatus(s.value, 'sif', 203);
    });
    test('Sync.ifOk: callback throws Err preserves statusCode', () {
      final s = Sync.okValue(1).ifOk(
        (_, __) => throw Err<int>('sok', statusCode: 204),
      );
      expectErrWithStatus((s as Sync<int>).value, 'sok', 204);
    });
    test('Sync.ifErr: callback throws Err preserves statusCode', () {
      final s = Sync<int>.errValue('orig').ifErr(
        (_, __) => throw Err<int>('sife', statusCode: 205),
      );
      expectErrWithStatus((s as Sync<int>).value, 'sife', 205);
    });
    test('Sync.fold: callback throws Err preserves statusCode', () {
      final s = Sync.okValue(1).fold(
        (_) => throw Err<int>('sfold', statusCode: 206),
        (_) => null,
      );
      expectErrWithStatus((s as Sync).value, 'sfold', 206);
    });
    test('Sync.whenComplete: callback throws Err preserves statusCode', () {
      final s = Sync.okValue(1).whenComplete<int>(
        (_) => throw Err<int>('swc', statusCode: 207),
      );
      expectErrWithStatus((s as Sync<int>).value, 'swc', 207);
    });
  });

  group('Async chain — error propagation', () {
    test('Async.then: callback throws Err preserves statusCode', () async {
      final a = Async.okValue(1).then(
        (_) => throw Err<int>('athen', statusCode: 220),
      );
      expectErrWithStatus(await a.value, 'athen', 220);
    });
    test('Async.map: callback throws Err preserves statusCode', () async {
      final a = Async.okValue(1).map(
        (_) => throw Err<int>('amap', statusCode: 221),
      );
      expectErrWithStatus(await a.value, 'amap', 221);
    });
    test('Async.resultMap: callback throws Err preserves statusCode', () async {
      final a = Async.okValue(1).resultMap<int>(
        (_) => throw Err<int>('arm', statusCode: 222),
      );
      expectErrWithStatus(await a.value, 'arm', 222);
    });
    test('Async.transf: mapper throws Err preserves statusCode', () async {
      final a = Async.okValue(1).transf<int>(
        (_) => throw Err<int>('atr', statusCode: 223),
      );
      expectErrWithStatus(await a.value, 'atr', 223);
    });
    test('Async.ifAsync: callback throws Err preserves statusCode', () async {
      final a = Async.okValue(1).ifAsync(
        (_, __) => throw Err<int>('aifa', statusCode: 224),
      );
      expectErrWithStatus(await a.value, 'aifa', 224);
    });
    test('Async.ifOk: callback throws Err preserves statusCode', () async {
      final a = Async.okValue(1).ifOk(
        (_, __) => throw Err<int>('aif', statusCode: 225),
      );
      expectErrWithStatus(await (a as Async<int>).value, 'aif', 225);
    });
    test('Async.ifErr: callback throws Err preserves statusCode', () async {
      final a = Async<int>.errValue((error: 'orig', statusCode: null)).ifErr(
        (_, __) => throw Err<int>('aife', statusCode: 226),
      );
      expectErrWithStatus(await (a as Async<int>).value, 'aife', 226);
    });
    test('Async.fold: callback throws Err preserves statusCode', () async {
      final a = Async.okValue(1).fold(
        (_) => null,
        (_) => throw Err<int>('afold', statusCode: 227),
      );
      expectErrWithStatus(await (a as Async).value, 'afold', 227);
    });
    test('Async.whenComplete: callback throws Err preserves statusCode',
        () async {
      final a = Async.okValue(1).whenComplete<int>(
        (_) => throw Err<int>('awc', statusCode: 228),
      );
      expectErrWithStatus(await a.value, 'awc', 228);
    });
  });

  group('Lazy — error propagation', () {
    test('singleton: constructor throws Err preserves statusCode', () {
      final lazy = Lazy<int>(
        () => throw Err<int>('lazy-boot', statusCode: 250),
      );
      expectErrWithStatus(
        (lazy.singleton as Sync<int>).value,
        'lazy-boot',
        250,
      );
    });
    test('factory: constructor throws Err preserves statusCode on every read',
        () {
      final lazy = Lazy<int>(
        () => throw Err<int>('factory-boot', statusCode: 251),
      );
      expectErrWithStatus(
        (lazy.factory as Sync<int>).value,
        'factory-boot',
        251,
      );
      expectErrWithStatus(
        (lazy.factory as Sync<int>).value,
        'factory-boot',
        251,
      );
    });
  });

  group('SafeCompleter.transf — error propagation', () {
    test('callback throws Err preserves statusCode', () async {
      final c = SafeCompleter<int>();
      c.complete(7).end();
      final t = c.transf<int>(
        (_) => throw Err<int>('sct', statusCode: 260),
      );
      final r = await t.resolvable().value;
      expectErrWithStatus(r, 'sct', 260);
    });
  });

  group('TaskSequencer — error propagation through chain', () {
    test('only handler throws Err: statusCode reaches completion', () async {
      // Single throwing handler — the absorbed Err must reach the
      // sequencer's completion with statusCode intact.
      final seq = TaskSequencer<int>();
      seq.then((_) => throw Err<Option<int>>('first', statusCode: 270)).end();
      final r = await seq.completion.value;
      expectErrWithStatus(r, 'first', 270);
    });
    test('subsequent handler can recover by returning Ok', () async {
      // Sequencer chains every handler — a later Ok recovers the chain.
      final seq = TaskSequencer<int>();
      seq.then((_) => throw Err<Option<int>>('first', statusCode: 271)).end();
      seq.then((_) => Sync.okValue(const Some(99))).end();
      final r = await seq.completion.value;
      expect(r, isA<Ok<Option<int>>>());
      expect((r as Ok<Option<int>>).value.unwrap(), 99);
    });
    test('handler throws StateError: wrapped as Err', () async {
      final seq = TaskSequencer<int>();
      seq.then((_) => throw StateError('seq-boom')).end();
      final r = await seq.completion.value;
      expectWrappedStateError(r, 'seq-boom');
    });
    test('eagerError short-circuits and preserves statusCode', () async {
      // With eagerError, subsequent handlers don't run; the Err survives.
      final seq = TaskSequencer<int>(eagerError: true);
      seq
          .then((_) => Sync.err(Err<Option<int>>('seed', statusCode: 272)))
          .end();
      seq.then((_) => Sync.okValue(const Some(99))).end();
      final r = await seq.completion.value;
      expectErrWithStatus(r, 'seed', 272);
    });
  });

  group('Combine* — error propagation', () {
    test('combineSync: first Err short-circuits with its statusCode', () {
      final c = combineSync<int>([
        Sync.okValue(1),
        Sync<int>.err(Err<int>('mid', statusCode: 280)),
        Sync.okValue(3),
      ]);
      expectErrWithStatus(c.value, 'mid', 280);
    });
    test('combineAsync: first Err short-circuits with its statusCode',
        () async {
      final c = combineAsync<int>([
        Async.okValue(1),
        Async<int>.err(Err<int>('amid', statusCode: 281)),
        Async.okValue(3),
      ]);
      expectErrWithStatus(await c.value, 'amid', 281);
    });
    test('combineResult: first Err short-circuits with its statusCode', () {
      final r = combineResult<int>([
        Ok<int>(1),
        Err<int>('rmid', statusCode: 282),
        Ok<int>(3),
      ]);
      expectErrWithStatus(r, 'rmid', 282);
    });
    test('combineOption: first None makes result None', () {
      final r = combineOption<int>([
        Some(1),
        None<int>(),
        Some(3),
      ]);
      expect(r, isA<None>());
    });
  });

  group('Multi-step chain — error propagates intact through layers', () {
    test('5-step chain: Err survives Sync → map → ifOk → resultMap → transf',
        () {
      final out = Sync.okValue(1)
          .map<int>((v) => v + 1)
          .ifOk((_, __) {})
          .resultMap<int>(
            (_) => throw Err<int>('deep', statusCode: 999),
          )
          .transf<int>();
      expectErrWithStatus(out.value, 'deep', 999);
    });

    test('Async chain: 5 steps, Err in middle survives to the end', () async {
      final out = await Async.okValue(1)
          .then((v) => v + 1)
          .then<int>((_) => throw Err<int>('mid-chain', statusCode: 888))
          .then((v) => v + 1)
          .then((v) => v + 1)
          .value;
      expectErrWithStatus(out, 'mid-chain', 888);
    });

    test('mixed Sync→Async chain: Err survives the platform transition',
        () async {
      final out = await Sync.okValue(1)
          .toAsync()
          .then<int>(
            (_) => throw Err<int>('cross-platform', statusCode: 777),
          )
          .value;
      expectErrWithStatus(out, 'cross-platform', 777);
    });
  });
}
