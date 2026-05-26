import 'package:df_safer_dart/df_safer_dart.dart';
import 'package:test/test.dart';

void main() {
  group('swap_resolvable_ext', () {
    test('SwapResolvableSomeExt.swap on Sync<Some> yields Some<Resolvable>', () async {
      final Resolvable<Some<int>> input = Sync<Some<int>>.okValue(const Some(1));
      final Some<Resolvable<int>> swapped = input.swap();
      final inner = await swapped.unwrap().value;
      expect(inner.unwrap(), 1);
    });

    test('SwapResolvableSomeExt.swap on Async<Some> yields Some<Resolvable>', () async {
      final Resolvable<Some<int>> input = Async<Some<int>>(() async => const Some(2));
      final Some<Resolvable<int>> swapped = input.swap();
      final inner = await swapped.unwrap().value;
      expect(inner.unwrap(), 2);
    });

    test('SwapResolvableNoneExt.swap turns Resolvable<None<T>> into None<Resolvable<T>>', () {
      final Resolvable<None<int>> input = Sync<None<int>>.okValue(const None());
      final None<Resolvable<int>> swapped = input.swap();
      expect(swapped, isA<None<Resolvable<int>>>());
    });

    test('SwapResolvableOkExt.swap on Sync<Ok> yields Ok<Resolvable>', () async {
      final Resolvable<Ok<int>> input = Sync<Ok<int>>.okValue(Ok(5));
      final Ok<Resolvable<int>> swapped = input.swap();
      final inner = await swapped.unwrap().value;
      expect(inner.unwrap(), 5);
    });

    test('SwapResolvableOkExt.swap on Async<Ok> yields Ok<Resolvable>', () async {
      final Resolvable<Ok<int>> input = Async<Ok<int>>(() async => Ok(6));
      final Ok<Resolvable<int>> swapped = input.swap();
      final inner = await swapped.unwrap().value;
      expect(inner.unwrap(), 6);
    });
  });
}
