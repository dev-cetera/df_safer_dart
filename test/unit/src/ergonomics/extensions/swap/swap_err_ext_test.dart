import 'package:df_safer_dart/df_safer_dart.dart';
import 'package:test/test.dart';

void main() {
  group('swap_err_ext', () {
    test('SwapErrSyncExt.swap turns Err<Sync<T>> into Sync<Err<T>>', () {
      final input = Err<Sync<int>>('boom');
      final swapped = input.swap();
      expect(swapped, isA<Sync<Err<int>>>());
      final innerResult = swapped.value;
      expect(innerResult, isA<Ok<Err<int>>>());
      final inner = innerResult.unwrap();
      expect(inner, isA<Err<int>>());
      expect(inner.error, 'boom');
    });

    test('SwapErrAsyncExt.swap turns Err<Async<T>> into Async<Err<T>>',
        () async {
      final input = Err<Async<int>>('bad');
      final swapped = input.swap();
      expect(swapped, isA<Async<Err<int>>>());
      final innerResult = await swapped.value;
      expect(innerResult, isA<Ok<Err<int>>>());
      final inner = innerResult.unwrap();
      expect(inner, isA<Err<int>>());
      expect(inner.error, 'bad');
    });

    test(
        'SwapErrResolvableExt.swap turns Err<Resolvable<T>> into Resolvable<Err<T>>',
        () async {
      final input = Err<Resolvable<int>>('nope');
      final swapped = input.swap();
      expect(swapped, isA<Resolvable<Err<int>>>());
      final innerResult = await swapped.value;
      expect(innerResult, isA<Ok<Err<int>>>());
      final inner = innerResult.unwrap();
      expect(inner, isA<Err<int>>());
      expect(inner.error, 'nope');
    });

    test('SwapErrOptionExt.swap turns Err<Option<T>> into Option<Err<T>>', () {
      final input = Err<Option<int>>('x');
      final swapped = input.swap();
      expect(swapped, isA<Some<Err<int>>>());
      final inner = (swapped as Some<Err<int>>).unwrap();
      expect(inner.error, 'x');
    });

    test('SwapErrSomeExt.swap turns Err<Some<T>> into Some<Err<T>>', () {
      final input = Err<Some<int>>('y');
      final swapped = input.swap();
      final inner = swapped.unwrap();
      expect(inner, isA<Err<int>>());
      expect(inner.error, 'y');
    });

    test('SwapErrNoneExt.swap turns Err<None<T>> into None<Err<T>>', () {
      final input = Err<None<int>>('lost');
      final swapped = input.swap();
      expect(swapped, isA<None<Err<int>>>());
    });

    test('SwapErrResultExt.swap turns Err<Result<T>> into Ok<Err<T>>', () {
      final input = Err<Result<int>>('boom');
      final swapped = input.swap();
      expect(swapped, isA<Ok<Err<int>>>());
      final inner = (swapped as Ok<Err<int>>).unwrap();
      expect(inner.error, 'boom');
    });

    test('SwapErrOkExt.swap turns Err<Ok<T>> into Ok<Err<T>>', () {
      final input = Err<Ok<int>>('z');
      final swapped = input.swap();
      final inner = swapped.unwrap();
      expect(inner.error, 'z');
    });

    test('swap preserves the original error message across all variants', () {
      final input = Err<Sync<int>>('the-error');
      final swapped = input.swap();
      final inner = swapped.value.unwrap();
      expect(inner.error, 'the-error');
    });
  });
}
