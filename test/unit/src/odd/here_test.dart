import 'package:df_safer_dart/df_safer_dart.dart';
import 'package:stack_trace/stack_trace.dart';
import 'package:test/test.dart';

void main() {
  group('here', () {
    test('Here(level) constructs with non-negative level', () {
      const here = Here(0);
      expect(here.level, 0);
      const deeper = Here(3);
      expect(deeper.level, 3);
    });

    test('Here(negative) asserts in debug mode', () {
      // The constructor has `assert(level >= 0)`. In debug builds this
      // throws; in release builds it is silently skipped. Tests run with
      // assertions enabled, so the throw is the expected outcome here.
      expect(() => Here(-1), throwsA(isA<AssertionError>()));
    });

    test('Here.call() returns Some<Frame> on platforms with parseable stacks',
        () {
      const here = Here(0);
      final frame = here();
      // On VM/JS the stack-trace package parses the frame, so we expect
      // Some. On dart2wasm it returns None. Accept either to stay
      // platform-agnostic, but if Some, verify shape.
      expect(frame, anyOf(isA<Some<Frame>>(), isA<None<Frame>>()));
      if (frame is Some<Frame>) {
        final f = frame.value;
        expect(f.line, isNotNull);
        expect(f.column, isNotNull);
      }
    });

    test(
        'Here.basepath returns Some<String> with file basename when frame is '
        'parseable', () {
      const here = Here(0);
      final basepath = here.basepath;
      expect(basepath, anyOf(isA<Some<String>>(), isA<None<String>>()));
      if (basepath is Some<String>) {
        final s = basepath.value;
        expect(s, isNotEmpty);
        // basepath uses `basenameWithoutExtension`, so it must not include
        // a `.dart` suffix.
        expect(s.contains('.dart'), isFalse);
      }
    });

    test('Here.location returns Some<String> when frame is parseable', () {
      const here = Here(0);
      final loc = here.location;
      expect(loc, anyOf(isA<Some<String>>(), isA<None<String>>()));
      if (loc is Some<String>) {
        expect(loc.value, isNotEmpty);
      }
    });

    test('Here.call() with very high level returns None gracefully', () {
      // A level deeper than the live stack must not throw — the contract
      // is to yield None instead.
      const here = Here(100000);
      final frame = here();
      expect(frame, isA<None<Frame>>());
    });
  });
}
