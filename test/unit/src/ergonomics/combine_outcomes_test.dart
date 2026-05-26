import 'package:df_safer_dart/df_safer_dart.dart';
import 'package:test/test.dart';

void main() {
  group('combine_outcomes', () {
    test('combineOutcome — flattens mixed Some/None outcomes', () async {
      final outcomes = <Outcome<int>>[
        Sync.okValue(1),
        const Some(2),
        const None<int>(),
        const Ok(3),
      ];
      final combined = combineOutcome<int>(outcomes);
      final list = await combined.value;
      final values = list.unwrap();
      expect(values.length, 4);
      expect(values[0], isA<Some<int>>());
      expect((values[0] as Some<int>).value, 1);
      expect(values[2], isA<None<int>>());
      expect((values[3] as Some<int>).value, 3);
    });

    test('combineOutcome — Err propagates', () async {
      final outcomes = <Outcome<int>>[
        const Ok<int>(1),
        Err<int>('boom'),
      ];
      final combined = combineOutcome<int>(outcomes);
      final result = await combined.value;
      expect(result.isErr(), isTrue);
    });

    test('combineResolvable — empty iterable yields Sync.okValue([])', () {
      final combined = combineResolvable<int>(const <Resolvable<int>>[]);
      expect(combined, isA<Sync<List<int>>>());
      final result = (combined as Sync<List<int>>).value;
      expect(result.unwrap(), isEmpty);
    });

    test('combineResolvable — all-Sync stays Sync', () {
      final combined = combineResolvable<int>([
        Sync.okValue(1),
        Sync.okValue(2),
      ]);
      expect(combined, isA<Sync<List<int>>>());
      final result = (combined as Sync<List<int>>).value;
      expect(result.unwrap(), [1, 2]);
    });

    test('combineResolvable — any Async promotes to Async', () async {
      final combined = combineResolvable<int>([
        Sync.okValue(1),
        Async.okValue(2),
      ]);
      expect(combined, isA<Async<List<int>>>());
      final result = await (combined as Async<List<int>>).value;
      expect(result.unwrap(), [1, 2]);
    });

    test(
      'combineResolvable — single-pass sync* generator is not lost',
      () {
        Iterable<Sync<int>> gen() sync* {
          yield Sync.okValue(10);
          yield Sync.okValue(20);
          yield Sync.okValue(30);
        }

        final combined = combineResolvable<int>(gen());
        final result = (combined as Sync<List<int>>).value;
        expect(result.unwrap(), [10, 20, 30]);
      },
    );

    test('combineResolvable — first Err short-circuits without onErr', () {
      final combined = combineResolvable<int>([
        Sync.okValue(1),
        Sync(() => throw StateError('one')),
        Sync(() => throw StateError('two')),
      ]);
      final result = (combined as Sync<List<int>>).value;
      expect(result.isErr(), isTrue);
    });

    test('combineSync — empty iterable yields okValue([])', () {
      final combined = combineSync<int>(const <Sync<int>>[]);
      final result = combined.value;
      expect(result.unwrap(), isEmpty);
    });

    test('combineSync — happy path aggregates values in order', () {
      final combined = combineSync<int>([
        Sync.okValue(1),
        Sync.okValue(2),
        Sync.okValue(3),
      ]);
      expect(combined.value.unwrap(), [1, 2, 3]);
    });

    test('combineSync — first Err propagates when onErr is null', () {
      final combined = combineSync<int>([
        Sync.okValue(1),
        Sync(() => throw StateError('boom')),
      ]);
      expect(combined.value.isErr(), isTrue);
    });

    test('combineSync — single-pass sync* generator not lost', () {
      Iterable<Sync<int>> gen() sync* {
        yield Sync.okValue(7);
        yield Sync.okValue(8);
      }

      final combined = combineSync<int>(gen());
      expect(combined.value.unwrap(), [7, 8]);
    });

    test('combineSync — onErr is invoked with full original results', () {
      final combined = combineSync<int>(
        [
          Sync.okValue(1),
          Sync(() => throw StateError('boom')),
        ],
        onErr: (all) {
          expect(all.length, 2);
          return Err<List<int>>('aggregated');
        },
      );
      final result = combined.value;
      expect(result.isErr(), isTrue);
    });

    test('combineAsync — empty iterable yields okValue([])', () async {
      final combined = combineAsync<int>(const <Async<int>>[]);
      final result = await combined.value;
      expect(result.unwrap(), isEmpty);
    });

    test('combineAsync — happy path aggregates concurrently', () async {
      final combined = combineAsync<int>([
        Async.okValue(1),
        Async.okValue(2),
        Async.okValue(3),
      ]);
      final result = await combined.value;
      expect(result.unwrap(), [1, 2, 3]);
    });

    test('combineAsync — Err propagates without onErr', () async {
      final combined = combineAsync<int>([
        Async.okValue(1),
        Async(() async => throw StateError('boom')),
      ]);
      final result = await combined.value;
      expect(result.isErr(), isTrue);
    });

    test('combineAsync — single-pass sync* generator not lost', () async {
      Iterable<Async<int>> gen() sync* {
        yield Async.okValue(11);
        yield Async.okValue(22);
      }

      final combined = combineAsync<int>(gen());
      final result = await combined.value;
      expect(result.unwrap(), [11, 22]);
    });

    test('combineOption — all Some returns Some(list)', () {
      final combined = combineOption<int>([
        const Some(1),
        const Some(2),
        const Some(3),
      ]);
      expect(combined, isA<Some<List<int>>>());
      expect((combined as Some<List<int>>).value, [1, 2, 3]);
    });

    test('combineOption — empty iterable returns Some([])', () {
      final combined = combineOption<int>(const <Option<int>>[]);
      expect(combined, isA<Some<List<int>>>());
      expect((combined as Some<List<int>>).value, isEmpty);
    });

    test('combineOption — any None short-circuits to None', () {
      final combined = combineOption<int>([
        const Some(1),
        const None<int>(),
        const Some(2),
      ]);
      expect(combined, isA<None<List<int>>>());
    });

    test('combineResult — all Ok returns Ok(list)', () {
      final combined = combineResult<int>([
        const Ok(1),
        const Ok(2),
        const Ok(3),
      ]);
      expect(combined.isOk(), isTrue);
      expect(combined.unwrap(), [1, 2, 3]);
    });

    test('combineResult — empty iterable returns Ok([])', () {
      final combined = combineResult<int>(const <Result<int>>[]);
      expect(combined.isOk(), isTrue);
      expect(combined.unwrap(), isEmpty);
    });

    test('combineResult — first Err propagates when onErr is null', () {
      final combined = combineResult<int>([
        const Ok(1),
        Err<int>('boom'),
        Err<int>('later'),
      ]);
      expect(combined.isErr(), isTrue);
    });

    test('combineResult — onErr receives full results list', () {
      var called = false;
      final combined = combineResult<int>(
        [
          const Ok(1),
          Err<int>('boom'),
          const Ok(3),
        ],
        onErr: (all) {
          called = true;
          expect(all.length, 3);
          return Err<List<int>>('aggregated');
        },
      );
      expect(called, isTrue);
      expect(combined.isErr(), isTrue);
    });

    test(
      'combineResult — single-pass sync* generator not lost (fast path)',
      () {
        Iterable<Result<int>> gen() sync* {
          yield const Ok(1);
          yield const Ok(2);
          yield const Ok(3);
        }

        final combined = combineResult<int>(gen());
        expect(combined.unwrap(), [1, 2, 3]);
      },
    );
  });
}
