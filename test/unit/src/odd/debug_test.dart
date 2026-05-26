import 'package:df_safer_dart/df_safer_dart.dart';
import 'package:test/test.dart';

void main() {
  group('debug', () {
    test('kIsDartLibraryUI is a compile-time bool', () {
      // The constant is a `const bool`, so it must always be a `bool`
      // regardless of whether the host defines `dart.library.ui` or not.
      expect(kIsDartLibraryUI, isA<bool>());
    });

    test('kIsDartLibraryUI matches bool.fromEnvironment fallback semantics',
        () {
      // When `dart.library.ui` is not defined, `bool.fromEnvironment` returns
      // `false`. In the Dart VM test runner the flag is not set, so the
      // constant must be `false`. We compute the expected value the same
      // way the source does, so the assertion is environment-agnostic.
      const expected = bool.fromEnvironment('dart.library.ui');
      expect(kIsDartLibraryUI, expected);
    });
  });
}
