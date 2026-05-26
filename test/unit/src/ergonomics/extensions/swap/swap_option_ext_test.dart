import 'package:df_safer_dart/df_safer_dart.dart';
import 'package:test/test.dart';

void main() {
  group('swap_option_ext', () {
    test('SwapOptionSyncExt.swap on Some<Sync> yields Sync<Some>', () {
      final Option<Sync<int>> input = Some(Sync.okValue(1));
      final swapped = input.swap();
      final inner = swapped.value;
      expect(inner, isA<Ok<Option<int>>>());
      expect((inner as Ok<Option<int>>).unwrap(), isA<Some<int>>());
      expect((inner.unwrap() as Some<int>).unwrap(), 1);
    });

    test('SwapOptionSyncExt.swap on None<Sync> yields Sync<None>', () {
      const Option<Sync<int>> input = None();
      final swapped = input.swap();
      final inner = swapped.value;
      expect((inner as Ok<Option<int>>).unwrap(), isA<None<int>>());
    });

    test('SwapOptionAsyncExt.swap on Some<Async> yields Async<Some>', () async {
      final Option<Async<int>> input = Some(Async<int>(() async => 2));
      final swapped = input.swap();
      final inner = await swapped.value;
      expect((inner as Ok<Option<int>>).unwrap(), isA<Some<int>>());
      expect((inner.unwrap() as Some<int>).unwrap(), 2);
    });

    test('SwapOptionAsyncExt.swap on None<Async> yields Async<None>', () async {
      const Option<Async<int>> input = None();
      final swapped = input.swap();
      final inner = await swapped.value;
      expect((inner as Ok<Option<int>>).unwrap(), isA<None<int>>());
    });

    test(
        'SwapOptionResolvableExt.swap on Some<Resolvable> yields Resolvable<Some>',
        () async {
      final Resolvable<int> r = Sync.okValue(3);
      final Option<Resolvable<int>> input = Some(r);
      final swapped = input.swap();
      final inner = await swapped.value;
      expect((inner as Ok<Option<int>>).unwrap(), isA<Some<int>>());
    });

    test(
        'SwapOptionResolvableExt.swap on None<Resolvable> yields Resolvable<None>',
        () async {
      const Option<Resolvable<int>> input = None();
      final swapped = input.swap();
      final inner = await swapped.value;
      expect((inner as Ok<Option<int>>).unwrap(), isA<None<int>>());
    });

    test('SwapOptionSomeExt.swap on Some<Some> stays Some<Some>', () {
      const Option<Some<int>> input = Some(Some(4));
      final swapped = input.swap();
      expect(swapped.unwrap(), isA<Some<int>>());
      expect((swapped.unwrap() as Some<int>).unwrap(), 4);
    });

    test('SwapOptionSomeExt.swap on None<Some> yields Some<None>', () {
      const Option<Some<int>> input = None();
      final swapped = input.swap();
      expect(swapped.unwrap(), isA<None<int>>());
    });

    test('SwapOptionNoneExt.swap returns None<Option>', () {
      const Option<None<int>> input = Some(None());
      final swapped = input.swap();
      expect(swapped, isA<None<Option<int>>>());
    });

    test('SwapOptionResultExt.swap on Some<Ok> yields Ok<Some>', () {
      final Option<Result<int>> input = const Some(Ok(7));
      final swapped = input.swap();
      expect(swapped, isA<Ok<Option<int>>>());
      expect(((swapped as Ok<Option<int>>).unwrap() as Some<int>).unwrap(), 7);
    });

    test('SwapOptionResultExt.swap on Some<Err> yields Err', () {
      final Option<Result<int>> input = Some(Err<int>('bad'));
      final swapped = input.swap();
      expect(swapped, isA<Err<Option<int>>>());
    });

    test('SwapOptionResultExt.swap on None<Result> yields Ok<None>', () {
      const Option<Result<int>> input = None();
      final swapped = input.swap();
      expect(swapped, isA<Ok<Option<int>>>());
      expect((swapped as Ok<Option<int>>).unwrap(), isA<None<int>>());
    });

    test('SwapOptionOkExt.swap on Some<Ok> yields Ok<Some>', () {
      final Option<Ok<int>> input = const Some(Ok(8));
      final swapped = input.swap();
      expect(swapped.unwrap(), isA<Some<int>>());
      expect((swapped.unwrap() as Some<int>).unwrap(), 8);
    });

    test('SwapOptionOkExt.swap on None<Ok> yields Ok<None>', () {
      const Option<Ok<int>> input = None();
      final swapped = input.swap();
      expect(swapped.unwrap(), isA<None<int>>());
    });

    test('SwapOptionErrExt.swap on Some<Err> yields Err', () {
      final Option<Err<int>> input = Some(Err<int>('e'));
      final swapped = input.swap();
      expect(swapped.error, 'e');
    });

    test('SwapOptionErrExt.swap on None<Err> yields Err<None>', () {
      const Option<Err<int>> input = None();
      final swapped = input.swap();
      expect(swapped, isA<Err<Option<int>>>());
      // Runtime payload is None<Object> due to const-canonicalisation; the
      // declared API type still narrows to Option<int> statically.
      expect(swapped.error, isA<None>());
    });
  });
}
