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

// Regression tests for three medical-grade defects:
//
//   A. `implements Equatable` instead of `extends Equatable` meant
//      Some(42) == Some(42) was `false` for non-const instances.
//   B. `letIntOrNone` on dart2js let `double.infinity` and out-of-range
//      doubles through because `is int` is true for any integer-valued
//      JS-Number.
//   C. `Err.toString()` from inside an async function crashed on dart2wasm
//      because `stack_trace`'s frame parser could not handle the WASM-native
//      stack format.

// Tests intentionally use non-`const` Some/Ok/None/Err instances — that's the
// exact shape that exposed defect A, so we keep them non-const.
// ignore_for_file: prefer_const_constructors, unrelated_type_equality_checks

import 'package:df_safer_dart/df_safer_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Defect A: Outcome value equality', () {
    test('Some(n) == Some(n) for non-const instances', () {
      expect(Some(42) == Some(42), isTrue);
      expect(Some('x') == Some('x'), isTrue);
    });

    test('Some(a) != Some(b) when values differ', () {
      expect(Some(1) == Some(2), isFalse);
    });

    test('None<T>() == None<T>() for non-const instances', () {
      expect(None<int>() == None<int>(), isTrue);
    });

    test('Ok(n) == Ok(n)', () {
      expect(Ok(42) == Ok(42), isTrue);
    });

    test('Err(s) == Err(s) for same error string', () {
      expect(Err<int>('boom') == Err<int>('boom'), isTrue);
    });

    test('different runtimeTypes never compare equal', () {
      // Some(42) vs Ok(42): both wrap 42 but are different sealed-tree
      // members. Equatable's runtimeType guard keeps them apart.
      expect(Some(42) == Ok(42), isFalse);
    });

    test('hashCode is value-based, not identity-based', () {
      expect(Some(42).hashCode == Some(42).hashCode, isTrue);
      expect(Ok('x').hashCode == Ok('x').hashCode, isTrue);
    });

    test('equal Outcomes are interchangeable in collections', () {
      // Verifies that the hashCode contract is honoured by hash-based
      // collections, which is what most real callers rely on.
      final set = <Outcome<int>>{Some(1), Some(2), Some(3)};
      expect(set.contains(Some(2)), isTrue);
      expect(set.contains(Some(99)), isFalse);
    });
  });

  group('Defect B: letIntOrNone rejects malformed numerics on every platform',
      () {
    test('double.infinity → None', () {
      expect(letIntOrNone(double.infinity), isA<None<int>>());
    });

    test('double.negativeInfinity → None', () {
      expect(letIntOrNone(double.negativeInfinity), isA<None<int>>());
    });

    test('double.nan → None', () {
      expect(letIntOrNone(double.nan), isA<None<int>>());
    });

    test('1e30 (beyond int64.max) → None', () {
      expect(letIntOrNone(1e30), isA<None<int>>());
    });

    test('-1e30 (beyond int64.min) → None', () {
      expect(letIntOrNone(-1e30), isA<None<int>>());
    });

    // The int64 boundary literals `0x7FFFFFFFFFFFFFFF` / `-0x8000000000000000`
    // can't be represented in JS-Numbers and dart2js refuses to compile them.
    // Those VM/WASM-specific bound tests live in
    // `test/int64_boundary_vm_test.dart`, which is gated with `@TestOn('vm')`
    // so the literals never reach dart2js.

    test('plain finite doubles continue to convert', () {
      expect(letIntOrNone(42.0).unwrap(), 42);
      expect(letIntOrNone(3.7).unwrap(), 3);
      expect(letIntOrNone('42').unwrap(), 42);
    });
  });

  group('Defect C: Err.toString never crashes', () {
    test('Err.toString in async context returns a usable string', () async {
      final a = Async<int>(() async => throw StateError('async-boom'));
      final v = await a.value;
      expect(v, isA<Err<int>>());
      // The actual crash on WASM happens here: stringification must succeed.
      final s = v.toString();
      expect(s, isNotEmpty);
      expect(s, contains('Err'));
      expect(s, contains('async-boom'));
    });

    test('Err.toString with a synthetic empty StackTrace returns a string', () {
      final e = Err<int>('x', stackTrace: StackTrace.empty);
      final s = e.toString();
      expect(s, contains('Err'));
      expect(s, contains('x'));
    });

    test('toJson produces a Map even when stack frames are empty', () {
      final e = Err<int>('x', stackTrace: StackTrace.empty);
      final json = e.toJson();
      expect(json['type'], 'Err<int>');
      expect(json['error'], contains('x'));
      expect(json['stackTrace'], isA<List<String>>());
    });
  });
}
