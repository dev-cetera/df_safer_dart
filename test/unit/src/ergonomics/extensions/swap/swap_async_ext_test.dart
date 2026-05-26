import 'package:df_safer_dart/df_safer_dart.dart';
import 'package:test/test.dart';

void main() {
  group('swap_async_ext', () {
    test('SwapAsyncSomeExt.swap turns Async<Some<T>> into Some<Async<T>>', () async {
      final Async<Some<int>> input = Async<Some<int>>(() async => const Some(7));
      final Some<Async<int>> swapped = input.swap();
      final inner = swapped.unwrap();
      expect(inner, isA<Async<int>>());
      final result = await inner.value;
      expect(result.unwrap(), 7);
    });

    test('SwapAsyncNoneExt.swap turns Async<None<T>> into None<Async<T>>', () {
      final Async<None<int>> input = Async<None<int>>(() async => const None());
      final None<Async<int>> swapped = input.swap();
      expect(swapped, isA<None<Async<int>>>());
    });

    test('SwapAsyncOkExt.swap turns Async<Ok<T>> into Ok<Async<T>>', () async {
      final Async<Ok<int>> input = Async<Ok<int>>(() async => Ok(42));
      final Ok<Async<int>> swapped = input.swap();
      final inner = swapped.unwrap();
      expect(inner, isA<Async<int>>());
      final result = await inner.value;
      expect(result.unwrap(), 42);
    });
  });
}
