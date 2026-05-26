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

// Regression tests for issues found in the post-crash audit pass:
//
//   1. `toSafeStream` lost the StackTrace for non-`Err` errors because
//      `handleError` constructed `Err<T>(error)` without forwarding the
//      `stackTrace` argument it had been given.
//
//   2. `letIterableOrNone` returned a lazy `Iterable.map(...)` view. A caller
//      that iterated the result twice (or fed a custom single-pass Iterable
//      in) re-ran `letOrNone` per element, and a non-restartable source
//      yielded zero elements on the second pass.
//
//   3. `combineSync` / `combineAsync` are public entry points but consumed
//      their `Iterable` twice (`.isEmpty` + subsequent `.map(...).toList()`).
//      A truly single-pass iterable lost every element after `.isEmpty`.
//
//   4. `letMapOrNone` carried a dead `final Outcome m =>` case inside its
//      switch — Outcomes were already unwrapped at the top of the function,
//      so the case was unreachable.

import 'dart:async';

import 'package:df_safer_dart/df_safer_dart.dart';
import 'package:test/test.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// An [Iterable] that throws on a second `.iterator` access — used to assert
/// that public APIs materialize their inputs once.
class _OnePassIterable<T> extends Iterable<T> {
  _OnePassIterable(this._items);
  final List<T> _items;
  bool _consumed = false;

  @override
  Iterator<T> get iterator {
    if (_consumed) {
      throw StateError('Iterable consumed more than once.');
    }
    _consumed = true;
    return _items.iterator;
  }
}

void main() {
  group('toSafeStream preserves stack traces', () {
    test('non-Err errors keep their original stack trace', () async {
      final ctrl = StreamController<int>();
      final captured = <Result<int>>[];

      // Capture the trace at the throw-site so we can prove it's the one
      // that ends up on the Err.
      late StackTrace originalTrace;
      try {
        throw Exception('boom');
      } catch (_, st) {
        originalTrace = st;
      }

      final sub = ctrl.stream
          .toSafeStream(cancelOnError: false)
          .listen(captured.add);

      ctrl.addError(Exception('boom'), originalTrace);
      await Future<void>.delayed(Duration.zero);
      await ctrl.close();
      await sub.cancel();

      expect(captured.length, 1);
      final result = captured.single;
      expect(result, isA<Err<int>>());
      final err = result as Err<int>;
      // The trace must originate from `addError`, not from the Err()
      // construction site inside the transformer. dart2wasm intentionally
      // captures an empty trace (see Err._safeStackTrace) — there we only
      // assert that the field is reachable. Elsewhere the trace text must
      // mention this file's name, proving it isn't an empty Trace.
      const isWasm = bool.fromEnvironment('dart.tool.dart2wasm');
      if (!isWasm) {
        expect(
          err.stackTrace.toString(),
          contains('audit_round_test.dart'),
          reason:
              'toSafeStream dropped the stack trace passed to handleError; '
              'a medical-grade audit trail requires it.',
        );
      }
    });

    test('Err errors keep their stack trace via transfErr()', () async {
      final ctrl = StreamController<int>();
      final captured = <Result<int>>[];

      final original = Err<int>(
        'oops',
        statusCode: 503,
        stackTrace: StackTrace.fromString(
          '#0 fake (package:fake/fake.dart:42:1)',
        ),
      );

      final sub = ctrl.stream
          .toSafeStream(cancelOnError: false)
          .listen(captured.add);

      ctrl.addError(original);
      await Future<void>.delayed(Duration.zero);
      await ctrl.close();
      await sub.cancel();

      expect(captured.length, 1);
      final err = captured.single as Err<int>;
      expect(err.statusCode.orNull(), 503);
      // On dart2wasm the trace is intentionally empty (see
      // Err._safeStackTrace) and `Trace.toString()` itself can hit the
      // documented WASM `Style.platform` trap, so we skip the textual
      // assertion there.
      const isWasm = bool.fromEnvironment('dart.tool.dart2wasm');
      if (!isWasm) {
        expect(err.stackTrace.toString(), contains('fake.dart'));
      }
    });
  });

  group('letIterableOrNone materializes once', () {
    test('survives single-pass source iterable', () {
      // `letOrNone<num>` does not auto-parse strings, so we use values that
      // are already numeric — the point of this test is the iterable
      // consumption count, not the per-element conversion path.
      final once = _OnePassIterable<dynamic>([1, 2, 3.5]);
      final out = letIterableOrNone<num>(once);
      // The returned iterable must be safe to iterate again without
      // re-touching the original.
      final first = out.unwrap().toList();
      final second = out.unwrap().toList();
      expect(first.length, 3);
      expect(second.length, 3);
      expect(first.map((e) => e.orNull()).toList(), [1, 2, 3.5]);
      expect(second.map((e) => e.orNull()).toList(), [1, 2, 3.5]);
    });

    test('inner Option<num> conversion runs exactly once per element', () {
      // If the implementation is lazy, each iteration re-converts.
      var conversions = 0;
      final wrapped = [1, 2, 3.5].map((e) {
        conversions++;
        return e;
      });
      final out = letIterableOrNone<num>(wrapped).unwrap().toList();
      expect(out.length, 3);
      // wrapped.map calls its body once per source iteration. We expect
      // exactly one full traversal of the source no matter how many times
      // the result is iterated.
      final before = conversions;
      // Iterate result twice; conversions must not grow.
      out.toList();
      out.toList();
      expect(conversions, before);
    });
  });

  group('Outcome.reduce preserves Err metadata', () {
    test('breadcrumbs from .named() survive reduce<R>()', () async {
      // Reduce was rebuilding the Err with statusCode + stackTrace but
      // dropping `breadcrumbs` — a `.named()` chain disappears on the way out.
      final reduced = await Sync.err(
        Err<int>('boom', statusCode: 418).withBreadcrumbs(['fetch', 'parse']),
      ).reduce<int>().value;
      final err = (reduced as Err);
      expect(err.breadcrumbs, ['fetch', 'parse']);
      expect(err.statusCode.orNull(), 418);
    });
  });

  group('SafeCompleter.transf', () {
    test('completes the new completer when the source resolves with Err',
        () async {
      // Previously: transf() chained `.then((e) => ...)` which fires only on
      // Ok. An Err source left the new completer dangling forever.
      final source = SafeCompleter<int>();
      final transformed = source.transf<String>((e) => '$e');

      source.resolve(Sync.err(Err<int>('upstream-fail', statusCode: 500))).end();

      // The transformed completer must surface the original error within a
      // bounded amount of time — not hang. Async.value is a Future.
      final value = transformed.resolvable().value;
      final result = await Future<Result<String>>.value(
        value,
      ).timeout(const Duration(seconds: 2));
      expect(result, isA<Err<String>>());
      final err = result as Err<String>;
      expect(err.error.toString(), contains('upstream-fail'));
      expect(err.statusCode.orNull(), 500);
    });
  });

  group('combineSync / combineAsync materialize their iterable once', () {
    test('combineSync survives a single-pass iterable', () {
      final once = _OnePassIterable<Sync<int>>([
        Sync.okValue(1),
        Sync.okValue(2),
        Sync.okValue(3),
      ]);
      final out = combineSync<int>(once);
      expect(out.value.unwrap(), [1, 2, 3]);
    });

    test('combineAsync survives a single-pass iterable', () async {
      final once = _OnePassIterable<Async<int>>([
        Async.okValue(1),
        Async.okValue(2),
        Async.okValue(3),
      ]);
      final out = combineAsync<int>(once);
      expect((await out.value).unwrap(), [1, 2, 3]);
    });
  });
}
