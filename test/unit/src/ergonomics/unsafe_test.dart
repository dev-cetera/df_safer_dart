import 'package:df_safer_dart/df_safer_dart.dart';
import 'package:test/test.dart';

void main() {
  group('unsafe', () {
    test('UNSAFE returns the block result on success', () {
      final value = UNSAFE(() => 42);
      expect(value, 42);
    });

    test('UNSAFE returns a non-primitive block result unchanged', () {
      final list = [1, 2, 3];
      final out = UNSAFE(() => list);
      expect(identical(out, list), isTrue);
    });

    test('UNSAFE supports Outcome.unwrap on Ok', () {
      final value = UNSAFE(() => const Ok<int>(99).unwrap());
      expect(value, 99);
    });

    test('UNSAFE re-throws the original error unchanged (does NOT swallow)',
        () {
      final boom = StateError('boom');
      expect(
        () => UNSAFE<int>(() => throw boom),
        throwsA(same(boom)),
      );
    });

    test('UNSAFE re-throws Err thrown via unwrap on Err', () {
      final Result<int> err = Err<int>('failure');
      expect(
        () => UNSAFE<int>(err.unwrap),
        throwsA(isA<Err<int>>()),
      );
    });

    test('UNSAFE re-throws unwrap on None', () {
      const Option<int> none = None<int>();
      expect(
        () => UNSAFE<int>(() => none.unwrap()),
        throwsA(anything),
      );
    });

    test('UNSAFE preserves the runtime type of the block return', () {
      final out = UNSAFE<String>(() => 'hello');
      expect(out, isA<String>());
      expect(out, 'hello');
    });

    test('UNSAFE invokes the block exactly once', () {
      var count = 0;
      UNSAFE(() {
        count++;
        return 0;
      });
      expect(count, 1);
    });
  });
}
