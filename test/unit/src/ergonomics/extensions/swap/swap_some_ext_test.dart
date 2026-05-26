import 'package:df_safer_dart/df_safer_dart.dart';
import 'package:test/test.dart';

void main() {
  group('swap_some_ext', () {
    test('SwapSomeSyncExt.swap turns Some<Sync<T>> into Sync<Some<T>>', () {
      final Some<Sync<int>> input = Some(Sync.okValue(1));
      final Sync<Some<int>> swapped = input.swap();
      final inner = swapped.value;
      expect(inner, isA<Ok<Some<int>>>());
      expect((inner as Ok<Some<int>>).unwrap().unwrap(), 1);
    });

    test('SwapSomeAsyncExt.swap turns Some<Async<T>> into Async<Some<T>>', () async {
      final Some<Async<int>> input = Some(Async<int>(() async => 2));
      final Async<Some<int>> swapped = input.swap();
      final inner = await swapped.value;
      expect(inner, isA<Ok<Some<int>>>());
      expect((inner as Ok<Some<int>>).unwrap().unwrap(), 2);
    });

    test('SwapSomeResolvableExt.swap turns Some<Resolvable<T>> into Resolvable<Some<T>>', () async {
      final Resolvable<int> r = Sync.okValue(3);
      final Some<Resolvable<int>> input = Some(r);
      final Resolvable<Some<int>> swapped = input.swap();
      final inner = await swapped.value;
      expect(inner, isA<Ok<Some<int>>>());
      expect((inner as Ok<Some<int>>).unwrap().unwrap(), 3);
    });

    test('SwapSomeOptionExt.swap on Some(Some) yields Some<Some>', () {
      final Some<Option<int>> input = Some(const Some(4));
      final Option<Some<int>> swapped = input.swap();
      expect(swapped, isA<Some<Some<int>>>());
      expect(((swapped as Some<Some<int>>).unwrap()).unwrap(), 4);
    });

    test('SwapSomeOptionExt.swap on Some(None) yields None', () {
      final Some<Option<int>> input = Some(const None());
      final Option<Some<int>> swapped = input.swap();
      expect(swapped, isA<None<Some<int>>>());
    });

    test('SwapSomeNoneExt.swap turns Some<None<T>> into None<Some<T>>', () {
      const Some<None<int>> input = Some(None());
      final None<Some<int>> swapped = input.swap();
      expect(swapped, isA<None<Some<int>>>());
    });

    test('SwapSomeResultExt.swap on Some(Ok) yields Ok<Some>', () {
      final Some<Result<int>> input = Some(Ok(5));
      final Result<Some<int>> swapped = input.swap();
      expect(swapped, isA<Ok<Some<int>>>());
      expect((swapped as Ok<Some<int>>).unwrap().unwrap(), 5);
    });

    test('SwapSomeResultExt.swap on Some(Err) yields Err', () {
      final Some<Result<int>> input = Some(Err<int>('e'));
      final Result<Some<int>> swapped = input.swap();
      expect(swapped, isA<Err<Some<int>>>());
      expect((swapped as Err<Some<int>>).error, 'e');
    });

    test('SwapSomeOkExt.swap turns Some<Ok<T>> into Ok<Some<T>>', () {
      final Some<Ok<int>> input = Some(Ok(6));
      final Ok<Some<int>> swapped = input.swap();
      expect(swapped.unwrap().unwrap(), 6);
    });

    test('SwapSomeErrExt.swap turns Some<Err<T>> into Err<Some<T>>', () {
      final Some<Err<int>> input = Some(Err<int>('boom'));
      final Err<Some<int>> swapped = input.swap();
      expect(swapped.error, 'boom');
    });
  });
}
