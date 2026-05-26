import 'package:df_safer_dart/df_safer_dart.dart';
import 'package:test/test.dart';

void main() {
  group('_ok', () {
    test('const constructor — value getter narrows to T', () {
      const ok = Ok<int>(42);
      expect(ok.value, 42);
      expect(ok.value, isA<int>());
    });

    test('isOk returns true', () {
      expect(const Ok<int>(1).isOk(), isTrue);
    });

    test('isErr returns false', () {
      expect(const Ok<int>(1).isErr(), isFalse);
    });

    test('ifOk invokes callback with self and ok', () {
      const ok = Ok<int>(7);
      Ok<int>? capturedSelf;
      Ok<int>? capturedOk;
      ok.ifOk((self, o) {
        capturedSelf = self;
        capturedOk = o;
      }).end();
      expect(identical(capturedSelf, ok), isTrue);
      expect(identical(capturedOk, ok), isTrue);
    });

    test('ifOk absorbs thrown error into Err', () {
      const ok = Ok<int>(7);
      final r = ok.ifOk((_, __) => throw StateError('boom'));
      expect(r.isErr(), isTrue);
    });

    test('ifErr does NOT invoke callback and returns this', () {
      const ok = Ok<int>(7);
      var called = false;
      final r = ok.ifErr((_, __) => called = true);
      expect(called, isFalse);
      expect(identical(r, ok), isTrue);
    });

    test('err() returns None', () {
      expect(const Ok<int>(1).err(), isA<None<Err<int>>>());
    });

    test('ok() returns Some(self)', () {
      const ok = Ok<int>(1);
      final some = ok.ok();
      expect(some, isA<Some<Ok<int>>>());
      expect(identical(some.unwrap(), ok), isTrue);
    });

    test('orNull returns value', () {
      expect(const Ok<int>(1).orNull(), 1);
    });

    test('flatMap — Ok pipeline returns next Ok', () {
      const ok = Ok<int>(2);
      final r = ok.flatMap<String>((v) => Ok('val=$v'));
      expect(r.unwrap(), 'val=2');
    });

    test('flatMap — callback returning Err propagates it', () {
      const ok = Ok<int>(2);
      final r = ok.flatMap<int>((_) => Err<int>('downstream'));
      expect(r.isErr(), isTrue);
      expect(r.err().unwrap().error, 'downstream');
    });

    test('flatMap — thrown Err preserves statusCode + breadcrumbs', () {
      const ok = Ok<int>(2);
      final thrown = Err<int>(
        'thrown',
        statusCode: 418,
        breadcrumbs: ['a', 'b'],
      );
      final r = ok.flatMap<int>((_) => throw thrown);
      expect(r.isErr(), isTrue);
      final e = r.err().unwrap();
      expect(e.error, 'thrown');
      expect(e.statusCode.unwrap(), 418);
      expect(e.breadcrumbs, ['a', 'b']);
    });

    test('flatMap — non-Err throw becomes Err with stackTrace', () {
      const ok = Ok<int>(2);
      final r = ok.flatMap<int>((_) => throw StateError('boom'));
      expect(r.isErr(), isTrue);
    });

    test('mapOk — Ok callback transforms', () {
      const ok = Ok<int>(2);
      final r = ok.mapOk((o) => Ok<int>(o.value * 10));
      expect(r.unwrap(), 20);
    });

    test('mapOk — thrown Err preserved verbatim', () {
      const ok = Ok<int>(2);
      final thrown = Err<int>('thrown', statusCode: 500);
      final r = ok.mapOk((_) => throw thrown);
      expect(r.err().unwrap().statusCode.unwrap(), 500);
    });

    test('mapOk — generic throw becomes Err', () {
      const ok = Ok<int>(2);
      final r = ok.mapOk((_) => throw StateError('x'));
      expect(r.isErr(), isTrue);
    });

    test('mapErr — returns this unchanged', () {
      const ok = Ok<int>(2);
      var called = false;
      final r = ok.mapErr((_) {
        called = true;
        return Err<int>('replaced');
      });
      expect(called, isFalse);
      expect(identical(r, ok), isTrue);
    });

    test('fold — onOk invoked, returned result propagates', () {
      const ok = Ok<int>(2);
      final r = ok.fold((o) => Ok<int>(o.value + 100), (_) => null);
      expect(r.unwrap(), 102);
    });

    test('fold — onOk returning null falls back to this', () {
      const ok = Ok<int>(2);
      final r = ok.fold((_) => null, (_) => null);
      expect(identical(r, ok), isTrue);
    });

    test('fold — thrown Err preserved verbatim', () {
      const ok = Ok<int>(2);
      final thrown = Err<int>('thrown', statusCode: 500);
      final r = ok.fold((_) => throw thrown, (_) => null);
      expect(r.err().unwrap().statusCode.unwrap(), 500);
    });

    test('fold — generic throw absorbed into Err', () {
      const ok = Ok<int>(2);
      final r = ok.fold((_) => throw StateError('x'), (_) => null);
      expect(r.isErr(), isTrue);
    });

    test('okOr — Ok keeps self', () {
      const ok = Ok<int>(1);
      const other = Ok<int>(99);
      expect(identical(ok.okOr(other), ok), isTrue);
    });

    test('errOr — Ok returns other', () {
      const ok = Ok<int>(1);
      const other = Ok<int>(99);
      expect(identical(ok.errOr(other), other), isTrue);
    });

    test('unwrap returns value', () {
      expect(const Ok<int>(7).unwrap(), 7);
    });

    test('unwrapOr returns value, ignores fallback', () {
      expect(const Ok<int>(7).unwrapOr(0), 7);
    });

    test('map — transforms value into new Ok<R>', () {
      const ok = Ok<int>(3);
      final r = ok.map<String>((v) => 'v=$v');
      expect(r.unwrap(), 'v=3');
    });

    test('map — thrown Err preserved verbatim', () {
      const ok = Ok<int>(3);
      final thrown = Err<int>('thrown', statusCode: 503);
      final r = ok.map<String>((_) => throw thrown);
      expect(r.err().unwrap().statusCode.unwrap(), 503);
    });

    test('map — generic throw absorbed into Err', () {
      const ok = Ok<int>(3);
      final r = ok.map<String>((_) => throw StateError('x'));
      expect(r.isErr(), isTrue);
    });

    test('transf — with mapper transforms', () {
      const ok = Ok<int>(5);
      final r = ok.transf<String>((v) => 'v=$v');
      expect(r.unwrap(), 'v=5');
    });

    test('transf — without mapper attempts cast (success)', () {
      const ok = Ok<Object>(5);
      final r = ok.transf<int>();
      expect(r.unwrap(), 5);
    });

    test('transf — without mapper, cast failure produces Err', () {
      const ok = Ok<Object>('hi');
      final r = ok.transf<int>();
      expect(r.isErr(), isTrue);
      final msg = r.err().unwrap().error.toString();
      expect(msg, contains('Cannot transform'));
    });

    test('transf — thrown Err in mapper preserved verbatim', () {
      const ok = Ok<int>(5);
      final thrown = Err<int>('thrown', statusCode: 422);
      final r = ok.transf<String>((_) => throw thrown);
      expect(r.err().unwrap().statusCode.unwrap(), 422);
    });

    test('transf — mapper exception wrapped with descriptive message', () {
      const ok = Ok<int>(5);
      final r = ok.transf<String>((_) => throw StateError('boom'));
      expect(r.isErr(), isTrue);
      final msg = r.err().unwrap().error.toString();
      expect(msg, contains('Cannot transform'));
    });
  });
}
