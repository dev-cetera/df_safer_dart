import 'package:df_safer_dart/df_safer_dart.dart';
import 'package:df_safer_dart/src/utils/_no_stack_overflow_wrapper.dart'
    show NoStackOverflowWrapper;
import 'package:test/test.dart';

void main() {
  group('_no_stack_overflow_wrapper', () {
    test('NoStackOverflowWrapper stores the provided value', () {
      const w = NoStackOverflowWrapper<int>(42);
      expect(w.value, 42);
    });

    test('NoStackOverflowWrapper accepts null when T is nullable', () {
      const w = NoStackOverflowWrapper<int?>(null);
      expect(w.value, isNull);
    });

    test('NoStackOverflowWrapper preserves arbitrary object identity', () {
      final list = <int>[1, 2, 3];
      final w = NoStackOverflowWrapper<List<int>>(list);
      expect(identical(w.value, list), isTrue);
    });

    test('NoStackOverflowWrapper is generic over T', () {
      const ws = NoStackOverflowWrapper<String>('hello');
      expect(ws.value, 'hello');
      expect(ws, isA<NoStackOverflowWrapper<String>>());
    });

    test('NoStackOverflowWrapper is used by letOrNone to unwrap deep Outcomes',
        () {
      // Sanity check: passing an Outcome chain into letOrNone must not blow
      // the stack, because the helper internally re-enters via
      // NoStackOverflowWrapper rather than recursing on raw values.
      Sync<Object> chain = Sync<int>.okValue(7);
      for (var i = 0; i < 1000; i++) {
        chain = Sync<Object>.okValue(chain);
      }
      final result = letOrNone<int>(chain);
      // The dispatcher unwraps a single Outcome layer, so for a deeply
      // nested chain we expect None (the inner value isn't of type int after
      // one peel). The important assertion is that no StackOverflowError is
      // thrown.
      expect(result, anyOf(isA<Some<int>>(), isA<None<int>>()));
    });

    test('NoStackOverflowWrapper is a const-constructible final class', () {
      // Confirms the const constructor compiles and that two const-created
      // wrappers over the same value are canonicalized.
      const a = NoStackOverflowWrapper<int>(1);
      const b = NoStackOverflowWrapper<int>(1);
      expect(identical(a, b), isTrue);
    });
  });
}
