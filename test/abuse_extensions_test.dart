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

import 'package:df_safer_dart/df_safer_dart.dart';
import 'package:test/test.dart';

void main() {
  group('letOrNone — type dispatch', () {
    test('null → None', () {
      expect(letOrNone<int>(null), isA<None>());
    });

    test('matching type → Some', () {
      expect(letOrNone<int>(42).unwrap(), 42);
    });

    test('string → int conversion', () {
      expect(letOrNone<int>('42').unwrap(), 42);
    });

    test('string → double conversion', () {
      expect(letOrNone<double>('3.14').unwrap(), 3.14);
    });

    test('string → bool conversion', () {
      expect(letOrNone<bool>('true').unwrap(), isTrue);
      expect(letOrNone<bool>('false').unwrap(), isFalse);
      expect(letOrNone<bool>('maybe'), isA<None>());
    });

    test('string → DateTime', () {
      final out = letOrNone<DateTime>('2024-01-15');
      expect(out.unwrap().year, 2024);
    });

    test('string → Uri', () {
      final out = letOrNone<Uri>('https://example.com/path');
      expect(out.unwrap().host, 'example.com');
    });

    test('Outcome chain — Ok unwraps', () {
      expect(letOrNone<int>(const Ok<int>(42)).unwrap(), 42);
    });

    test('Outcome chain — Err → None', () {
      expect(letOrNone<int>(Err<int>('boom')), isA<None>());
    });

    test('Outcome chain — Some unwraps', () {
      expect(letOrNone<int>(const Some<int>(42)).unwrap(), 42);
    });

    test('Outcome chain — None → None', () {
      expect(letOrNone<int>(const None<int>()), isA<None>());
    });

    test('unparseable string → None', () {
      expect(letOrNone<int>('not a number'), isA<None>());
    });
  });

  group('letIntOrNone — edge cases', () {
    test('int passthrough', () {
      expect(letIntOrNone(7).unwrap(), 7);
    });

    test('int max safe', () {
      expect(letIntOrNone(0x7FFFFFFFFFFFFFFF).unwrap(), 0x7FFFFFFFFFFFFFFF);
    });

    test('double with fractional truncates', () {
      expect(letIntOrNone(3.7).unwrap(), 3);
    });

    test('string with int', () {
      expect(letIntOrNone('42').unwrap(), 42);
    });

    test('string with whitespace trimmed', () {
      expect(letIntOrNone('  42  ').unwrap(), 42);
    });

    test('string with sign', () {
      expect(letIntOrNone('-42').unwrap(), -42);
    });

    test('non-numeric string → None', () {
      expect(letIntOrNone('abc'), isA<None>());
    });

    test('empty string → None', () {
      expect(letIntOrNone(''), isA<None>());
    });

    test('bool input → None', () {
      expect(letIntOrNone(true), isA<None>());
    });

    test('null → None', () {
      expect(letIntOrNone(null), isA<None>());
    });
  });

  group('letDoubleOrNone', () {
    test('int → double', () {
      expect(letDoubleOrNone(42).unwrap(), 42.0);
    });

    test('infinity passes', () {
      expect(letDoubleOrNone(double.infinity).unwrap(), double.infinity);
    });

    test('NaN passes (double itself)', () {
      expect(letDoubleOrNone(double.nan).unwrap().isNaN, isTrue);
    });

    test('string scientific', () {
      expect(letDoubleOrNone('1.5e3').unwrap(), 1500.0);
    });
  });

  group('letBoolOrNone', () {
    test('true → Some(true)', () {
      expect(letBoolOrNone(true).unwrap(), isTrue);
    });

    test('"true" → Some(true)', () {
      expect(letBoolOrNone('true').unwrap(), isTrue);
    });

    test('"TRUE" → Some(true) (case-insensitive)', () {
      expect(letBoolOrNone('TRUE').unwrap(), isTrue);
    });

    test('"false" → Some(false)', () {
      expect(letBoolOrNone('false').unwrap(), isFalse);
    });

    test('"yes" → None (only true/false accepted)', () {
      expect(letBoolOrNone('yes'), isA<None>());
    });

    test('1 → None (numbers not boolean)', () {
      expect(letBoolOrNone(1), isA<None>());
    });
  });

  group('letUriOrNone', () {
    test('valid http', () {
      expect(letUriOrNone('https://x.com').unwrap().scheme, 'https');
    });

    test('relative path', () {
      expect(letUriOrNone('/a/b').unwrap().path, '/a/b');
    });

    test('Uri passthrough', () {
      final u = Uri.parse('https://x.com');
      expect(letUriOrNone(u).unwrap(), u);
    });
  });

  group('letDateTimeOrNone', () {
    test('ISO string', () {
      final out = letDateTimeOrNone('2024-01-15T10:00:00Z');
      expect(out.unwrap().year, 2024);
    });

    test('invalid format → None', () {
      expect(letDateTimeOrNone('not a date'), isA<None>());
    });

    test('DateTime passthrough', () {
      final dt = DateTime(2024, 1, 15);
      expect(letDateTimeOrNone(dt).unwrap(), dt);
    });
  });

  group('letAsStringOrNone', () {
    test('any object → toString', () {
      expect(letAsStringOrNone(42).unwrap(), '42');
    });

    test('null → None', () {
      expect(letAsStringOrNone(null), isA<None>());
    });

    test('Ok(value) → toString of value', () {
      expect(letAsStringOrNone(const Ok<int>(42)).unwrap(), '42');
    });
  });

  group('jsonDecodeOrNone', () {
    test('valid JSON object', () {
      final out = jsonDecodeOrNone<Map<String, dynamic>>('{"a":1}');
      expect(out.unwrap()['a'], 1);
    });

    test('invalid JSON → None', () {
      expect(jsonDecodeOrNone<Map<String, dynamic>>('not json'), isA<None>());
    });

    test('type mismatch → None', () {
      expect(jsonDecodeOrNone<List<dynamic>>('{"a":1}'), isA<None>());
    });
  });

  group('IterableExt', () {
    test('firstOrNone on empty', () {
      expect(<int>[].firstOrNone, isA<None>());
    });

    test('firstOrNone on populated', () {
      expect([1, 2, 3].firstOrNone.unwrap(), 1);
    });

    test('lastOrNone on empty', () {
      expect(<int>[].lastOrNone, isA<None>());
    });

    test('lastOrNone on populated', () {
      expect([1, 2, 3].lastOrNone.unwrap(), 3);
    });

    test('singleOrNone on empty', () {
      expect(<int>[].singleOrNone, isA<None>());
    });

    test('singleOrNone on single', () {
      expect([7].singleOrNone.unwrap(), 7);
    });

    test('singleOrNone on multiple → None', () {
      expect([1, 2].singleOrNone, isA<None>());
    });

    test('firstWhereOrNone match', () {
      expect([1, 2, 3].firstWhereOrNone((e) => e > 1).unwrap(), 2);
    });

    test('firstWhereOrNone no match', () {
      expect([1, 2, 3].firstWhereOrNone((e) => e > 9), isA<None>());
    });

    test('elementAtOrNone valid', () {
      expect([10, 20, 30].elementAtOrNone(1).unwrap(), 20);
    });

    test('elementAtOrNone out of bounds → None', () {
      expect([10, 20, 30].elementAtOrNone(99), isA<None>());
    });

    test('elementAtOrNone negative index → None', () {
      expect([10, 20, 30].elementAtOrNone(-1), isA<None>());
    });

    test('noneIfEmpty empty', () {
      expect(<int>[].noneIfEmpty, isA<None>());
    });

    test('noneIfEmpty populated', () {
      expect([1].noneIfEmpty.unwrap(), [1]);
    });
  });

  group('StringExt', () {
    test('firstOrNone on empty', () {
      expect(''.firstOrNone, isA<None>());
    });

    test('firstOrNone on populated', () {
      expect('hello'.firstOrNone.unwrap(), 'h');
    });

    test('lastOrNone on populated', () {
      expect('hello'.lastOrNone.unwrap(), 'o');
    });

    test('elementAtOrNone in bounds', () {
      expect('abc'.elementAtOrNone(1).unwrap(), 'b');
    });

    test('elementAtOrNone out of bounds', () {
      expect('abc'.elementAtOrNone(99), isA<None>());
    });

    test('noneIfEmpty', () {
      expect(''.noneIfEmpty, isA<None>());
      expect('x'.noneIfEmpty.unwrap(), 'x');
    });
  });

  group('Outcome.reduce — combinations', () {
    test('Some(int) reduces to Sync<Option<int>>', () {
      final out = const Some<int>(5).reduce<int>();
      expect(out, isA<Sync>());
      expect(out.sync().unwrap().value.unwrap().unwrap(), 5);
    });

    test('None reduces to Sync<Option<int>>(Ok(None))', () {
      final out = const None<int>().reduce<int>();
      final inner = out.sync().unwrap().value.unwrap();
      expect(inner, isA<None>());
    });

    test('Err reduces to Sync<Option<int>>(Err)', () {
      final out = Err<int>('boom').reduce<int>();
      expect(out.sync().unwrap().value, isA<Err>());
    });

    test('Ok(Some(42)) reduces to Some(42)', () {
      final out = const Ok<Some<int>>(Some(42)).reduce<int>();
      expect(out.sync().unwrap().value.unwrap().unwrap(), 42);
    });

    test('Some(Ok(42)) reduces to Some(42)', () {
      final out = const Some<Ok<int>>(Ok(42)).reduce<int>();
      expect(out.sync().unwrap().value.unwrap().unwrap(), 42);
    });

    test('Async(Ok(1)) reduces (async)', () async {
      final a = Async.okValue(1);
      final out = a.reduce<int>();
      expect(out, isA<Async>());
      final r = (await out.value).unwrap();
      expect(r.unwrap(), 1);
    });

    test('Some(Some(Some(42))) reduces to 42', () {
      const triple = Some<Some<Some<int>>>(Some(Some(42)));
      final out = triple.reduce<int>();
      expect(out.sync().unwrap().value.unwrap().unwrap(), 42);
    });

    test('Ok(Ok(Ok(42))) reduces to 42', () {
      const triple = Ok<Ok<Ok<int>>>(Ok(Ok(42)));
      final out = triple.reduce<int>();
      expect(out.sync().unwrap().value.unwrap().unwrap(), 42);
    });

    test('Mix: Ok(Some(Ok(42))) reduces to 42', () {
      const mix = Ok<Some<Ok<int>>>(Some(Ok(42)));
      final out = mix.reduce<int>();
      expect(out.sync().unwrap().value.unwrap().unwrap(), 42);
    });

    test('Mix with None: Ok(Some(None<int>())) reduces to None', () {
      const mix = Ok<Some<None<int>>>(Some(None()));
      final out = mix.reduce<int>();
      final inner = out.sync().unwrap().value.unwrap();
      expect(inner, isA<None>());
    });

    test('Mix with Err: Ok(Some(Err<int>("boom"))) reduces to Err', () {
      final mix = Ok<Some<Err<int>>>(Some(Err<int>('boom')));
      final out = mix.reduce<int>();
      expect(out.sync().unwrap().value, isA<Err>());
    });
  });

  group('Outcome.raw / rawSync / rawAsync', () {
    test('rawSync on simple Some returns Sync(Ok(value))', () {
      final out = const Some<int>(5).rawSync();
      expect(out.value, isA<Ok>());
    });

    test('rawSync on None returns Sync(Err)', () {
      final out = const None<int>().rawSync();
      expect(out.value, isA<Err>());
    });

    test('rawSync on Err returns Sync(Err)', () {
      final out = Err<int>('boom').rawSync();
      expect(out.value, isA<Err>());
    });

    test('rawSync on Async returns Sync(Err) — not allowed', () {
      final out = Async.okValue(1).rawSync();
      expect(out.value, isA<Err>());
    });

    test('rawAsync on Some resolves', () async {
      final out = const Some<int>(5).rawAsync();
      final r = await out.value;
      expect(r.unwrap(), 5);
    });

    test('rawAsync on Async resolves', () async {
      final out = Async.okValue(7).rawAsync();
      final r = await out.value;
      expect(r.unwrap(), 7);
    });
  });

  group('Outcome.unwrapOr', () {
    test('Some.unwrapOr returns value', () {
      expect(const Some<int>(5).unwrapOr(0), 5);
    });

    test('None.unwrapOr returns fallback', () {
      final Option<int> n = const None();
      expect(n.unwrapOr(99), 99);
    });

    test('Ok.unwrapOr returns value', () {
      expect(const Ok<int>(5).unwrapOr(0), 5);
    });
  });

  group('Unit', () {
    test('Unit() is a value', () {
      expect(Unit(), isNotNull);
    });

    test('UNIT constant exists', () {
      expect(UNIT, isA<Unit>());
    });

    test('OK_UNIT, SOME_UNIT, NONE_UNIT constants', () {
      expect(OK_UNIT, isA<Ok<Unit>>());
      expect(SOME_UNIT, isA<Some<Unit>>());
      expect(NONE_UNIT, isA<None<Unit>>());
    });

    test('syncUnit / asyncUnit / resolvableUnit shortcuts', () async {
      expect(syncUnit().value, isA<Ok<Unit>>());
      expect((await asyncUnit().value), isA<Ok<Unit>>());
      expect(resolvableUnit(), isA<Resolvable<Unit>>());
    });

    test('syncNone / syncSome / asyncNone / asyncSome', () async {
      expect(syncNone<int>().value, isA<Ok<None<int>>>());
      expect(syncSome(5).value.unwrap().value, 5);
      expect((await asyncNone<int>().value), isA<Ok<None<int>>>());
      expect((await asyncSome(5).value).unwrap().value, 5);
    });
  });

  group('Combined / nested abuse scenarios', () {
    test('100-deep Some chain reduces in linear time', () {
      Outcome<Object> chain = const Some(42);
      for (var i = 0; i < 1000; i++) {
        chain = Some(chain);
      }
      final out = chain.reduce<int>();
      expect(out.sync().unwrap().value.unwrap().unwrap(), 42);
    });

    test('Async chain: Async(Some(Some(42)))', () async {
      final a = Async<Some<Some<int>>>(
        () async => const Some(Some(42)),
      );
      final out = a.reduce<int>();
      final r = (await out.value).unwrap();
      expect(r.unwrap(), 42);
    });

    test('combineResolvable mix of sync errors', () async {
      final out = combineResolvable<int>([
        Sync.okValue(1),
        Sync<int>.errValue('mid'),
        Sync.okValue(3),
      ]);
      final r = await out.value;
      expect(r, isA<Err>());
    });

    test('combineResolvable with onErr handler aggregates', () async {
      final out = combineResolvable<int>(
        [Sync.okValue(1), Sync<int>.errValue('mid')],
        onErr: (results) => Err<List<int>>(
          'aggregate of ${results.length} entries',
        ),
      );
      final r = await out.value;
      expect(r, isA<Err>());
      expect((r as Err).error, contains('aggregate of'));
    });
  });

  group('UNSAFE marker', () {
    test('UNSAFE returns block value when no throw', () {
      expect(UNSAFE(() => 42), 42);
    });

    test('UNSAFE rethrows (documented behavior)', () {
      expect(
        () => UNSAFE<int>(() => throw StateError('boom')),
        throwsA(isA<StateError>()),
      );
    });
  });
}
