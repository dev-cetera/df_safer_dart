import 'package:df_safer_dart/df_safer_dart.dart';
import 'package:test/test.dart';

void main() {
  group('iterable_ext', () {
    group('IterableExt', () {
      test('noneIfEmpty returns Some for non-empty iterable', () {
        final out = [1, 2, 3].noneIfEmpty;
        expect(out, isA<Some<Iterable<int>>>());
        expect(out.unwrap().toList(), [1, 2, 3]);
      });

      test('noneIfEmpty returns None for empty iterable', () {
        expect(<int>[].noneIfEmpty, isA<None<Iterable<int>>>());
      });

      test('firstOrNone returns Some of first element', () {
        expect([1, 2].firstOrNone.unwrap(), 1);
      });

      test('firstOrNone returns None when empty', () {
        expect(<int>[].firstOrNone, isA<None<int>>());
      });

      test('lastOrNone returns Some of last element', () {
        expect([1, 2, 3].lastOrNone.unwrap(), 3);
      });

      test('lastOrNone returns None when empty', () {
        expect(<int>[].lastOrNone, isA<None<int>>());
      });

      test('singleOrNone returns Some when single element', () {
        expect([7].singleOrNone.unwrap(), 7);
      });

      test('singleOrNone returns None when more than one element', () {
        expect([1, 2].singleOrNone, isA<None<int>>());
      });

      test('singleOrNone returns None when empty', () {
        expect(<int>[].singleOrNone, isA<None<int>>());
      });

      test('firstWhereOrNone returns Some when match exists', () {
        expect([1, 2, 3].firstWhereOrNone((e) => e > 1).unwrap(), 2);
      });

      test('firstWhereOrNone returns None when no match', () {
        expect([1, 2, 3].firstWhereOrNone((e) => e > 9), isA<None<int>>());
      });

      test('lastWhereOrNone returns Some of last matching element', () {
        expect([1, 2, 3, 2].lastWhereOrNone((e) => e == 2).unwrap(), 2);
      });

      test('lastWhereOrNone returns None when no match', () {
        expect([1, 2, 3].lastWhereOrNone((e) => e > 9), isA<None<int>>());
      });

      test('singleWhereOrNone returns Some when exactly one match', () {
        expect([1, 2, 3].singleWhereOrNone((e) => e == 2).unwrap(), 2);
      });

      test('singleWhereOrNone returns None when multiple matches', () {
        expect(
          [1, 2, 2].singleWhereOrNone((e) => e == 2),
          isA<None<int>>(),
        );
      });

      test('reduceOrNone reduces non-empty iterable', () {
        expect([1, 2, 3].reduceOrNone((a, b) => a + b).unwrap(), 6);
      });

      test('reduceOrNone returns None on empty', () {
        expect(<int>[].reduceOrNone((a, b) => a + b), isA<None<int>>());
      });

      test('elementAtOrNone returns Some at valid index', () {
        expect([10, 20, 30].elementAtOrNone(1).unwrap(), 20);
      });

      test('elementAtOrNone returns None for negative index', () {
        expect([10, 20].elementAtOrNone(-1), isA<None<int>>());
      });

      test('elementAtOrNone returns None for out-of-bounds index', () {
        expect([10, 20].elementAtOrNone(99), isA<None<int>>());
      });
    });

    group('NoneIfEmptyOnListExt', () {
      test('non-empty list returns Some(this)', () {
        final list = [1, 2];
        final out = list.noneIfEmpty;
        expect(out, isA<Some<List<int>>>());
        expect(identical(out.unwrap(), list), isTrue);
      });

      test('empty list returns None', () {
        expect(<int>[].noneIfEmpty, isA<None<List<int>>>());
      });
    });

    group('NoneIfEmptyOnSetExt', () {
      test('non-empty set returns Some(this)', () {
        final set = {1, 2};
        final out = set.noneIfEmpty;
        expect(out, isA<Some<Set<int>>>());
        expect(identical(out.unwrap(), set), isTrue);
      });

      test('empty set returns None', () {
        expect(<int>{}.noneIfEmpty, isA<None<Set<int>>>());
      });
    });

    group('IterableOptionExt', () {
      final source = <Option<int>>[const Some(1), const None(), const Some(3)];

      test('whereSome keeps only Some entries', () {
        final out = source.whereSome().toList();
        expect(out, hasLength(2));
        expect(out, everyElement(isA<Some<int>>()));
      });

      test('whereNone keeps only None entries', () {
        final out = source.whereNone().toList();
        expect(out, hasLength(1));
        expect(out.single, isA<None<int>>());
      });

      test('values unwraps Some values', () {
        expect(source.values.toList(), [1, 3]);
      });

      test('sequenceList returns Some(list) when all Some', () {
        final all = <Option<int>>[const Some(1), const Some(2)];
        expect(all.sequenceList().unwrap(), [1, 2]);
      });

      test('sequenceList returns None when any None', () {
        expect(source.sequenceList(), isA<None<List<int>>>());
      });

      test('sequenceSet returns Some(set) when all Some', () {
        final all = <Option<int>>[const Some(1), const Some(2), const Some(1)];
        expect(all.sequenceSet().unwrap(), {1, 2});
      });

      test('sequenceSet returns None when any None', () {
        expect(source.sequenceSet(), isA<None<Set<int>>>());
      });

      test('partition splits some/none in one pass', () {
        final result = source.partition();
        expect(result.someParts.length, 2);
        expect(result.noneParts.length, 1);
      });
    });

    group('IterableFutureOptionExt', () {
      test('whereSome awaits and filters Some', () async {
        final futures = <Future<Option<int>>>[
          Future.value(const Some(1)),
          Future.value(const None()),
          Future.value(const Some(2)),
        ];
        final out = (await futures.whereSome()).toList();
        expect(out, hasLength(2));
        expect(out, everyElement(isA<Some<int>>()));
      });

      test('whereNone awaits and filters None', () async {
        final futures = <Future<Option<int>>>[
          Future.value(const Some(1)),
          Future.value(const None()),
        ];
        final out = (await futures.whereNone()).toList();
        expect(out, hasLength(1));
      });
    });

    group('IterableSomeExt.unwrapAll', () {
      test('unwraps every Some value', () {
        final list = <Some<int>>[const Some(1), const Some(2), const Some(3)];
        expect(list.unwrapAll().toList(), [1, 2, 3]);
      });

      test('empty iterable yields empty result', () {
        expect(<Some<int>>[].unwrapAll().toList(), <int>[]);
      });
    });

    group('FutureIterableSomeExt.unwrapAll', () {
      test('awaits then unwraps every Some value', () async {
        final fut = Future.value(<Some<int>>[const Some(7), const Some(8)]);
        expect((await fut.unwrapAll()).toList(), [7, 8]);
      });
    });

    group('IterableResultExt', () {
      final source = <Result<int>>[const Ok(1), Err('boom'), const Ok(3)];

      test('whereOk keeps only Ok entries', () {
        final out = source.whereOk().toList();
        expect(out, hasLength(2));
        expect(out, everyElement(isA<Ok<int>>()));
      });

      test('whereErr keeps only Err entries', () {
        final out = source.whereErr().toList();
        expect(out, hasLength(1));
        expect(out.single, isA<Err<int>>());
      });

      test('values unwraps Ok values', () {
        expect(source.values.toList(), [1, 3]);
      });

      test('sequenceList returns Some(list) when all Ok', () {
        final all = <Result<int>>[const Ok(1), const Ok(2)];
        expect(all.sequenceList().unwrap(), [1, 2]);
      });

      test('sequenceList returns None when any Err', () {
        expect(source.sequenceList(), isA<None<List<int>>>());
      });

      test('sequenceSet returns Some(set) when all Ok', () {
        final all = <Result<int>>[const Ok(1), const Ok(2), const Ok(1)];
        expect(all.sequenceSet().unwrap(), {1, 2});
      });

      test('sequenceSet returns None when any Err', () {
        expect(source.sequenceSet(), isA<None<Set<int>>>());
      });

      test('partition splits ok/err in one pass', () {
        final result = source.partition();
        expect(result.okParts.length, 2);
        expect(result.errParts.length, 1);
      });
    });

    group('IterableFutureResultExt', () {
      test('whereOk awaits and filters Ok', () async {
        final futures = <Future<Result<int>>>[
          Future.value(const Ok(1)),
          Future.value(Err<int>('e')),
          Future.value(const Ok(2)),
        ];
        final out = (await futures.whereOk()).toList();
        expect(out, hasLength(2));
        expect(out, everyElement(isA<Ok<int>>()));
      });

      test('whereErr awaits and filters Err', () async {
        final futures = <Future<Result<int>>>[
          Future.value(const Ok(1)),
          Future.value(Err<int>('e')),
        ];
        final out = (await futures.whereErr()).toList();
        expect(out, hasLength(1));
      });
    });

    group('IterableOkExt.unwrapAll', () {
      test('unwraps every Ok value', () {
        final list = <Ok<int>>[const Ok(1), const Ok(2), const Ok(3)];
        expect(list.unwrapAll().toList(), [1, 2, 3]);
      });

      test('empty iterable yields empty result', () {
        expect(<Ok<int>>[].unwrapAll().toList(), <int>[]);
      });
    });

    group('FutureIterableOkExt.unwrapAll', () {
      test('awaits then unwraps every Ok value', () async {
        final fut = Future.value(<Ok<int>>[const Ok(11), const Ok(12)]);
        expect((await fut.unwrapAll()).toList(), [11, 12]);
      });
    });

    group('IterableResolvableExt', () {
      Resolvable<int> mkSync(int v) => Sync.okValue(v);
      Resolvable<int> mkAsync(int v) => Async.okValue(v);
      final source = <Resolvable<int>>[mkSync(1), mkAsync(2), mkSync(3)];

      test('whereSync keeps only Sync entries', () {
        final out = source.whereSync().toList();
        expect(out, hasLength(2));
        expect(out, everyElement(isA<Sync<int>>()));
      });

      test('whereAsync keeps only Async entries', () {
        final out = source.whereAsync().toList();
        expect(out, hasLength(1));
        expect(out.single, isA<Async<int>>());
      });

      test('mapToAsync converts every entry to Async', () {
        final out = source.mapToAsync().toList();
        expect(out, hasLength(3));
        expect(out, everyElement(isA<Async<int>>()));
      });

      test('partition splits sync/async in one pass', () {
        final result = source.partition();
        expect(result.syncParts.length, 2);
        expect(result.asyncParts.length, 1);
      });
    });

    group('IterableSyncExt', () {
      test('mapToResults exposes the inner Results', () {
        final list = <Sync<int>>[Sync.okValue(1), Sync.err(Err<int>('e'))];
        final out = list.mapToResults().toList();
        expect(out, hasLength(2));
        expect(out[0], isA<Ok<int>>());
        expect(out[1], isA<Err<int>>());
      });

      test('resolveInSequence collects all values in order', () async {
        final list = <Sync<int>>[
          Sync.okValue(1),
          Sync.okValue(2),
          Sync.okValue(3),
        ];
        final out = list.resolveInSequence();
        // Underlying TaskSequencer schedules microtasks — await the value to
        // observe the final list.
        final result = out.value;
        expect(result, isA<Ok<List<int>>>());
        expect(result.unwrap(), [1, 2, 3]);
      });
    });

    group('IterableAsyncExt.mapToResults', () {
      test('exposes the inner Future<Result> for each Async', () async {
        final list = <Async<int>>[Async.okValue(5), Async.okValue(6)];
        final out = list.mapToResults().toList();
        final results = await Future.wait(out);
        expect(results.map((r) => r.unwrap()).toList(), [5, 6]);
      });
    });
  });
}
