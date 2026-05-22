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

// Propagation matrix — every combinator on every concrete Outcome flavour,
// exercised with a callback that throws. The contract under test is:
//
//   1. The pipeline NEVER lets a throw escape (unless the caller deliberately
//      invokes a `@unsafeOrError` method like `unwrap()` outside an UNSAFE
//      block — those are exempt).
//   2. The throw becomes an `Err` whose `stackTrace` references the throwing
//      closure.
//   3. `.named(label)` correctly attributes failure to the first failing
//      step in a multi-step pipeline.

import 'package:df_safer_dart/df_safer_dart.dart';
import 'package:test/test.dart';

const _boom = 'boom';

// Typed throwers so Dart doesn't infer `Never` for the closure's return type
// (which would force the receiver's `T` to `Never` and break later `.map`s in
// the chain).
int _throwInt(int _) => throw Exception(_boom);
Result<int> _throwResultInt(int _) => throw Exception(_boom);
Option<int> _throwOptionInt(int _) => throw Exception(_boom);
bool _throwBool(int _) => throw Exception(_boom);

void main() {
  group('Result.map — throw absorption', () {
    test('Ok.map(throwing) becomes Err', () {
      final Result<int> a = const Ok<int>(1);
      final r = a.map(_throwInt);
      expect(r, isA<Err>());
      expect((r as Err).error.toString(), contains(_boom));
    });

    test('Ok.flatMap(throwing) becomes Err', () {
      final Result<int> a = const Ok<int>(1);
      final r = a.flatMap(_throwResultInt);
      expect(r, isA<Err>());
    });

    test('Ok.mapOk(throwing) becomes Err', () {
      final r = const Ok<int>(1).mapOk((_) => throw Exception(_boom));
      expect(r, isA<Err>());
    });

    test('Err.map / flatMap / mapOk — callback never runs on Err', () {
      var called = 0;
      final Result<int> e = Err<int>('upstream');
      e.map((v) {
        called++;
        return v;
      }).end();
      e.flatMap((v) {
        called++;
        return Ok(v);
      }).end();
      e.mapOk((ok) {
        called++;
        return ok;
      }).end();
      expect(called, 0);
    });

    test('Err.mapErr(non-throwing) replaces the Err', () {
      final r = Err<int>('a').mapErr((_) => Err<int>('b'));
      expect(r, isA<Err>());
      expect((r as Err).error, 'b');
    });
  });

  group('Result.fold — throw absorption (debug + release)', () {
    test('Ok.fold absorbs throw from onOk', () {
      final r = const Ok<int>(1).fold(
        (_) => throw Exception(_boom),
        (_) => null,
      );
      expect(r, isA<Err>());
    });

    test('Err.fold absorbs throw from onErr', () {
      final r = Err<int>('x').fold(
        (_) => null,
        (_) => throw Exception(_boom),
      );
      expect(r, isA<Err>());
    });
  });

  group('Result.transf — throw absorption', () {
    test('Ok.transf with throwing transformer becomes Err', () {
      final r = const Ok<int>(1).transf<String>((_) => throw Exception(_boom));
      expect(r, isA<Err>());
    });
  });

  group('Option — throws escape (documented contract)', () {
    test('Some.map(throwing) — throw escapes', () {
      expect(
        () => const Some<int>(1).map(_throwInt),
        throwsA(isA<Exception>()),
      );
    });

    test('Some.flatMap(throwing) — throw escapes', () {
      expect(
        () => const Some<int>(1).flatMap(_throwOptionInt),
        throwsA(isA<Exception>()),
      );
    });

    test('Some.filter(throwing predicate) — throw escapes', () {
      expect(
        () => const Some<int>(1).filter(_throwBool),
        throwsA(isA<Exception>()),
      );
    });

    test('Some.fold absorbs throw (return type allows Err)', () {
      final r = const Some<int>(1).fold(
        (_) => throw Exception(_boom),
        (_) => null,
      );
      expect(r, isA<Err>());
    });

    test('None ignores all callbacks — never throws', () {
      var called = 0;
      const n = None<int>();
      n.map((_) {
        called++;
        return 1;
      }).end();
      n.flatMap((_) {
        called++;
        return const None();
      }).end();
      n.filter((_) {
        called++;
        return true;
      }).end();
      expect(called, 0);
    });
  });

  group('Sync — throw absorption', () {
    test('Sync(() => throw) yields Err', () {
      final r = Sync<int>(() => throw Exception(_boom));
      expect(r.value, isA<Err>());
    });

    test('Sync.map with throwing callback yields Err', () {
      final s = Sync<int>(() => 1).map(_throwInt);
      expect(s.value, isA<Err>());
    });

    test('Sync.fold absorbs throw', () {
      final r = Sync<int>(() => 1).fold(
        (_) => throw Exception(_boom),
        (_) => null,
      );
      expect((r as Sync).value, isA<Err>());
    });
  });

  group('Async — throw absorption', () {
    test('Async(() async => throw) yields Err', () async {
      final r = await Async<int>(() async => throw Exception(_boom)).value;
      expect(r, isA<Err>());
    });

    test('Async.map with sync-throwing callback yields Err', () async {
      final r = await Async<int>(() async => 1).map(_throwInt).value;
      expect(r, isA<Err>());
    });

    test('Async.fold absorbs throw', () async {
      final out = Async<int>(() async => 1).fold(
        (_) => null,
        (_) => throw Exception(_boom),
      );
      final r = await (out as Async).value;
      expect(r, isA<Err>());
    });
  });

  group('breadcrumbs / .named(label)', () {
    test('Err carries empty breadcrumbs by default', () {
      final e = Err<int>('x');
      expect(e.breadcrumbs, isEmpty);
    });

    test('.named on Result<Err> labels with the first label', () {
      final r = Err<int>('x').named('step-a');
      expect(r, isA<Err>());
      expect((r as Err).breadcrumbs, ['step-a']);
    });

    test('.named on Result<Ok> is a no-op', () {
      final r = const Ok<int>(1).named('step-a');
      expect(r, isA<Ok>());
    });

    test('.named on already-labeled Err does NOT override', () {
      final r = Err<int>('x').named('first').named('second');
      expect((r as Err).breadcrumbs, ['first']);
    });

    test('Sync.named labels its Err', () {
      final r = Sync<int>(() => throw Exception(_boom)).named('parse');
      expect((r.value as Err).breadcrumbs, ['parse']);
    });

    test('Async.named labels its Err', () async {
      final r = await Async<int>(() async => throw Exception(_boom))
          .named('fetch')
          .value;
      expect((r as Err).breadcrumbs, ['fetch']);
    });

    test(
      'pipeline: failing middle step is named, later .named() does not override',
      () async {
        final out = await Async<int>(() async => 1)
            .named('fetch')
            .map(_throwInt)
            .named('parse')
            .map((v) => v + 1)
            .named('increment')
            .value;
        expect(out, isA<Err>());
        // The throw originated in the 'parse' step. 'fetch' succeeded so it
        // didn't label anything; 'increment' came after the failure and must
        // not override the originating label.
        expect((out as Err).breadcrumbs, ['parse']);
      },
    );

    test('transfErr through pipeline preserves breadcrumbs', () {
      final r = Err<int>('x', breadcrumbs: ['origin']).transfErr<String>();
      expect(r.breadcrumbs, ['origin']);
    });

    test('toJson includes breadcrumbs only when non-empty', () {
      final empty = Err<int>('x').toJson();
      expect(empty.containsKey('breadcrumbs'), isFalse);

      final labeled = Err<int>('x', breadcrumbs: ['step']).toJson();
      expect(labeled['breadcrumbs'], ['step']);
    });
  });

  group('Pipeline short-circuit / no escape', () {
    test('Sync pipeline: throwing step short-circuits, no escape', () {
      var stepReached = 0;

      final r = Sync<int>(() => 1)
          .map<int>((v) {
            stepReached = 1;
            return v + 1;
          })
          .map<int>((v) {
            stepReached = 2;
            throw Exception(_boom);
          })
          .map<int>((v) {
            stepReached = 3; // must NOT run after error
            return v + 1;
          });

      expect(r.value, isA<Err>());
      expect(stepReached, 2, reason: 'pipeline must short-circuit on Err');
    });

    test('Async pipeline: throwing step does not crash awaiter', () async {
      final r = await Async<int>(() async => 1)
          .map(_throwInt)
          .map((v) => v + 1)
          .value;
      expect(r, isA<Err>());
    });
  });
}
