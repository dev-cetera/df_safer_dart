import 'package:df_safer_dart/df_safer_dart.dart';
import 'package:test/test.dart';

void main() {
  group('swap_err_ext', () {
    test('SwapErrSyncExt.swap turns Err<Sync<T>> into Sync<Err<T>>', () {
      final Err<Sync<int>> input = Err<Sync<int>>('boom');
      final Sync<Err<int>> swapped = input.swap();
      expect(swapped, isA<Sync<Err<int>>>());
      final inner = swapped.value;
      expect(inner, isA<Err<int>>());
      expect((inner as Err<int>).error, 'boom');
    });

    test('SwapErrAsyncExt.swap turns Err<Async<T>> into Async<Err<T>>', () async {
      final Err<Async<int>> input = Err<Async<int>>('bad');
      final Async<Err<int>> swapped = input.swap();
      expect(swapped, isA<Async<Err<int>>>());
      final inner = await swapped.value;
      expect(inner, isA<Err<int>>());
      expect((inner as Err<int>).error, 'bad');
    });

    test('SwapErrResolvableExt.swap turns Err<Resolvable<T>> into Resolvable<Err<T>>', () async {
      final Err<Resolvable<int>> input = Err<Resolvable<int>>('nope');
      final Resolvable<Err<int>> swapped = input.swap();
      expect(swapped, isA<Resolvable<Err<int>>>());
      final inner = await swapped.value;
      expect(inner, isA<Err<int>>());
      expect((inner as Err<int>).error, 'nope');
    });

    test('SwapErrOptionExt.swap turns Err<Option<T>> into Option<Err<T>>', () {
      final Err<Option<int>> input = Err<Option<int>>('x');
      final Option<Err<int>> swapped = input.swap();
      expect(swapped, isA<Some<Err<int>>>());
      final inner = (swapped as Some<Err<int>>).unwrap();
      expect(inner.error, 'x');
    });

    test('SwapErrSomeExt.swap turns Err<Some<T>> into Some<Err<T>>', () {
      final Err<Some<int>> input = Err<Some<int>>('y');
      final Some<Err<int>> swapped = input.swap();
      final inner = swapped.unwrap();
      expect(inner, isA<Err<int>>());
      expect(inner.error, 'y');
    });

    test('SwapErrNoneExt.swap turns Err<None<T>> into None<Err<T>>', () {
      final Err<None<int>> input = Err<None<int>>('lost');
      final None<Err<int>> swapped = input.swap();
      expect(swapped, isA<None<Err<int>>>());
    });

    test('SwapErrResultExt.swap turns Err<Result<T>> into Ok<Err<T>>', () {
      final Err<Result<int>> input = Err<Result<int>>('boom');
      final Result<Err<int>> swapped = input.swap();
      expect(swapped, isA<Ok<Err<int>>>());
      final inner = (swapped as Ok<Err<int>>).unwrap();
      expect(inner.error, 'boom');
    });

    test('SwapErrOkExt.swap turns Err<Ok<T>> into Ok<Err<T>>', () {
      final Err<Ok<int>> input = Err<Ok<int>>('z');
      final Ok<Err<int>> swapped = input.swap();
      final inner = swapped.unwrap();
      expect(inner.error, 'z');
    });

    test('swap preserves the original error message across all variants', () {
      final Err<Sync<int>> input = Err<Sync<int>>('the-error');
      final swapped = input.swap();
      expect((swapped.value as Err<int>).error, 'the-error');
    });
  });
}
