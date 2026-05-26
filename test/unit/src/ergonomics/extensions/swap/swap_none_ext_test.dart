import 'package:df_safer_dart/df_safer_dart.dart';
import 'package:test/test.dart';

void main() {
  group('swap_none_ext', () {
    test('SwapNoneSyncExt.swap turns None<Sync<T>> into Sync<None<T>>', () {
      const input = None<Sync<int>>();
      final swapped = input.swap();
      expect(swapped, isA<Sync<None<int>>>());
      final inner = swapped.value;
      expect(inner, isA<Ok<None<int>>>());
      expect((inner as Ok<None<int>>).unwrap(), isA<None<int>>());
    });

    test('SwapNoneAsyncExt.swap turns None<Async<T>> into Async<None<T>>', () async {
      const input = None<Async<int>>();
      final swapped = input.swap();
      expect(swapped, isA<Async<None<int>>>());
      final inner = await swapped.value;
      expect(inner, isA<Ok<None<int>>>());
      expect((inner as Ok<None<int>>).unwrap(), isA<None<int>>());
    });

    test('SwapNoneResolvableExt.swap turns None<Resolvable<T>> into Resolvable<None<T>>', () async {
      const input = None<Resolvable<int>>();
      final swapped = input.swap();
      expect(swapped, isA<Resolvable<None<int>>>());
      final inner = await swapped.value;
      expect(inner, isA<Ok<None<int>>>());
    });

    test('SwapNoneOptionExt.swap turns None<Option<T>> into Some<None<T>>', () {
      const input = None<Option<int>>();
      final swapped = input.swap();
      expect(swapped, isA<Some<None<int>>>());
      expect((swapped as Some<None<int>>).unwrap(), isA<None<int>>());
    });

    test('SwapNoneSomeExt.swap turns None<Some<T>> into Some<None<T>>', () {
      const input = None<Some<int>>();
      final swapped = input.swap();
      expect(swapped.unwrap(), isA<None<int>>());
    });

    test('SwapNoneResultExt.swap turns None<Result<T>> into Ok<None<T>>', () {
      const input = None<Result<int>>();
      final swapped = input.swap();
      expect(swapped, isA<Ok<None<int>>>());
      expect((swapped as Ok<None<int>>).unwrap(), isA<None<int>>());
    });

    test('SwapNoneOkExt.swap turns None<Ok<T>> into Ok<None<T>>', () {
      const input = None<Ok<int>>();
      final swapped = input.swap();
      expect(swapped.unwrap(), isA<None<int>>());
    });

    test('SwapNoneErrExt.swap turns None<Err<T>> into Err<None<T>>', () {
      const input = None<Err<int>>();
      final swapped = input.swap();
      expect(swapped, isA<Err<None<int>>>());
      // The const None() inside the swap impl is canonicalised to None<Object>,
      // since `T extends Object` cannot be reified through a const literal.
      expect(swapped.error, isA<None<Object>>());
    });
  });
}
