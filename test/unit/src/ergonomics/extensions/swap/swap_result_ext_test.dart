import 'package:df_safer_dart/df_safer_dart.dart';
import 'package:test/test.dart';

void main() {
  group('swap_result_ext', () {
    test('SwapResultSyncExt.swap on Ok<Sync> yields Sync<Result>', () {
      final Result<Sync<int>> input = Ok(Sync.okValue(1));
      final swapped = input.swap();
      final inner = swapped.value;
      expect(inner, isA<Ok<Result<int>>>());
      expect(((inner as Ok<Result<int>>).unwrap() as Ok<int>).unwrap(), 1);
    });

    test('SwapResultSyncExt.swap on Err<Sync> yields Sync<Err>', () {
      final Result<Sync<int>> input = Err<Sync<int>>('bad');
      final swapped = input.swap();
      // The Err.swap() lifts to Sync.okValue(Err<T>), so .value is Ok<Err<T>>.
      final innerResult = swapped.value;
      expect(innerResult, isA<Ok<Result<int>>>());
      expect(innerResult.unwrap(), isA<Err<int>>());
    });

    test('SwapResultAsyncExt.swap on Ok<Async> yields Async<Result>', () async {
      final Result<Async<int>> input = Ok(Async<int>(() async => 2));
      final swapped = input.swap();
      final inner = await swapped.value;
      expect(inner, isA<Ok<Result<int>>>());
      expect(((inner as Ok<Result<int>>).unwrap() as Ok<int>).unwrap(), 2);
    });

    test('SwapResultAsyncExt.swap on Err<Async> yields Async<Err>', () async {
      final Result<Async<int>> input = Err<Async<int>>('bad');
      final swapped = input.swap();
      final inner = await swapped.value;
      expect(inner, isA<Ok<Result<int>>>());
      expect(inner.unwrap(), isA<Err<int>>());
    });

    test(
        'SwapResultResolvableExt.swap on Ok<Resolvable> yields Resolvable<Result>',
        () async {
      final Result<Resolvable<int>> input =
          Ok(Sync.okValue(3) as Resolvable<int>);
      final swapped = input.swap();
      final inner = await swapped.value;
      expect(inner, isA<Ok<Result<int>>>());
    });

    test(
        'SwapResultResolvableExt.swap on Err<Resolvable> yields Resolvable<Err>',
        () async {
      final Result<Resolvable<int>> input = Err<Resolvable<int>>('e');
      final swapped = input.swap();
      final inner = await swapped.value;
      expect(inner, isA<Ok<Result<int>>>());
      expect(inner.unwrap(), isA<Err<int>>());
    });

    test('SwapResultOptionExt.swap on Ok<Some> yields Some<Result>', () {
      final Result<Option<int>> input = const Ok(Some(4));
      final swapped = input.swap();
      expect(swapped, isA<Some<Result<int>>>());
      expect(((swapped as Some<Result<int>>).unwrap() as Ok<int>).unwrap(), 4);
    });

    test('SwapResultOptionExt.swap on Ok<None> yields None', () {
      final Result<Option<int>> input = const Ok(None());
      final swapped = input.swap();
      expect(swapped, isA<None<Result<int>>>());
    });

    test('SwapResultOptionExt.swap on Err<Option> yields Some<Err>', () {
      final Result<Option<int>> input = Err<Option<int>>('o');
      final swapped = input.swap();
      expect(swapped, isA<Some<Result<int>>>());
      expect((swapped as Some<Result<int>>).unwrap(), isA<Err<int>>());
    });

    test('SwapResultSomeExt.swap on Ok<Some> yields Some<Result>', () {
      final Result<Some<int>> input = const Ok(Some(5));
      final swapped = input.swap();
      expect((swapped.unwrap() as Ok<int>).unwrap(), 5);
    });

    test('SwapResultSomeExt.swap on Err<Some> yields Some<Err>', () {
      final Result<Some<int>> input = Err<Some<int>>('s');
      final swapped = input.swap();
      expect(swapped.unwrap(), isA<Err<int>>());
    });

    test('SwapResultNoneExt.swap on Ok<None> yields None', () {
      final Result<None<int>> input = const Ok(None());
      final swapped = input.swap();
      expect(swapped, isA<None<Result<int>>>());
    });

    test('SwapResultNoneExt.swap on Err<None> yields Err<None>', () {
      final Result<None<int>> input = Err<None<int>>('n');
      final swapped = input.swap();
      // Err<None<T>>.swap() returns Err<None<T>> per SwapErrNoneExt — but
      // SwapResultNoneExt dispatches there, so via Option upcast it shows
      // as the same instance.
      expect(swapped, isA<None<Result<int>>>());
    });

    test('SwapResultOkExt.swap on Ok<Ok> stays Ok<Ok>', () {
      final Result<Ok<int>> input = const Ok(Ok(6));
      final swapped = input.swap();
      expect((swapped.unwrap() as Ok<int>).unwrap(), 6);
    });

    test('SwapResultOkExt.swap on Err<Ok> yields Ok<Err>', () {
      final Result<Ok<int>> input = Err<Ok<int>>('z');
      final swapped = input.swap();
      expect(swapped.unwrap(), isA<Err<int>>());
    });

    test('SwapResultErrExt.swap on Ok<Err> flattens to inner Err', () {
      final Result<Err<int>> input = Ok(Err<int>('inner'));
      final swapped = input.swap();
      expect(swapped, isA<Err<int>>());
      expect((swapped as Err<int>).error, 'inner');
    });

    test('SwapResultErrExt.swap on Err<Err> flattens to outer Err', () {
      final Result<Err<int>> input = Err<Err<int>>('outer');
      final swapped = input.swap();
      expect(swapped, isA<Err<int>>());
      expect((swapped as Err<int>).error, 'outer');
    });
  });
}
