import 'dart:async';

import 'package:df_safer_dart/df_safer_dart.dart';
import 'package:test/test.dart';

void main() {
  group('resolvable_ext', () {
    group('ToResolvableExt.toResolvable', () {
      test('on plain value returns a Sync wrapping Ok', () async {
        final r = 42.toResolvable();
        expect(r, isA<Resolvable<int>>());
        final result = await r.value;
        expect(result, isA<Ok<int>>());
        expect(result.unwrap(), 42);
      });

      test('on Future returns an Async wrapping Ok', () async {
        final FutureOr<int> fo = Future.value(7);
        final r = fo.toResolvable();
        final result = await r.value;
        expect(result, isA<Ok<int>>());
        expect(result.unwrap(), 7);
      });
    });

    group('ToAsyncExt.toAsync', () {
      test('on Future of value yields Ok asynchronously', () async {
        final async = Future.value(11).toAsync();
        expect(async, isA<Async<int>>());
        final result = await async.value;
        expect(result, isA<Ok<int>>());
        expect(result.unwrap(), 11);
      });

      test('thrown future error becomes Err', () async {
        final async =
            Future<int>.error(StateError('boom')).toAsync();
        final result = await async.value;
        expect(result, isA<Err<int>>());
      });
    });

    group('ToSync.toSync', () {
      test('on value returns Sync wrapping Ok', () {
        final sync = 5.toSync();
        expect(sync, isA<Sync<int>>());
        expect(sync.value, isA<Ok<int>>());
        expect(sync.value.unwrap(), 5);
      });

      test('respects onFinalize callback', () {
        var finalized = false;
        // ignore: unused_local_variable
        final sync = 1.toSync(onFinalize: () => finalized = true);
        expect(finalized, isTrue);
      });
    });

    group('SyncOptionExt.unwrapSync', () {
      test('Sync<Some> unwraps to the inner value', () {
        final sync = Sync.okValue<Option<int>>(const Some(3));
        expect(sync.unwrapSync(), 3);
      });

      test('Sync<None> throws when unwrapped', () {
        final sync = Sync.okValue<Option<int>>(const None());
        expect(sync.unwrapSync, throwsA(isA<Err>()));
      });
    });

    group('AsyncOptionExt.unwrapAsync', () {
      test('Async<Some> unwraps to the inner value', () async {
        final async = Async.okValue<Option<int>>(const Some(9));
        expect(await async.unwrapAsync(), 9);
      });

      test('Async<None> throws when unwrapped', () async {
        final async = Async.okValue<Option<int>>(const None());
        await expectLater(async.unwrapAsync(), throwsA(isA<Err>()));
      });
    });

    group('ResolvableOptionExt.unwrapSync', () {
      test('Sync receiver unwraps to inner value', () {
        final Resolvable<Option<int>> r =
            Sync.okValue<Option<int>>(const Some(13));
        expect(r.unwrapSync(), 13);
      });

      test('Async receiver throws (cannot unwrap sync)', () {
        final Resolvable<Option<int>> r =
            Async.okValue<Option<int>>(const Some(13));
        expect(r.unwrapSync, throwsA(isA<Err>()));
      });
    });

    group('ResolvableOptionExt.unwrapAsync', () {
      test('Async receiver unwraps to inner value', () async {
        final Resolvable<Option<int>> r =
            Async.okValue<Option<int>>(const Some(21));
        expect(await r.unwrapAsync(), 21);
      });

      test('Sync receiver throws (cannot unwrap async)', () async {
        final Resolvable<Option<int>> r =
            Sync.okValue<Option<int>>(const Some(21));
        await expectLater(r.unwrapAsync(), throwsA(isA<Err>()));
      });
    });
  });
}
