import 'package:df_safer_dart/df_safer_dart.dart';
import 'package:test/test.dart';

void main() {
  group('swap_result_ext', () {
    test('SwapResultSyncExt.swap on Ok<Sync> yields Sync<Result>', () {
      final Result<Sync<int>> input = Ok(Sync.okValue(1));
      final Sync<Result<int>> swapped = input.swap();
      final inner = swapped.value;
      expect(inner, isA<Ok<Result<int>>>());
      expect(((inner as Ok<Result<int>>).unwrap() as Ok<int>).unwrap(), 1);
    });

    test('SwapResultSyncExt.swap on Err<Sync> yields Sync<Err>', () {
      final Result<Sync<int>> input = Err<Sync<int>>('bad');
      final Sync<Result<int>> swapped = input.swap();
      expect(swapped.value, isA<Err<int>>());
    });

    test('SwapResultAsyncExt.swap on Ok<Async> yields Async<Result>', () async {
      final Result<Async<int>> input = Ok(Async<int>(() async => 2));
      final Async<Result<int>> swapped = input.swap();
      final inner = await swapped.value;
      expect(inner, isA<Ok<Result<int>>>());
      expect(((inner as Ok<Result<int>>).unwrap() as Ok<int>).unwrap(), 2);
    });

    test('SwapResultAsyncExt.swap on Err<Async> yields Async<Err>', () async {
      final Result<Async<int>> input = Err<Async<int>>('bad');
      final Async<Result<int>> swapped = input.swap();
      final inner = await swapped.value;
      expect(inner, isA<Err<int>>());
    });

    test('SwapResultResolvableExt.swap on Ok<Resolvable> yields Resolvable<Result>', () async {
      final Result<Resolvable<int>> input = Ok(Sync.okValue(3) as Resolvable<int>);
      final Resolvable<Result<int>> swapped = input.swap();
      final inner = await swapped.value;
      expect(inner, isA<Ok<Result<int>>>());
    });

    test('SwapResultResolvableExt.swap on Err<Resolvable> yields Resolvable<Err>', () async {
      final Result<Resolvable<int>> input = Err<Resolvable<int>>('e');
      final Resolvable<Result<int>> swapped = input.swap();
      final inner = await swapped.value;
      expect(inner, isA<Err<int>>());
    });

    test('SwapResultOptionExt.swap on Ok<Some> yields Some<Result>', () {
      final Result<Option<int>> input = Ok(const Some(4));
      final Option<Result<int>> swapped = input.swap();
      expect(swapped, isA<Some<Result<int>>>());
      expect(((swapped as Some<Result<int>>).unwrap() as Ok<int>).unwrap(), 4);
    });

    test('SwapResultOptionExt.swap on Ok<None> yields None', () {
      final Result<Option<int>> input = Ok(const None());
      final Option<Result<int>> swapped = input.swap();
      expect(swapped, isA<None<Result<int>>>());
    });

    test('SwapResultOptionExt.swap on Err<Option> yields Some<Err>', () {
      final Result<Option<int>> input = Err<Option<int>>('o');
      final Option<Result<int>> swapped = input.swap();
      expect(swapped, isA<Some<Result<int>>>());
      expect((swapped as Some<Result<int>>).unwrap(), isA<Err<int>>());
    });

    test('SwapResultSomeExt.swap on Ok<Some> yields Some<Result>', () {
      final Result<Some<int>> input = Ok(const Some(5));
      final Some<Result<int>> swapped = input.swap();
      expect((swapped.unwrap() as Ok<int>).unwrap(), 5);
    });

    test('SwapResultSomeExt.swap on Err<Some> yields Some<Err>', () {
      final Result<Some<int>> input = Err<Some<int>>('s');
      final Some<Result<int>> swapped = input.swap();
      expect(swapped.unwrap(), isA<Err<int>>());
    });

    test('SwapResultNoneExt.swap on Ok<None> yields None', () {
      final Result<None<int>> input = Ok(const None());
      final Option<Result<int>> swapped = input.swap();
      expect(swapped, isA<None<Result<int>>>());
    });

    test('SwapResultNoneExt.swap on Err<None> yields Err<None>', () {
      final Result<None<int>> input = Err<None<int>>('n');
      final Option<Result<int>> swapped = input.swap();
      // Err<None<T>>.swap() returns Err<None<T>> per SwapErrNoneExt — but
      // SwapResultNoneExt dispatches there, so via Option upcast it shows
      // as the same instance.
      expect(swapped, isA<None<Result<int>>>());
    });

    test('SwapResultOkExt.swap on Ok<Ok> stays Ok<Ok>', () {
      final Result<Ok<int>> input = Ok(Ok(6));
      final Ok<Result<int>> swapped = input.swap();
      expect((swapped.unwrap() as Ok<int>).unwrap(), 6);
    });

    test('SwapResultOkExt.swap on Err<Ok> yields Ok<Err>', () {
      final Result<Ok<int>> input = Err<Ok<int>>('z');
      final Ok<Result<int>> swapped = input.swap();
      expect(swapped.unwrap(), isA<Err<int>>());
    });

    test('SwapResultErrExt.swap on Ok<Err> flattens to inner Err', () {
      final Result<Err<int>> input = Ok(Err<int>('inner'));
      final Result<int> swapped = input.swap();
      expect(swapped, isA<Err<int>>());
      expect((swapped as Err<int>).error, 'inner');
    });

    test('SwapResultErrExt.swap on Err<Err> flattens to outer Err', () {
      final Result<Err<int>> input = Err<Err<int>>('outer');
      final Result<int> swapped = input.swap();
      expect(swapped, isA<Err<int>>());
      expect((swapped as Err<int>).error, 'outer');
    });
  });
}
