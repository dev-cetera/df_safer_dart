import 'package:df_safer_dart/df_safer_dart.dart';
import 'package:test/test.dart';

void main() {
  group('outcome', () {
    group('value', () {
      test('Some.value exposes the wrapped payload', () {
        const Outcome<int> some = Some(42);
        expect(some.value, 42);
      });

      test('None.value is the canonical empty marker', () {
        const Outcome<int> none = None();
        // None still has a `value` (the internal sentinel object); just
        // confirm it is non-null and stable for equality through props.
        expect(none.value, isNotNull);
      });

      test('Ok.value exposes the success payload', () {
        const Outcome<int> ok = Ok(7);
        expect(ok.value, 7);
      });

      test('Err.value exposes the error payload', () {
        final Outcome<int> err = Err<int>('boom');
        expect(err.value, 'boom');
      });

      test('Sync.value exposes the inner Result', () {
        final Outcome<int> sync = Sync<int>.okValue(1);
        expect(sync.value, isA<Ok<int>>());
      });

      test('Async.value exposes a Future<Result>', () async {
        final Outcome<int> async = Async<int>.okValue(1);
        final raw = async.value;
        expect(raw, isA<Future<Object>>());
        final result = await (raw as Future<Object>);
        expect(result, isA<Ok<int>>());
      });
    });

    group('reduce', () {
      test('Ok(42) reduces to Sync(Ok(Some(42)))', () async {
        final out = const Ok<int>(42).reduce<int>();
        expect(out, isA<Sync<Option<int>>>());
        final inner = await out.value;
        expect(inner, isA<Ok<Option<int>>>());
        expect(inner.unwrap(), const Some<int>(42));
      });

      test('None reduces to Sync(Ok(None))', () async {
        final out = const None<int>().reduce<int>();
        expect(out, isA<Sync<Option<int>>>());
        final inner = await out.value;
        expect(inner.unwrap(), isA<None<int>>());
      });

      test('Err reduces to Sync(Err) preserving the error value', () async {
        final out = Err<int>('bad').reduce<int>();
        expect(out, isA<Sync<Option<int>>>());
        final inner = await out.value;
        expect(inner, isA<Err<Option<int>>>());
        expect((inner as Err).error, 'bad');
      });

      test('Err.reduce preserves breadcrumbs across the type transfer', () async {
        final source = Err<int>(
          'broken',
          breadcrumbs: const ['stepA', 'stepB'],
          statusCode: 503,
        );
        final out = source.reduce<int>();
        final inner = await out.value;
        final err = inner as Err;
        expect(err.breadcrumbs, ['stepA', 'stepB']);
        expect(err.statusCode.unwrap(), 503);
      });

      test('Some(Some(Ok(99))) flattens all layers', () async {
        // Build a nested chain by hand using known constructors. We use the
        // dynamic-typed Outcome to let nested Outcomes nest as `value`.
        final Outcome inner = const Ok<int>(99);
        final Outcome middle = Some<Outcome>(inner);
        final Outcome outer = Some<Outcome>(middle);
        final reduced = outer.reduce<int>();
        final settled = await reduced.value;
        expect(settled, isA<Ok<Option<int>>>());
        expect(settled.unwrap(), const Some<int>(99));
      });

      test('1000-deep Some(Some(...Ok(7))) reduces without stack overflow',
          () async {
        Outcome current = const Ok<int>(7);
        for (var i = 0; i < 1000; i++) {
          current = Some<Outcome>(current);
        }
        final reduced = current.reduce<int>();
        final settled = await reduced.value;
        expect(settled.unwrap(), const Some<int>(7));
      });

      test('Async layer is unwrapped to a Some result asynchronously',
          () async {
        final async = Async<int>.okValue(123);
        final reduced = async.reduce<int>();
        expect(reduced, isA<Async<Option<int>>>());
        final settled = await reduced.value;
        expect(settled.unwrap(), const Some<int>(123));
      });
    });

    group('raw (unsafe)', () {
      test('raw returns the innermost raw value via dive (sync path)', () {
        final Outcome out = const Some<int>(5);
        final v = out.raw(
          onErr: (_) => -1,
          onNone: () => -2,
        );
        expect(v, 5);
      });

      test('raw invokes onNone for a None', () {
        final Outcome out = const None<int>();
        final v = out.raw(
          onErr: (_) => 'err',
          onNone: () => 'empty',
        );
        expect(v, 'empty');
      });

      test('raw invokes onErr for an Err and exposes the captured Err',
          () async {
        final Outcome out = Err<int>('xx');
        late Err observed;
        await out.raw(
          onErr: (e) {
            observed = e;
            return 0;
          },
          onNone: () => 0,
        );
        expect(observed.error, 'xx');
      });
    });

    group('rawSync', () {
      test('rawSync returns a Sync wrapping the raw value', () {
        final s = const Some<int>(10).rawSync();
        expect(s, isA<Sync>());
        expect((s.value as Ok).value, 10);
      });

      test('rawSync collapses None into an Err', () {
        final s = const None<int>().rawSync();
        expect(s.value, isA<Err>());
      });

      test('rawSync surfaces an Err present in the chain', () {
        final s = Err<int>('failure').rawSync();
        final err = s.value as Err;
        expect(err.error, 'failure');
      });

      test('rawSync turns an Async chain into an Err', () {
        final s = Async<int>.okValue(1).rawSync();
        expect(s.value, isA<Err>());
        final err = s.value as Err;
        expect(err.error.toString().toLowerCase(), contains('async'));
      });
    });

    group('rawAsync', () {
      test('rawAsync resolves with the inner raw value', () async {
        final a = Async<int>.okValue(11).rawAsync();
        final settled = await a.value;
        expect((settled as Ok).value, 11);
      });

      test('rawAsync collapses None into an Err', () async {
        final a = const None<int>().rawAsync();
        final settled = await a.value;
        expect(settled, isA<Err>());
      });

      test('rawAsync propagates an Err present in the chain', () async {
        final a = Err<int>('boom').rawAsync();
        final settled = await a.value;
        expect(settled, isA<Err>());
        expect((settled as Err).error, 'boom');
      });
    });

    group('unwrap', () {
      test('unwrap returns the contained value for Ok', () {
        expect(const Ok<int>(8).unwrap(), 8);
      });

      test('unwrap returns the value for Some', () {
        expect(const Some<int>(9).unwrap(), 9);
      });

      test('unwrap throws an Err for an Err', () {
        final Outcome<int> err = Err<int>('x');
        expect(err.unwrap, throwsA(isA<Err>()));
      });

      test('unwrap throws for None', () {
        const Outcome<int> none = None<int>();
        expect(none.unwrap, throwsA(isA<Object>()));
      });

      test('Sync.unwrap returns underlying value', () {
        expect(Sync<int>.okValue(13).unwrap(), 13);
      });

      test('Async.unwrap returns a Future resolving to the value', () async {
        expect(await Async<int>.okValue(14).unwrap(), 14);
      });
    });

    group('unwrapOr', () {
      test('unwrapOr returns the contained value for Ok', () {
        expect(const Ok<int>(3).unwrap(), 3);
        expect(const Ok<int>(3).unwrapOr(0), 3);
      });

      test('unwrapOr returns the fallback for Err', () {
        final Outcome<int> err = Err<int>('x');
        expect(err.unwrapOr(999), 999);
      });

      test('unwrapOr returns the fallback for None', () {
        const Outcome<int> none = None<int>();
        expect(none.unwrapOr(-1), -1);
      });

      test('Async.unwrapOr returns fallback when Async holds an Err',
          () async {
        final a = Async<int>.errValue((error: 'nope', statusCode: null));
        expect(await a.unwrapOr(42), 42);
      });
    });

    group('map', () {
      test('map on Ok transforms the value', () {
        final out = const Ok<int>(2).map((v) => v * 5);
        expect(out, isA<Ok<int>>());
        expect(out.unwrap(), 10);
      });

      test('map on Err preserves the error', () {
        final source = Err<int>('e');
        final mapped = source.map((v) => v * 5);
        expect(mapped, isA<Err<int>>());
        expect((mapped as Err).error, 'e');
      });

      test('map on Some transforms the value', () {
        final out = const Some<int>(2).map((v) => v + 3);
        expect(out, isA<Some<int>>());
        expect(out.unwrap(), 5);
      });

      test('map on Sync absorbs throws into Err', () async {
        final out = Sync<int>.okValue(1).map<int>(
          (_) => throw StateError('nope'),
        );
        expect(out, isA<Sync<int>>());
        expect((out as Sync).value, isA<Err>());
      });

      test('map on Async absorbs throws into Err', () async {
        final out = Async<int>.okValue(1).map<int>(
          (_) => throw StateError('nope'),
        );
        final settled = await (out as Async).value;
        expect(settled, isA<Err>());
      });
    });

    group('transf', () {
      test('transf without a mapper performs a direct generic transfer', () {
        final out = const Ok<int>(11).transf<num>();
        expect(out, isA<Outcome>());
        // The Ok<num>(11) preserves value.
        expect((out as Ok).value, 11);
      });

      test('transf on Err preserves the error and bumps the generic', () {
        final Outcome<int> source = Err<int>('e');
        final out = source.transf<String>();
        expect(out, isA<Err<String>>());
        expect((out as Err).error, 'e');
      });

      test('transf on Sync wraps a converted value', () async {
        final out = Sync<int>.okValue(2).transf<String>((v) => 'v=$v');
        expect(out, isA<Sync<String>>());
        expect((out as Sync).value, isA<Ok>());
        expect(((out).value as Ok).value, 'v=2');
      });

      test('transf on Async wraps a converted value asynchronously',
          () async {
        final out = Async<int>.okValue(2).transf<String>((v) => 'v=$v');
        final settled = await (out as Async).value;
        expect((settled as Ok).value, 'v=2');
      });
    });

    group('end', () {
      test('Sync.end is a no-op that returns void without throwing', () {
        Sync<int>.okValue(1).end();
      });

      test('Async.end detaches without throwing', () {
        // Async.end deliberately ignores in-flight futures and must not
        // throw — invoke it directly and assert nothing is raised.
        Async<int>.okValue(1).end();
      });

      test('Some.end and Ok.end are no-ops', () {
        const Some<int>(1).end();
        const Ok<int>(1).end();
      });

      test('Err.end and None.end are no-ops', () {
        Err<int>('e').end();
        const None<int>().end();
      });
    });

    group('equality (Equatable via props)', () {
      test('Two Some(42) instances compare equal', () {
        expect(const Some<int>(42) == const Some<int>(42), isTrue);
      });

      test('Two Ok(42) instances compare equal', () {
        expect(const Ok<int>(42) == const Ok<int>(42), isTrue);
      });

      test('Two Err("x") instances compare equal', () {
        expect(Err<int>('x') == Err<int>('x'), isTrue);
      });

      test('Two Sync.okValue(1) compare equal because Ok==Ok', () {
        expect(Sync<int>.okValue(1) == Sync<int>.okValue(1), isTrue);
      });

      test('Two Async built from separate closures are not equal', () {
        final a = Async<int>(() async => 1);
        final b = Async<int>(() async => 1);
        expect(a == b, isFalse);
      });

      test('Different runtime types are never equal even with same value', () {
        final Object some = const Some<int>(1);
        final Object ok = const Ok<int>(1);
        expect(some == ok, isFalse);
      });

      test('hashCode is stable for value-equal Some instances', () {
        expect(const Some<int>(1).hashCode, const Some<int>(1).hashCode);
      });
    });

    group('stringify (Equatable opt-out)', () {
      test('Outcome.stringify returns false for any subtype', () {
        expect(const Some<int>(1).stringify, false);
        expect(const Ok<int>(1).stringify, false);
        expect(const None<int>().stringify, false);
        expect(Err<int>('e').stringify, false);
        expect(Sync<int>.okValue(1).stringify, false);
        expect(Async<int>.okValue(1).stringify, false);
      });
    });

    group('props', () {
      test('props always contains the inner value', () {
        expect(const Some<int>(7).props, [7]);
        expect(const Ok<int>(8).props, [8]);
      });

      test('Sync.props wraps the Result instance', () {
        final sync = Sync<int>.okValue(5);
        expect(sync.props.length, 1);
        expect(sync.props.first, isA<Ok<int>>());
      });
    });

    group('sealed subtype check', () {
      test('Every concrete Outcome is one of the known sealed subtypes', () {
        for (final o in <Outcome>[
          const Some<int>(1),
          const None<int>(),
          const Ok<int>(1),
          Err<int>('e'),
          Sync<int>.okValue(1),
          Async<int>.okValue(1),
        ]) {
          expect(
            o is Some || o is None || o is Ok || o is Err || o is Sync ||
                o is Async,
            isTrue,
          );
        }
      });
    });
  });
}
