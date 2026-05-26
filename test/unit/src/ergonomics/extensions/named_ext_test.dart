import 'package:df_safer_dart/df_safer_dart.dart';
import 'package:test/test.dart';

void main() {
  group('named_ext', () {
    group('NamedResultExt.named', () {
      test('Err receiver records label as breadcrumb', () {
        final result = Err<int>('boom').named('step-a');
        expect(result, isA<Err<int>>());
        expect((result as Err<int>).breadcrumbs, ['step-a']);
      });

      test('Ok receiver is a no-op and returns the same instance', () {
        const ok = Ok<int>(1);
        final out = ok.named('step-a');
        expect(identical(out, ok), isTrue);
      });

      test('Err already carrying breadcrumbs is not overwritten', () {
        final original = Err<int>('boom').named('first');
        final after = original.named('second');
        expect((after as Err<int>).breadcrumbs, ['first']);
      });
    });

    group('NamedSyncExt.named', () {
      test('Sync wrapping Err carries label after named()', () {
        final sync = Sync.err(Err<int>('boom')).named('step-b');
        final inner = sync.value;
        expect(inner, isA<Err<int>>());
        expect((inner as Err<int>).breadcrumbs, ['step-b']);
      });

      test('Sync wrapping Ok is unaffected', () {
        final sync = Sync.okValue(42).named('step-b');
        expect(sync.value, isA<Ok<int>>());
      });
    });

    group('NamedAsyncExt.named', () {
      test('Async wrapping Err carries label after named()', () async {
        final async = Async.err(Err<int>('boom')).named('step-c');
        final result = await async.value;
        expect(result, isA<Err<int>>());
        expect((result as Err<int>).breadcrumbs, ['step-c']);
      });

      test('Async wrapping Ok is unaffected', () async {
        final async = Async.okValue(7).named('step-c');
        final result = await async.value;
        expect(result, isA<Ok<int>>());
      });
    });

    group('NamedResolvableExt.named', () {
      test('dispatches to Sync receiver', () {
        final Resolvable<int> r = Sync.err(Err<int>('boom'));
        final out = r.named('via-resolvable');
        expect(out, isA<Sync<int>>());
        final inner = (out as Sync<int>).value;
        expect((inner as Err<int>).breadcrumbs, ['via-resolvable']);
      });

      test('dispatches to Async receiver', () async {
        final Resolvable<int> r = Async.err(Err<int>('boom'));
        final out = r.named('via-resolvable');
        expect(out, isA<Async<int>>());
        final result = await (out as Async<int>).value;
        expect((result as Err<int>).breadcrumbs, ['via-resolvable']);
      });
    });
  });
}
