import 'package:df_safer_dart/df_safer_dart.dart';
import 'package:test/test.dart';

void main() {
  group('err_model', () {
    test('const constructor — assigns all fields', () {
      const m = ErrModel(
        type: 'Err<int>',
        error: 'boom',
        statusCode: 500,
        stackTrace: ['frame1'],
      );
      expect(m.type, 'Err<int>');
      expect(m.error, 'boom');
      expect(m.statusCode, 500);
      expect(m.stackTrace, ['frame1']);
    });

    test('const constructor — optional fields default to null', () {
      const m = ErrModel(type: 'Err<int>', error: 'boom');
      expect(m.statusCode, isNull);
      expect(m.stackTrace, isNull);
    });

    test('const constructor — required fields can be null', () {
      const m = ErrModel(type: null, error: null);
      expect(m.type, isNull);
      expect(m.error, isNull);
    });

    test('copyWith — replaces only specified fields', () {
      const original = ErrModel(
        type: 'Err<int>',
        error: 'boom',
        statusCode: 500,
        stackTrace: ['frame1'],
      );
      final updated = original.copyWith(error: 'changed', statusCode: 503);
      expect(updated.type, 'Err<int>');
      expect(updated.error, 'changed');
      expect(updated.statusCode, 503);
      expect(updated.stackTrace, ['frame1']);
    });

    test('copyWith — no arguments produces an equivalent copy', () {
      const original = ErrModel(
        type: 'Err<int>',
        error: 'boom',
        statusCode: 500,
        stackTrace: ['frame1'],
      );
      final copy = original.copyWith();
      expect(copy.type, original.type);
      expect(copy.error, original.error);
      expect(copy.statusCode, original.statusCode);
      expect(copy.stackTrace, original.stackTrace);
    });

    test('copyWithout — clears specified fields, keeps others', () {
      const original = ErrModel(
        type: 'Err<int>',
        error: 'boom',
        statusCode: 500,
        stackTrace: ['frame1'],
      );
      final cleared = original.copyWithout(statusCode: false, error: false);
      expect(cleared.type, 'Err<int>');
      expect(cleared.error, isNull);
      expect(cleared.statusCode, isNull);
      expect(cleared.stackTrace, ['frame1']);
    });

    test('copyWithout — defaults keep all fields', () {
      const original = ErrModel(
        type: 'Err<int>',
        error: 'boom',
        statusCode: 500,
        stackTrace: ['frame1'],
      );
      final kept = original.copyWithout();
      expect(kept.type, original.type);
      expect(kept.error, original.error);
      expect(kept.statusCode, original.statusCode);
      expect(kept.stackTrace, original.stackTrace);
    });

    test('type\$ — unwraps non-null type', () {
      const m = ErrModel(type: 'Err<int>', error: null);
      expect(m.type$, 'Err<int>');
    });

    test('type\$ — throws on null', () {
      const m = ErrModel(type: null, error: null);
      expect(() => m.type$, throwsA(isA<TypeError>()));
    });

    test('error\$ — unwraps non-null error', () {
      const m = ErrModel(type: null, error: 'boom');
      expect(m.error$, 'boom');
    });

    test('error\$ — throws on null', () {
      const m = ErrModel(type: null, error: null);
      expect(() => m.error$, throwsA(isA<TypeError>()));
    });

    test('statusCode\$ — returns nullable value (non-null)', () {
      const m = ErrModel(type: null, error: null, statusCode: 503);
      expect(m.statusCode$, 503);
    });

    test('statusCode\$ — returns null when absent', () {
      const m = ErrModel(type: null, error: null);
      expect(m.statusCode$, isNull);
    });

    test('stackTrace\$ — returns nullable list (non-null)', () {
      const m = ErrModel(type: null, error: null, stackTrace: ['f1']);
      expect(m.stackTrace$, ['f1']);
    });

    test('stackTrace\$ — returns null when absent', () {
      const m = ErrModel(type: null, error: null);
      expect(m.stackTrace$, isNull);
    });
  });
}
