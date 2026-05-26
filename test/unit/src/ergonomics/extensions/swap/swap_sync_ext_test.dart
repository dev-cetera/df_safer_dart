import 'package:df_safer_dart/df_safer_dart.dart';
import 'package:test/test.dart';

void main() {
  group('swap_sync_ext', () {
    test('SwapSyncAsyncExt.swap on Sync(Ok(Async)) yields Async<Sync>', () async {
      final input = Sync<Async<int>>.okValue(Async<int>(() async => 1));
      final swapped = input.swap();
      final outer = await swapped.value;
      expect(outer, isA<Ok<Sync<int>>>());
      final innerSync = (outer as Ok<Sync<int>>).unwrap();
      expect((innerSync.value as Ok<int>).unwrap(), 1);
    });

    test('SwapSyncAsyncExt.swap on Sync.err(Async) yields Async<Sync<Err>>', () async {
      final input = Sync<Async<int>>.err(Err<Async<int>>('bad'));
      final swapped = input.swap();
      final outer = await swapped.value;
      expect(outer, isA<Ok<Sync<int>>>());
      final innerSync = (outer as Ok<Sync<int>>).unwrap();
      expect(innerSync.value, isA<Err<int>>());
      expect((innerSync.value as Err<int>).error, 'bad');
    });

    test('SwapSyncResolvableExt.swap on Sync(Ok(Sync)) yields Sync wrapping Sync', () async {
      final Resolvable<int> r = Sync.okValue(2);
      final input = Sync<Resolvable<int>>.okValue(r);
      final swapped = input.swap();
      final outer = await swapped.value;
      expect(outer, isA<Ok<Sync<int>>>());
      final innerSync = (outer as Ok<Sync<int>>).unwrap();
      expect((innerSync.value as Ok<int>).unwrap(), 2);
    });

    test('SwapSyncResolvableExt.swap on Sync(Ok(Async)) yields Async<Sync>', () async {
      final Resolvable<int> r = Async<int>(() async => 3);
      final input = Sync<Resolvable<int>>.okValue(r);
      final swapped = input.swap();
      expect(swapped, isA<Async<Sync<int>>>());
      final outer = await swapped.value;
      final innerSync = (outer as Ok<Sync<int>>).unwrap();
      expect((innerSync.value as Ok<int>).unwrap(), 3);
    });

    test('SwapSyncResolvableExt.swap on Sync.err yields Sync wrapping failed Sync', () async {
      final input =
          Sync<Resolvable<int>>.err(Err<Resolvable<int>>('e'));
      final swapped = input.swap();
      final outer = await swapped.value;
      final innerSync = (outer as Ok<Sync<int>>).unwrap();
      expect(innerSync.value, isA<Err<int>>());
    });

    test('SwapSyncOptionExt.swap on Sync(Ok(Some)) yields Some<Sync>', () {
      final input = Sync<Option<int>>.okValue(const Some(4));
      final swapped = input.swap();
      expect(swapped, isA<Some<Sync<int>>>());
      final innerSync = (swapped as Some<Sync<int>>).unwrap();
      expect((innerSync.value as Ok<int>).unwrap(), 4);
    });

    test('SwapSyncOptionExt.swap on Sync(Ok(None)) yields None', () {
      final input = Sync<Option<int>>.okValue(const None());
      final swapped = input.swap();
      expect(swapped, isA<None<Sync<int>>>());
    });

    test('SwapSyncOptionExt.swap on Sync.err yields Some<Sync<Err>>', () {
      final input = Sync<Option<int>>.err(Err<Option<int>>('e'));
      final swapped = input.swap();
      expect(swapped, isA<Some<Sync<int>>>());
      final innerSync = (swapped as Some<Sync<int>>).unwrap();
      expect(innerSync.value, isA<Err<int>>());
    });

    test('SwapSyncSomeExt.swap turns Sync<Some<T>> into Some<Sync<T>>', () {
      final input = Sync<Some<int>>.okValue(const Some(5));
      final swapped = input.swap();
      expect((swapped.unwrap().value as Ok<int>).unwrap(), 5);
    });

    test('SwapSyncNoneExt.swap turns Sync<None<T>> into None<Sync<T>>', () {
      final input = Sync<None<int>>.okValue(const None());
      final swapped = input.swap();
      expect(swapped, isA<None<Sync<int>>>());
    });

    test('SwapSyncResultExt.swap on Sync(Ok(Ok)) yields Ok<Sync>', () {
      final input = Sync<Result<int>>.okValue(const Ok(7));
      final swapped = input.swap();
      expect(swapped, isA<Ok<Sync<int>>>());
      expect(((swapped as Ok<Sync<int>>).unwrap().value as Ok<int>).unwrap(), 7);
    });

    test('SwapSyncResultExt.swap on Sync(Ok(Err)) yields Err', () {
      final input = Sync<Result<int>>.okValue(Err<int>('inner'));
      final swapped = input.swap();
      expect(swapped, isA<Err<Sync<int>>>());
      expect((swapped as Err<Sync<int>>).error, 'inner');
    });

    test('SwapSyncResultExt.swap on Sync.err yields Err', () {
      final input = Sync<Result<int>>.err(Err<Result<int>>('outer'));
      final swapped = input.swap();
      expect(swapped, isA<Err<Sync<int>>>());
      expect((swapped as Err<Sync<int>>).error, 'outer');
    });

    test('SwapSyncOkExt.swap turns Sync<Ok<T>> into Ok<Sync<T>>', () {
      final input = Sync<Ok<int>>.okValue(const Ok(8));
      final swapped = input.swap();
      expect((swapped.unwrap().value as Ok<int>).unwrap(), 8);
    });

    test('SwapSyncErrExt.swap turns Sync<Err<T>> into Err<Sync<T>>', () {
      final input = Sync<Err<int>>.okValue(Err<int>('boom'));
      final swapped = input.swap();
      expect(swapped.error, 'boom');
    });
  });
}
