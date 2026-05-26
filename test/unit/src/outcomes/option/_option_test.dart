import 'package:df_safer_dart/df_safer_dart.dart';
import 'package:test/test.dart';

void main() {
  group('_option', () {
    test('Option.combine2 returns Some tuple when both inputs are Some', () {
      final combined = Option.combine2(const Some(1), const Some('a'));
      expect(combined, isA<Some<(int, String)>>());
      final tuple = combined.unwrap();
      expect(tuple.$1, 1);
      expect(tuple.$2, 'a');
    });

    test('Option.combine2 returns None when any input is None', () {
      final combined = Option.combine2<int, String>(
        const Some(1),
        const None(),
      );
      expect(combined, isA<None<(int, String)>>());
    });

    test('Option.combine3 returns Some triple when all inputs are Some', () {
      final combined = Option.combine3(
        const Some(1),
        const Some('a'),
        const Some(true),
      );
      expect(combined, isA<Some<(int, String, bool)>>());
      final tuple = combined.unwrap();
      expect(tuple.$1, 1);
      expect(tuple.$2, 'a');
      expect(tuple.$3, true);
    });

    test('Option.combine3 returns None when any input is None', () {
      final combined = Option.combine3<int, String, bool>(
        const Some(1),
        const None(),
        const Some(true),
      );
      expect(combined, isA<None<(int, String, bool)>>());
    });

    test('Option.from(value) returns Some for non-null value', () {
      final option = Option<int>.from(42);
      expect(option, isA<Some<int>>());
      expect(option.unwrap(), 42);
    });

    test('Option.from(null) returns None', () {
      final option = Option<int>.from(null);
      expect(option, isA<None<int>>());
    });

    // ignore: deprecated_member_use_from_same_package
    test('Option.fromNullable delegates to Option.from', () {
      // ignore: deprecated_member_use
      final some = Option<int>.fromNullable(7);
      // ignore: deprecated_member_use
      final none = Option<int>.fromNullable(null);
      expect(some, isA<Some<int>>());
      expect(some.unwrap(), 7);
      expect(none, isA<None<int>>());
    });

    test('asOption returns the same instance typed as Option<T>', () {
      const some = Some<int>(3);
      final asOpt = some.asOption();
      expect(identical(asOpt, some), isTrue);
    });

    test('Option subtypes are sealed to Some and None only', () {
      const Option<int> some = Some(1);
      const Option<int> none = None();
      expect(some is Some<int> || some is None<int>, isTrue);
      expect(none is Some<int> || none is None<int>, isTrue);
    });

    test('Option equality is structural via Equatable', () {
      expect(const Some<int>(1) == const Some<int>(1), isTrue);
      expect(const None<int>() == const None<int>(), isTrue);
      expect(const Some<int>(1) == const Some<int>(2), isFalse);
    });

    test('Option.end() is a no-op and returns void', () {
      const Option<int> some = Some(1);
      // Calling .end() must not throw; its return type is void.
      expect(() => some.end(), returnsNormally);
    });
  });
}
