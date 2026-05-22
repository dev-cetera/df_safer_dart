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
  group('Result construction', () {
    test('Ok.new + value', () {
      const r = Ok<int>(7);
      expect(r.value, 7);
      expect(r.isOk(), isTrue);
      expect(r.isErr(), isFalse);
    });

    test('Err with all metadata', () {
      final st = StackTrace.current;
      final err = Err<int>('boom', statusCode: 500, stackTrace: st);
      expect(err.error, 'boom');
      expect(err.statusCode.unwrap(), 500);
      expect(err.stackTrace.toString(), isNotEmpty);
      expect(err.isOk(), isFalse);
      expect(err.isErr(), isTrue);
    });

    test('Err without statusCode → None', () {
      final err = Err<int>('boom');
      expect(err.statusCode, isA<None<int>>());
    });

    test('Err implements Exception', () {
      expect(Err<int>('boom'), isA<Exception>());
    });
  });

  group('Result.ifOk / ifErr', () {
    test('Ok.ifOk runs', () {
      var hit = 0;
      const Ok<int>(1).ifOk((_, __) => hit++).end();
      expect(hit, 1);
    });

    test('Ok.ifErr does not run', () {
      var hit = 0;
      const Ok<int>(1).ifErr((_, __) => hit++).end();
      expect(hit, 0);
    });

    test('Err.ifErr runs', () {
      var hit = 0;
      Err<int>('boom').ifErr((_, __) => hit++).end();
      expect(hit, 1);
    });

    test('Err.ifOk does not run', () {
      var hit = 0;
      Err<int>('boom').ifOk((_, __) => hit++).end();
      expect(hit, 0);
    });

    test('Ok.ifOk throwing becomes Err', () {
      final out = const Ok<int>(1).ifOk((_, __) => throw StateError('boom'));
      expect(out, isA<Err>());
    });

    test('Err.ifErr throwing returns Err with new error', () {
      final out = Err<int>('original').ifErr(
        (_, __) => throw StateError('new'),
      );
      expect(out, isA<Err>());
    });
  });

  group('Result.ok() / err()', () {
    test('Ok.ok yields Some', () {
      expect(const Ok<int>(1).ok(), isA<Some<Ok<int>>>());
    });

    test('Ok.err yields None', () {
      expect(const Ok<int>(1).err(), isA<None<Err<int>>>());
    });

    test('Err.err yields Some', () {
      expect(Err<int>('boom').err(), isA<Some<Err<int>>>());
    });

    test('Err.ok yields None', () {
      expect(Err<int>('boom').ok(), isA<None<Ok<int>>>());
    });
  });

  group('Result.orNull / unwrap / unwrapOr', () {
    test('Ok.orNull yields value', () {
      expect(const Ok<int>(9).orNull(), 9);
    });

    test('Err.orNull yields null', () {
      expect(Err<int>('boom').orNull(), isNull);
    });

    test('Ok.unwrap yields value', () {
      expect(const Ok<int>(9).unwrap(), 9);
    });

    test('Err.unwrap throws the Err itself', () {
      final Result<int> err = Err<int>('boom');
      expect(err.unwrap, throwsA(isA<Err>()));
    });

    test('Ok.unwrapOr returns value', () {
      expect(const Ok<int>(9).unwrapOr(0), 9);
    });

    test('Err.unwrapOr returns fallback', () {
      final Result<int> err = Err<int>('boom');
      expect(err.unwrapOr(0), 0);
    });
  });

  group('Result.map / mapOk / mapErr / flatMap', () {
    test('Ok.map applies', () {
      expect(const Ok<int>(2).map((n) => n * 10).unwrap(), 20);
    });

    test('Err.map preserves error', () {
      final out = Err<int>('boom').map((n) => n * 10);
      expect(out, isA<Err<int>>());
      expect((out as Err).error, 'boom');
    });

    test('Ok.mapOk applies', () {
      final out = const Ok<int>(1).mapOk((ok) => Ok(ok.value + 1));
      expect(out.unwrap(), 2);
    });

    test('Ok.mapErr no-ops', () {
      final out = const Ok<int>(1).mapErr((_) => Err('nope'));
      expect(out, isA<Ok>());
    });

    test('Err.mapErr replaces', () {
      final out = Err<int>('a').mapErr((_) => Err<int>('b'));
      expect((out as Err).error, 'b');
    });

    test('Ok.flatMap chains to Ok', () {
      final out = const Ok<int>(2).flatMap((v) => Ok(v + 1));
      expect(out.unwrap(), 3);
    });

    test('Ok.flatMap chains to Err', () {
      final out = const Ok<int>(2).flatMap((_) => Err<int>('boom'));
      expect(out, isA<Err<int>>());
    });

    test('Err.flatMap stays Err', () {
      final out = Err<int>('a').flatMap(Ok.new);
      expect(out, isA<Err>());
    });
  });

  group('Result.fold — abuse', () {
    test('Ok.fold calls onOk', () {
      final out = const Ok<int>(1).fold(
        (ok) => Ok(ok.value + 1),
        (_) => fail('should not call onErr'),
      );
      expect(out, isA<Ok<Object>>());
    });

    test('Ok.fold callback throw becomes Err', () {
      final out = const Ok<int>(1).fold(
        (_) => throw StateError('boom'),
        (_) => null,
      );
      expect(out, isA<Err>());
    });

    test('Err.fold calls onErr', () {
      final out = Err<int>('boom').fold(
        (_) => fail('should not call onOk'),
        (e) => const Ok<int>(99),
      );
      expect(out, isA<Ok<Object>>());
    });

    test('Err.fold callback throw becomes Err', () {
      final out = Err<int>('original').fold(
        (_) => null,
        (_) => throw StateError('new'),
      );
      expect(out, isA<Err>());
    });
  });

  group('Result.okOr / errOr', () {
    test('Ok.okOr returns self', () {
      expect(const Ok<int>(1).okOr(const Ok<int>(2)).unwrap(), 1);
    });

    test('Err.okOr returns other', () {
      expect(Err<int>('boom').okOr(const Ok<int>(99)).unwrap(), 99);
    });

    test('Ok.errOr returns other', () {
      expect(const Ok<int>(1).errOr(Err<int>('e')), isA<Err>());
    });

    test('Err.errOr returns self', () {
      expect(Err<int>('a').errOr(Err<int>('b')), isA<Err>());
    });
  });

  group('Result.transf', () {
    test('Ok.transf with mapper applies', () {
      final out = const Ok<int>(2).transf<String>((n) => 'v$n');
      expect(out.unwrap(), 'v2');
    });

    test('Ok.transf cast mismatch becomes Err', () {
      final out = const Ok<int>(2).transf<String>();
      expect(out, isA<Err>());
    });

    test('Err.transfErr preserves error + stack + statusCode', () {
      final orig = Err<int>('boom', statusCode: 404);
      final out = orig.transfErr<String>();
      expect(out, isA<Err<String>>());
      expect(out.error, 'boom');
      expect(out.statusCode.unwrap(), 404);
      expect(out.stackTrace.toString(), orig.stackTrace.toString());
    });
  });

  group('Err.matchError', () {
    test('matchError captures matching type', () {
      final err = Err<int>(const FormatException('bad'));
      expect(err.matchError<FormatException>(), isA<Some<FormatException>>());
    });

    test('matchError returns None on mismatch', () {
      final err = Err<int>(const FormatException('bad'));
      expect(err.matchError<StateError>(), isA<None>());
    });
  });

  group('Err.toModel / toJson / fromModel', () {
    test('toJson includes all populated fields', () {
      final err = Err<int>('boom', statusCode: 500);
      final json = err.toJson();
      expect(json['type'], 'Err<int>');
      expect(json['error'], 'boom');
      expect(json['statusCode'], 500);
      expect(json['stackTrace'], isA<List<String>>());
    });

    test('fromModel roundtrip', () {
      final orig = Err<int>('boom', statusCode: 404);
      final model = orig.toModel();
      final reconstructed = Err<int>.fromModel(model);
      expect(reconstructed.error, 'boom');
      expect(reconstructed.statusCode.unwrap(), 404);
    });

    test('toString is JSON', () {
      final err = Err<int>('boom');
      expect(err.toString(), contains('"error": "boom"'));
    });
  });

  group('combineResult', () {
    test('all Ok returns Ok(list)', () {
      final out = combineResult<int>([
        const Ok(1),
        const Ok(2),
        const Ok(3),
      ]);
      expect(out.unwrap(), [1, 2, 3]);
    });

    test('first Err short-circuits', () {
      final out = combineResult<int>([
        const Ok(1),
        Err<int>('mid'),
        const Ok(3),
      ]);
      expect(out, isA<Err>());
    });

    test('with onErr handler', () {
      final out = combineResult<int>(
        [const Ok<int>(1), Err<int>('mid')],
        onErr: (List<Result<int>> results) =>
            Err<List<int>>('custom error'),
      );
      expect(out, isA<Err>());
      expect((out as Err).error, 'custom error');
    });

    test('empty', () {
      expect(combineResult<int>(const []).unwrap(), <int>[]);
    });

    test('handles single-pass generator', () {
      Iterable<Result<int>> g() sync* {
        yield const Ok(1);
        yield const Ok(2);
      }

      expect(combineResult(g()).unwrap(), [1, 2]);
    });
  });

  group('Result deep / nested', () {
    test('Ok(Ok(...)) flatten via reduce', () {
      const r = Ok<Result<int>>(Ok(5));
      final flat = r.reduce<int>().sync().unwrap().value.unwrap().unwrap();
      expect(flat, 5);
    });

    test('Ok(Err(...)) reduces to Err', () {
      final r = Ok<Result<int>>(Err<int>('inner'));
      final reduced = r.reduce<int>();
      expect(reduced.sync().unwrap().value, isA<Err>());
    });
  });
}
