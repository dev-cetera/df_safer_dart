import 'package:df_safer_dart/df_safer_dart.dart';
import 'package:test/test.dart';

void main() {
  group('swap_some_ext', () {
    test('SwapSomeSyncExt.swap turns Some<Sync<T>> into Sync<Some<T>>', () {
      final input = Some<Sync<int>>(Sync.okValue(1));
      final swapped = input.swap();
      final inner = swapped.value;
      expect(inner, isA<Ok<Some<int>>>());
      expect((inner as Ok<Some<int>>).unwrap().unwrap(), 1);
    });

    test('SwapSomeAsyncExt.swap turns Some<Async<T>> into Async<Some<T>>', () async {
      final input = Some<Async<int>>(Async<int>(() async => 2));
      final swapped = input.swap();
      final inner = await swapped.value;
      expect(inner, isA<Ok<Some<int>>>());
      expect((inner as Ok<Some<int>>).unwrap().unwrap(), 2);
    });

    test('SwapSomeResolvableExt.swap turns Some<Resolvable<T>> into Resolvable<Some<T>>', () async {
      final Resolvable<int> r = Sync.okValue(3);
      final input = Some<Resolvable<int>>(r);
      final swapped = input.swap();
      final inner = await swapped.value;
      expect(inner, isA<Ok<Some<int>>>());
      expect((inner as Ok<Some<int>>).unwrap().unwrap(), 3);
    });

    test('SwapSomeOptionExt.swap on Some(Some) yields Some<Some>', () {
      final input = const Some<Option<int>>(Some(4));
      final swapped = input.swap();
      expect(swapped, isA<Some<Some<int>>>());
      expect(((swapped as Some<Some<int>>).unwrap()).unwrap(), 4);
    });

    test('SwapSomeOptionExt.swap on Some(None) yields None', () {
      final input = const Some<Option<int>>(None());
      final swapped = input.swap();
      expect(swapped, isA<None<Some<int>>>());
    });

    test('SwapSomeNoneExt.swap turns Some<None<T>> into None<Some<T>>', () {
      const input = Some<None<int>>(None());
      final swapped = input.swap();
      expect(swapped, isA<None<Some<int>>>());
    });

    test('SwapSomeResultExt.swap on Some(Ok) yields Ok<Some>', () {
      final input = const Some<Result<int>>(Ok(5));
      final swapped = input.swap();
      expect(swapped, isA<Ok<Some<int>>>());
      expect((swapped as Ok<Some<int>>).unwrap().unwrap(), 5);
    });

    test('SwapSomeResultExt.swap on Some(Err) yields Err', () {
      final input = Some<Result<int>>(Err<int>('e'));
      final swapped = input.swap();
      expect(swapped, isA<Err<Some<int>>>());
      expect((swapped as Err<Some<int>>).error, 'e');
    });

    test('SwapSomeOkExt.swap turns Some<Ok<T>> into Ok<Some<T>>', () {
      final input = const Some<Ok<int>>(Ok(6));
      final swapped = input.swap();
      expect(swapped.unwrap().unwrap(), 6);
    });

    test('SwapSomeErrExt.swap turns Some<Err<T>> into Err<Some<T>>', () {
      final input = Some<Err<int>>(Err<int>('boom'));
      final swapped = input.swap();
      expect(swapped.error, 'boom');
    });
  });
}
