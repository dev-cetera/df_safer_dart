import 'package:df_safer_dart/df_safer_dart.dart';
import 'package:test/test.dart';

void main() {
  group('unit', () {
    test('Unit() factory returns the canonical instance', () {
      expect(identical(Unit(), Unit.instance), isTrue);
      expect(identical(Unit(), Unit()), isTrue);
    });

    test('Unit.instance is the canonical singleton', () {
      expect(identical(Unit.instance, Unit.instance), isTrue);
    });

    test('Unit.i is an alias for Unit.instance', () {
      expect(identical(Unit.i, Unit.instance), isTrue);
    });

    test('UNIT top-level constant equals Unit.instance', () {
      expect(identical(UNIT, Unit.instance), isTrue);
      expect(identical(UNIT, Unit()), isTrue);
    });

    test('Unit equality via Equatable: all Units are equal', () {
      // Equatable compares using `props`, which is empty for Unit, so any
      // two Units are equal.
      expect(Unit() == Unit.instance, isTrue);
      expect(UNIT == Unit(), isTrue);
    });

    test('Unit hashCode is stable across instances', () {
      expect(Unit().hashCode, Unit.instance.hashCode);
      expect(UNIT.hashCode, Unit().hashCode);
    });

    test('Unit.toString returns "Unit()"', () {
      expect(Unit().toString(), 'Unit()');
      expect(Unit.instance.toString(), 'Unit()');
      expect(UNIT.toString(), 'Unit()');
    });

    test('Unit.props is an empty list', () {
      expect(Unit().props, isEmpty);
      expect(Unit().props, isA<List<Object?>>());
    });

    test('Unit.stringify is false', () {
      expect(Unit().stringify, isFalse);
    });
  });
}
