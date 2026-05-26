import 'package:df_safer_dart/df_safer_dart.dart';
import 'package:test/test.dart';

void main() {
  group('swap_ok_ext', () {
    test('SwapOkSyncExt.swap turns Ok<Sync<T>> into Sync<Ok<T>>', () {
      final Ok<Sync<int>> input = Ok(Sync.okValue(3));
      final Sync<Ok<int>> swapped = input.swap();
      expect(swapped, isA<Sync<Ok<int>>>());
      final inner = swapped.value;
      expect(inner, isA<Ok<Ok<int>>>());
      expect((inner as Ok<Ok<int>>).unwrap().unwrap(), 3);
    });

    test('SwapOkAsyncExt.swap turns Ok<Async<T>> into Async<Ok<T>>', () async {
      final Ok<Async<int>> input = Ok(Async<int>(() async => 9));
      final Async<Ok<int>> swapped = input.swap();
      expect(swapped, isA<Async<Ok<int>>>());
      final inner = await swapped.value;
      expect(inner, isA<Ok<Ok<int>>>());
      expect((inner as Ok<Ok<int>>).unwrap().unwrap(), 9);
    });

    test('SwapOkResolvableExt.swap turns Ok<Resolvable<T>> into Resolvable<Ok<T>>', () async {
      final Resolvable<int> r = Sync.okValue(5);
      final Ok<Resolvable<int>> input = Ok(r);
      final Resolvable<Ok<int>> swapped = input.swap();
      final inner = await swapped.value;
      expect(inner, isA<Ok<Ok<int>>>());
      expect((inner as Ok<Ok<int>>).unwrap().unwrap(), 5);
    });

    test('SwapOkOptionExt.swap turns Ok<Option<T>> into Option<Ok<T>>', () {
      final Ok<Option<int>> input = Ok(const Some(11));
      final Option<Ok<int>> swapped = input.swap();
      expect(swapped, isA<Some<Ok<int>>>());
      expect((swapped as Some<Ok<int>>).unwrap().unwrap(), 11);
    });

    test('SwapOkOptionExt.swap on Ok(None) returns None', () {
      final Ok<Option<int>> input = Ok(const None());
      final Option<Ok<int>> swapped = input.swap();
      expect(swapped, isA<None<Ok<int>>>());
    });

    test('SwapOkSomeExt.swap turns Ok<Some<T>> into Some<Ok<T>>', () {
      final Ok<Some<int>> input = Ok(const Some(2));
      final Some<Ok<int>> swapped = input.swap();
      expect(swapped.unwrap().unwrap(), 2);
    });

    test('SwapOkNoneExt.swap turns Ok<None<T>> into None<Ok<T>>', () {
      final Ok<None<int>> input = Ok(const None());
      final None<Ok<int>> swapped = input.swap();
      expect(swapped, isA<None<Ok<int>>>());
    });

    test('SwapOkResultExt.swap turns Ok<Result<T>> into Result<Ok<T>>', () {
      final Ok<Result<int>> input = Ok(Ok(13));
      final Result<Ok<int>> swapped = input.swap();
      expect(swapped, isA<Ok<Ok<int>>>());
      expect((swapped as Ok<Ok<int>>).unwrap().unwrap(), 13);
    });

    test('SwapOkResultExt.swap on Ok(Err) returns Err', () {
      final Ok<Result<int>> input = Ok(Err<int>('inner'));
      final Result<Ok<int>> swapped = input.swap();
      expect(swapped, isA<Err<Ok<int>>>());
      expect((swapped as Err<Ok<int>>).error, 'inner');
    });

    test('SwapOkErrExt.swap turns Ok<Err<T>> into Err<Ok<T>>', () {
      final Ok<Err<int>> input = Ok(Err<int>('thrown'));
      final Err<Ok<int>> swapped = input.swap();
      expect(swapped.error, 'thrown');
    });
  });
}
