import 'package:df_safer_dart/df_safer_dart.dart';
import 'package:test/test.dart';

void main() {
  group('_err', () {
    test('constructor — minimal Err captures value and default fields', () {
      final err = Err<int>('boom');
      expect(err.error, 'boom');
      expect(err.statusCode, isA<None<int>>());
      expect(err.breadcrumbs, isEmpty);
      // stackTrace.toString() must not throw, even if frames are empty.
      expect(err.stackTrace.toString(), isA<String>());
    });

    test('constructor — statusCode is wrapped in Some', () {
      final err = Err<int>('boom', statusCode: 404);
      expect(err.statusCode, isA<Some<int>>());
      expect(err.statusCode.unwrap(), 404);
    });

    test('constructor — captures provided stackTrace', () {
      final st = StackTrace.current;
      final err = Err<int>('boom', stackTrace: st);
      // We must be able to read the trace as a string without throwing.
      expect(err.stackTrace.toString(), isA<String>());
    });

    test('constructor — captures current stackTrace when none provided', () {
      final err = Err<int>('boom');
      expect(err.stackTrace.toString(), isA<String>());
    });

    test('constructor — breadcrumbs are stored unmodifiable', () {
      final err = Err<int>('boom', breadcrumbs: ['a', 'b']);
      expect(err.breadcrumbs, ['a', 'b']);
      expect(
        () => err.breadcrumbs.add('c'),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('constructor — empty breadcrumbs default to const []', () {
      final err = Err<int>('boom');
      expect(err.breadcrumbs, isEmpty);
    });

    test('error getter returns the underlying error object', () {
      final err = Err<int>('boom');
      expect(err.error, 'boom');
    });

    test('Err.fromModel — reconstructs error / statusCode / stackTrace', () {
      const model = ErrModel(
        type: 'Err<int>',
        error: 'remote-boom',
        statusCode: 503,
        stackTrace: ['frame1', 'frame2'],
      );
      final err = Err<int>.fromModel(model);
      expect(err.error, 'remote-boom');
      expect(err.statusCode.unwrap(), 503);
    });

    test('Err.fromModel — null error falls back to "Error"', () {
      const model = ErrModel(type: 'Err<int>', error: null);
      final err = Err<int>.fromModel(model);
      expect(err.error, 'Error');
    });

    test('isOk returns false', () {
      expect(Err<int>('x').isOk(), isFalse);
    });

    test('isErr returns true', () {
      expect(Err<int>('x').isErr(), isTrue);
    });

    test('ifOk does NOT invoke callback and returns this', () {
      final err = Err<int>('x');
      var called = false;
      final r = err.ifOk((_, __) => called = true);
      expect(called, isFalse);
      expect(identical(r, err), isTrue);
    });

    test('ifErr invokes callback with self and self', () {
      final err = Err<int>('x');
      Err<int>? capturedSelf;
      Err<int>? capturedErr;
      err.ifErr((self, e) {
        capturedSelf = self;
        capturedErr = e;
      });
      expect(identical(capturedSelf, err), isTrue);
      expect(identical(capturedErr, err), isTrue);
    });

    test('err() returns Some(self)', () {
      final err = Err<int>('x');
      final some = err.err();
      expect(some, isA<Some<Err<int>>>());
      expect(identical(some.unwrap(), err), isTrue);
    });

    test('ok() returns None', () {
      expect(Err<int>('x').ok(), isA<None<Ok<int>>>());
    });

    test('orNull returns null', () {
      expect(Err<int>('x').orNull(), isNull);
    });

    test('flatMap returns transferred Err — never invokes callback', () {
      final err = Err<int>('x', statusCode: 500);
      var called = false;
      final r = err.flatMap<String>((_) {
        called = true;
        return const Ok('never');
      });
      expect(called, isFalse);
      expect(r.isErr(), isTrue);
      expect(r.err().unwrap().statusCode.unwrap(), 500);
    });

    test('mapOk returns this unchanged', () {
      final err = Err<int>('x');
      var called = false;
      final r = err.mapOk((_) {
        called = true;
        return const Ok(0);
      });
      expect(called, isFalse);
      expect(identical(r, err), isTrue);
    });

    test('mapErr — Err callback transforms', () {
      final err = Err<int>('x');
      final r = err.mapErr((_) => Err<int>('replaced'));
      expect(r.err().unwrap().error, 'replaced');
    });

    test('mapErr — thrown Err preserved verbatim', () {
      final err = Err<int>('x');
      final thrown = Err<int>('thrown', statusCode: 418);
      final r = err.mapErr((_) => throw thrown);
      expect(r.err().unwrap().statusCode.unwrap(), 418);
    });

    test('mapErr — generic throw absorbed into Err', () {
      final err = Err<int>('x');
      final r = err.mapErr((_) => throw StateError('boom'));
      expect(r.isErr(), isTrue);
    });

    test('fold — invokes onErr branch', () {
      final err = Err<int>('x');
      final r = err.fold((_) => null, (_) => const Ok<int>(999));
      expect(r.unwrap(), 999);
    });

    test('fold — onErr returning null falls back to this', () {
      final err = Err<int>('x');
      final r = err.fold((_) => null, (_) => null);
      expect(identical(r, err), isTrue);
    });

    test('fold — thrown Err preserved verbatim', () {
      final err = Err<int>('x');
      final thrown = Err<int>('thrown', statusCode: 422);
      final r = err.fold((_) => null, (_) => throw thrown);
      expect(r.err().unwrap().statusCode.unwrap(), 422);
    });

    test('fold — generic throw absorbed into Err', () {
      final err = Err<int>('x');
      final r = err.fold((_) => null, (_) => throw StateError('boom'));
      expect(r.isErr(), isTrue);
    });

    test('okOr — Err returns other', () {
      final err = Err<int>('x');
      const other = Ok<int>(42);
      expect(identical(err.okOr(other), other), isTrue);
    });

    test('errOr — Err returns this', () {
      final err = Err<int>('x');
      const other = Ok<int>(42);
      expect(identical(err.errOr(other), err), isTrue);
    });

    test('matchError — Some when error matches type', () {
      final err = Err<int>(const FormatException('bad'));
      final matched = err.matchError<FormatException>();
      expect(matched, isA<Some<FormatException>>());
      expect(matched.unwrap().message, 'bad');
    });

    test('matchError — None when error does not match type', () {
      final err = Err<int>('string-error');
      expect(err.matchError<FormatException>(), isA<None<FormatException>>());
    });

    test(
        'transfErr — preserves error, stackTrace, statusCode and breadcrumbs',
        () {
      final st = StackTrace.current;
      final err = Err<int>(
        'boom',
        statusCode: 502,
        stackTrace: st,
        breadcrumbs: ['fetch', 'parse'],
      );
      final transferred = err.transfErr<String>();
      expect(transferred, isA<Err<String>>());
      expect(transferred.error, 'boom');
      expect(transferred.statusCode.unwrap(), 502);
      expect(transferred.breadcrumbs, ['fetch', 'parse']);
      // The transferred stack trace must remain readable.
      expect(transferred.stackTrace.toString(), isA<String>());
    });

    test('withBreadcrumbs replaces breadcrumbs, keeps other fields', () {
      final err = Err<int>(
        'boom',
        statusCode: 503,
        breadcrumbs: ['old'],
      );
      final updated = err.withBreadcrumbs(['new1', 'new2']);
      expect(updated.error, 'boom');
      expect(updated.statusCode.unwrap(), 503);
      expect(updated.breadcrumbs, ['new1', 'new2']);
    });

    test('toModel — emits ErrModel with type, error, statusCode', () {
      final err = Err<int>('boom', statusCode: 503);
      final model = err.toModel();
      expect(model.type, 'Err<int>');
      expect(model.error, 'boom');
      expect(model.statusCode, 503);
      // stackTrace can be null/empty depending on host but must not throw.
      expect(model.stackTrace, anyOf(isNull, isA<List<String>>()));
    });

    test('toJson — includes core fields, omits empty breadcrumbs', () {
      final err = Err<int>('boom', statusCode: 503);
      final json = err.toJson();
      expect(json['type'], 'Err<int>');
      expect(json['error'], 'boom');
      expect(json['statusCode'], 503);
      expect(json.containsKey('breadcrumbs'), isFalse);
    });

    test('toJson — includes breadcrumbs when non-empty', () {
      final err = Err<int>('boom', breadcrumbs: ['a', 'b']);
      final json = err.toJson();
      expect(json['breadcrumbs'], ['a', 'b']);
    });

    test('unwrap — throws this very Err', () {
      final err = Err<int>('boom');
      final Result<int> r = err;
      Object? thrown;
      try {
        r.unwrap();
      } catch (e) {
        thrown = e;
      }
      expect(identical(thrown, err), isTrue);
    });

    test('unwrapOr returns fallback', () {
      final Result<int> r = Err<int>('x');
      expect(r.unwrapOr(42), 42);
    });

    test('map — returns transferred Err, never invokes callback', () {
      final err = Err<int>('x', statusCode: 500);
      var called = false;
      final r = err.map<String>((_) {
        called = true;
        return 'nope';
      });
      expect(called, isFalse);
      expect(r, isA<Err<String>>());
      expect(r.statusCode.unwrap(), 500);
    });

    test('transf — returns transferred Err preserving metadata', () {
      final Result<int> err = Err<int>(
        'x',
        statusCode: 500,
        breadcrumbs: ['a'],
      );
      final r = err.transf<String>();
      expect(r, isA<Err<String>>());
      final transferred = r.err().unwrap();
      expect(transferred.error, 'x');
      expect(transferred.statusCode.unwrap(), 500);
      expect(transferred.breadcrumbs, ['a']);
    });

    test('transf — callback is never invoked on Err', () {
      final Result<int> err = Err<int>('x');
      var called = false;
      final r = err.transf<String>((_) {
        called = true;
        return 'nope';
      });
      expect(called, isFalse);
      expect(r, isA<Err<String>>());
    });

    test('toString — produces JSON string for normal case', () {
      final err = Err<int>('boom', statusCode: 503);
      final s = err.toString();
      expect(s, contains('boom'));
      expect(s, contains('Err<int>'));
      expect(s, contains('503'));
    });

    test('Err implements Exception', () {
      expect(Err<int>('boom'), isA<Exception>());
    });

    test('value equality — two Errs with same payload compare equal', () {
      // Equality is value-based via Equatable.props == [value].
      final a = Err<int>('boom');
      final b = Err<int>('boom');
      expect(a, equals(b));
    });
  });
}
