import 'package:df_safer_dart/df_safer_dart.dart';
import 'package:test/test.dart';

void main() {
  group('to_void_on_outcome_ext', () {
    test('ToVoidOnOutcomeExt.toVoid returns the same instance typed as Outcome<void>', () {
      final Outcome<int> source = const Some<int>(1);
      final result = source.toVoid();
      expect(result, isA<Outcome<void>>());
      expect(identical(result, source), isTrue);
    });

    test('ToVoidOnResolvableExt.toVoid returns the same instance typed as Resolvable<void>', () {
      final Resolvable<int> source = Sync<int>.okValue(2);
      final result = source.toVoid();
      expect(result, isA<Resolvable<void>>());
      expect(identical(result, source), isTrue);
    });

    test('ToVoidOnSyncExt.toVoid returns the same instance typed as Sync<void>', () {
      final source = Sync<int>.okValue(3);
      final result = source.toVoid();
      expect(result, isA<Sync<void>>());
      expect(identical(result, source), isTrue);
    });

    test('ToVoidOnAsyncExt.toVoid returns the same instance typed as Async<void>', () async {
      final source = Async<int>.okValue(4);
      final result = source.toVoid();
      expect(result, isA<Async<void>>());
      expect(identical(result, source), isTrue);
      final settled = await source.value;
      expect(settled.unwrap(), 4);
    });

    test('ToVoidOnOptionExt.toVoid on Some returns same instance typed as Option<void>', () {
      final Option<int> source = const Some<int>(5);
      final result = source.toVoid();
      expect(result, isA<Option<void>>());
      expect(identical(result, source), isTrue);
    });

    test('ToVoidOnOptionExt.toVoid on None returns same instance typed as Option<void>', () {
      final Option<int> source = const None<int>();
      final result = source.toVoid();
      expect(result, isA<Option<void>>());
      expect(identical(result, source), isTrue);
    });

    test('ToVoidOnSomeExt.toVoid returns the same Some instance typed as Some<void>', () {
      const source = Some<int>(6);
      final result = source.toVoid();
      expect(result, isA<Some<void>>());
      expect(identical(result, source), isTrue);
    });

    test('ToVoidOnNoneExt.toVoid returns the same None instance typed as None<void>', () {
      const source = None<int>();
      final result = source.toVoid();
      expect(result, isA<None<void>>());
      expect(identical(result, source), isTrue);
    });

    test('ToVoidOnResultExt.toVoid on Ok returns same instance typed as Result<void>', () {
      final Result<int> source = const Ok<int>(7);
      final result = source.toVoid();
      expect(result, isA<Result<void>>());
      expect(identical(result, source), isTrue);
    });

    test('ToVoidOnResultExt.toVoid on Err returns same instance typed as Result<void>', () {
      final Result<int> source = Err<int>('boom');
      final result = source.toVoid();
      expect(result, isA<Result<void>>());
      expect(identical(result, source), isTrue);
    });

    test('ToVoidOnOkExt.toVoid returns the same Ok instance typed as Ok<void>', () {
      const source = Ok<int>(8);
      final result = source.toVoid();
      expect(result, isA<Ok<void>>());
      expect(identical(result, source), isTrue);
    });

    test('ToVoidOnErrExt.toVoid returns the same Err instance typed as Err<void>', () {
      final source = Err<int>('void-err');
      final result = source.toVoid();
      expect(result, isA<Err<void>>());
      expect(identical(result, source), isTrue);
      expect(result.error, 'void-err');
    });
  });
}
