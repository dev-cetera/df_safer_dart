import 'package:df_safer_dart/df_safer_dart.dart';
import 'package:test/test.dart';

void main() {
  group('wrap_outcome_ext', () {
    // ─── WrapOnOutcomeExt<T, M> ──────────────────────────────────────────────

    test('WrapOnOutcomeExt.wrapInSome wraps the outcome itself in Some', () {
      const some = Some<int>(1);
      final wrapped = some.wrapInSome();
      expect(wrapped, isA<Some<Some<int>>>());
      expect(identical(wrapped.value, some), isTrue);
    });

    test('WrapOnOutcomeExt.wrapInOk wraps the outcome itself in Ok', () {
      const some = Some<int>(2);
      final wrapped = some.wrapInOk();
      expect(wrapped, isA<Ok<Some<int>>>());
      expect(identical(wrapped.value, some), isTrue);
    });

    test('WrapOnOutcomeExt.wrapInResolvable wraps the outcome in a Resolvable', () async {
      const some = Some<int>(3);
      final wrapped = some.wrapInResolvable();
      expect(wrapped, isA<Resolvable<Some<int>>>());
      final settled = await wrapped.toAsync().value;
      expect(identical(settled.unwrap(), some), isTrue);
    });

    test('WrapOnOutcomeExt.wrapInSync wraps the outcome in a Sync', () {
      const some = Some<int>(4);
      final wrapped = some.wrapInSync();
      expect(wrapped, isA<Sync<Some<int>>>());
      expect(identical(wrapped.value.unwrap(), some), isTrue);
    });

    test('WrapOnOutcomeExt.wrapInAsync wraps the outcome in an Async', () async {
      const some = Some<int>(5);
      final wrapped = some.wrapInAsync();
      expect(wrapped, isA<Async<Some<int>>>());
      final settled = await wrapped.value;
      expect(identical(settled.unwrap(), some), isTrue);
    });

    test('WrapOnOutcomeExt.wrapValueInSome maps the value to Some(value)', () {
      const some = Some<int>(6);
      final wrapped = some.wrapValueInSome();
      expect(wrapped, isA<Outcome<Some<int>>>());
      final inner = wrapped.unwrap();
      expect(inner, isA<Some<int>>());
      expect(inner.value, 6);
    });

    test('WrapOnOutcomeExt.wrapValueInOk maps the value to Ok(value)', () {
      const some = Some<int>(7);
      final wrapped = some.wrapValueInOk();
      expect(wrapped, isA<Outcome<Ok<int>>>());
      final inner = wrapped.unwrap();
      expect(inner, isA<Ok<int>>());
      expect(inner.value, 7);
    });

    test('WrapOnOutcomeExt.wrapValueInResolvable maps the value to Sync.okValue(value)', () async {
      const some = Some<int>(8);
      final wrapped = some.wrapValueInResolvable();
      expect(wrapped, isA<Outcome<Resolvable<int>>>());
      final inner = wrapped.unwrap();
      expect(inner, isA<Resolvable<int>>());
      final settled = await inner.toAsync().value;
      expect(settled.unwrap(), 8);
    });

    test('WrapOnOutcomeExt.wrapValueInSync maps the value to Sync.okValue(value)', () {
      const some = Some<int>(9);
      final wrapped = some.wrapValueInSync();
      expect(wrapped, isA<Outcome<Sync<int>>>());
      final inner = wrapped.unwrap();
      expect(inner, isA<Sync<int>>());
      expect(inner.value.unwrap(), 9);
    });

    test('WrapOnOutcomeExt.wrapValueInAsync maps the value to Async.okValue(value)', () async {
      const some = Some<int>(10);
      final wrapped = some.wrapValueInAsync();
      expect(wrapped, isA<Outcome<Async<int>>>());
      final inner = wrapped.unwrap();
      expect(inner, isA<Async<int>>());
      final settled = await inner.value;
      expect(settled.unwrap(), 10);
    });

    // ─── WrapOnResolvableExt<T> ─────────────────────────────────────────────

    test('WrapOnResolvableExt.wrapValueInSome maps the resolved value to Some(value)', () async {
      final Resolvable<int> source = Sync<int>.okValue(11);
      final wrapped = source.wrapValueInSome();
      expect(wrapped, isA<Resolvable<Some<int>>>());
      final settled = await wrapped.toAsync().value;
      expect(settled.unwrap().value, 11);
    });

    test('WrapOnResolvableExt.wrapValueInOk maps the resolved value to Ok(value)', () async {
      final Resolvable<int> source = Sync<int>.okValue(12);
      final wrapped = source.wrapValueInOk();
      expect(wrapped, isA<Resolvable<Ok<int>>>());
      final settled = await wrapped.toAsync().value;
      expect(settled.unwrap().value, 12);
    });

    test('WrapOnResolvableExt.wrapValueInResolvable maps the resolved value to Sync.okValue(value)', () async {
      final Resolvable<int> source = Sync<int>.okValue(13);
      final wrapped = source.wrapValueInResolvable();
      expect(wrapped, isA<Resolvable<Resolvable<int>>>());
      final settled = await wrapped.toAsync().value;
      final inner = settled.unwrap();
      final innerSettled = await inner.toAsync().value;
      expect(innerSettled.unwrap(), 13);
    });

    test('WrapOnResolvableExt.wrapValueInSync maps the resolved value to Sync.okValue(value)', () async {
      final Resolvable<int> source = Sync<int>.okValue(14);
      final wrapped = source.wrapValueInSync();
      expect(wrapped, isA<Resolvable<Sync<int>>>());
      final settled = await wrapped.toAsync().value;
      expect(settled.unwrap().value.unwrap(), 14);
    });

    test('WrapOnResolvableExt.wrapValueInAsync maps the resolved value to Async.okValue(value)', () async {
      final Resolvable<int> source = Sync<int>.okValue(15);
      final wrapped = source.wrapValueInAsync();
      expect(wrapped, isA<Resolvable<Async<int>>>());
      final settled = await wrapped.toAsync().value;
      final inner = settled.unwrap();
      final innerSettled = await inner.value;
      expect(innerSettled.unwrap(), 15);
    });

    // ─── WrapOnSyncExt<T> ───────────────────────────────────────────────────

    test('WrapOnSyncExt.wrapValueInSome maps Sync value to Some', () {
      final source = Sync<int>.okValue(21);
      final wrapped = source.wrapValueInSome();
      expect(wrapped, isA<Sync<Some<int>>>());
      expect(wrapped.value.unwrap().value, 21);
    });

    test('WrapOnSyncExt.wrapValueInOk maps Sync value to Ok', () {
      final source = Sync<int>.okValue(22);
      final wrapped = source.wrapValueInOk();
      expect(wrapped, isA<Sync<Ok<int>>>());
      expect(wrapped.value.unwrap().value, 22);
    });

    test('WrapOnSyncExt.wrapValueInResolvable maps Sync value to Sync.okValue', () {
      final source = Sync<int>.okValue(23);
      final wrapped = source.wrapValueInResolvable();
      expect(wrapped, isA<Sync<Resolvable<int>>>());
      final inner = wrapped.value.unwrap();
      expect(inner, isA<Sync<int>>());
      expect((inner as Sync<int>).value.unwrap(), 23);
    });

    test('WrapOnSyncExt.wrapValueInSync maps Sync value to Sync.okValue', () {
      final source = Sync<int>.okValue(24);
      final wrapped = source.wrapValueInSync();
      expect(wrapped, isA<Sync<Sync<int>>>());
      expect(wrapped.value.unwrap().value.unwrap(), 24);
    });

    test('WrapOnSyncExt.wrapValueInAsync maps Sync value to Async.okValue', () async {
      final source = Sync<int>.okValue(25);
      final wrapped = source.wrapValueInAsync();
      expect(wrapped, isA<Sync<Async<int>>>());
      final inner = wrapped.value.unwrap();
      final settled = await inner.value;
      expect(settled.unwrap(), 25);
    });

    // ─── WrapOnAsyncExt<T> ──────────────────────────────────────────────────

    test('WrapOnAsyncExt.wrapValueInSome maps Async value to Some', () async {
      final source = Async<int>.okValue(31);
      final wrapped = source.wrapValueInSome();
      expect(wrapped, isA<Async<Some<int>>>());
      final settled = await wrapped.value;
      expect(settled.unwrap().value, 31);
    });

    test('WrapOnAsyncExt.wrapValueInOk maps Async value to Ok', () async {
      final source = Async<int>.okValue(32);
      final wrapped = source.wrapValueInOk();
      expect(wrapped, isA<Async<Ok<int>>>());
      final settled = await wrapped.value;
      expect(settled.unwrap().value, 32);
    });

    test('WrapOnAsyncExt.wrapValueInResolvable maps Async value to Sync.okValue', () async {
      final source = Async<int>.okValue(33);
      final wrapped = source.wrapValueInResolvable();
      expect(wrapped, isA<Async<Resolvable<int>>>());
      final settled = await wrapped.value;
      final inner = settled.unwrap();
      final innerSettled = await inner.toAsync().value;
      expect(innerSettled.unwrap(), 33);
    });

    test('WrapOnAsyncExt.wrapValueInSync maps Async value to Sync.okValue', () async {
      final source = Async<int>.okValue(34);
      final wrapped = source.wrapValueInSync();
      expect(wrapped, isA<Async<Sync<int>>>());
      final settled = await wrapped.value;
      expect(settled.unwrap().value.unwrap(), 34);
    });

    test('WrapOnAsyncExt.wrapValueInAsync maps Async value to Async.okValue', () async {
      final source = Async<int>.okValue(35);
      final wrapped = source.wrapValueInAsync();
      expect(wrapped, isA<Async<Async<int>>>());
      final settled = await wrapped.value;
      final inner = settled.unwrap();
      final innerSettled = await inner.value;
      expect(innerSettled.unwrap(), 35);
    });

    // ─── WrapOnOptionExt<T> ─────────────────────────────────────────────────

    test('WrapOnOptionExt.wrapValueInSome on Some maps to Some(Some(value))', () {
      final Option<int> source = const Some<int>(41);
      final wrapped = source.wrapValueInSome();
      expect(wrapped, isA<Option<Some<int>>>());
      expect(wrapped.unwrap().value, 41);
    });

    test('WrapOnOptionExt.wrapValueInSome on None stays None', () {
      final Option<int> source = const None<int>();
      final wrapped = source.wrapValueInSome();
      expect(wrapped, isA<None<Some<int>>>());
    });

    test('WrapOnOptionExt.wrapValueInOk on Some maps to Some(Ok(value))', () {
      final Option<int> source = const Some<int>(42);
      final wrapped = source.wrapValueInOk();
      expect(wrapped, isA<Option<Ok<int>>>());
      expect(wrapped.unwrap().value, 42);
    });

    test('WrapOnOptionExt.wrapValueInResolvable on Some maps to Some(Sync(value))', () {
      final Option<int> source = const Some<int>(43);
      final wrapped = source.wrapValueInResolvable();
      expect(wrapped, isA<Option<Resolvable<int>>>());
      final inner = wrapped.unwrap();
      expect(inner, isA<Sync<int>>());
    });

    test('WrapOnOptionExt.wrapValueInSync on Some maps to Some(Sync(value))', () {
      final Option<int> source = const Some<int>(44);
      final wrapped = source.wrapValueInSync();
      expect(wrapped, isA<Option<Sync<int>>>());
      expect(wrapped.unwrap().value.unwrap(), 44);
    });

    test('WrapOnOptionExt.wrapValueInAsync on Some maps to Some(Async(value))', () async {
      final Option<int> source = const Some<int>(45);
      final wrapped = source.wrapValueInAsync();
      expect(wrapped, isA<Option<Async<int>>>());
      final inner = wrapped.unwrap();
      final settled = await inner.value;
      expect(settled.unwrap(), 45);
    });

    // ─── WrapOnSomeExt<T> ───────────────────────────────────────────────────

    test('WrapOnSomeExt.wrapValueInSome maps to Some(Some(value))', () {
      const source = Some<int>(51);
      final wrapped = source.wrapValueInSome();
      expect(wrapped, isA<Some<Some<int>>>());
      expect(wrapped.value.value, 51);
    });

    test('WrapOnSomeExt.wrapValueInOk maps to Some(Ok(value))', () {
      const source = Some<int>(52);
      final wrapped = source.wrapValueInOk();
      expect(wrapped, isA<Some<Ok<int>>>());
      expect(wrapped.value.value, 52);
    });

    test('WrapOnSomeExt.wrapValueInResolvable maps to Some(Sync(value))', () {
      const source = Some<int>(53);
      final wrapped = source.wrapValueInResolvable();
      expect(wrapped, isA<Some<Resolvable<int>>>());
      expect(wrapped.value, isA<Sync<int>>());
    });

    test('WrapOnSomeExt.wrapValueInSync maps to Some(Sync(value))', () {
      const source = Some<int>(54);
      final wrapped = source.wrapValueInSync();
      expect(wrapped, isA<Some<Sync<int>>>());
      expect(wrapped.value.value.unwrap(), 54);
    });

    test('WrapOnSomeExt.wrapValueInAsync maps to Some(Async(value))', () async {
      const source = Some<int>(55);
      final wrapped = source.wrapValueInAsync();
      expect(wrapped, isA<Some<Async<int>>>());
      final settled = await wrapped.value.value;
      expect(settled.unwrap(), 55);
    });

    // ─── WrapOnNoneExt<T> ───────────────────────────────────────────────────

    test('WrapOnNoneExt.wrapValueInSome returns a None', () {
      const source = None<int>();
      final wrapped = source.wrapValueInSome();
      expect(wrapped, isA<None<Some<int>>>());
    });

    test('WrapOnNoneExt.wrapValueInOk returns a None', () {
      const source = None<int>();
      final wrapped = source.wrapValueInOk();
      expect(wrapped, isA<None<Ok<int>>>());
    });

    test('WrapOnNoneExt.wrapValueInResolvable returns a None', () {
      const source = None<int>();
      final wrapped = source.wrapValueInResolvable();
      expect(wrapped, isA<None<Resolvable<int>>>());
    });

    test('WrapOnNoneExt.wrapValueInSync returns a None', () {
      const source = None<int>();
      final wrapped = source.wrapValueInSync();
      expect(wrapped, isA<None<Sync<int>>>());
    });

    test('WrapOnNoneExt.wrapValueInAsync returns a None', () {
      const source = None<int>();
      final wrapped = source.wrapValueInAsync();
      expect(wrapped, isA<None<Async<int>>>());
    });

    // ─── WrapOnResultExt<T> ─────────────────────────────────────────────────

    test('WrapOnResultExt.wrapValueInSome on Ok maps to Ok(Some(value))', () {
      final Result<int> source = const Ok<int>(61);
      final wrapped = source.wrapValueInSome();
      expect(wrapped, isA<Result<Some<int>>>());
      expect(wrapped.unwrap().value, 61);
    });

    test('WrapOnResultExt.wrapValueInSome on Err preserves the Err', () {
      final Result<int> source = Err<int>('err-some');
      final wrapped = source.wrapValueInSome();
      expect(wrapped, isA<Err<Some<int>>>());
      expect((wrapped as Err).error, 'err-some');
    });

    test('WrapOnResultExt.wrapValueInOk on Ok maps to Ok(Ok(value))', () {
      final Result<int> source = const Ok<int>(62);
      final wrapped = source.wrapValueInOk();
      expect(wrapped, isA<Result<Ok<int>>>());
      expect(wrapped.unwrap().value, 62);
    });

    test('WrapOnResultExt.wrapValueInResolvable on Ok maps to Ok(Sync(value))', () {
      final Result<int> source = const Ok<int>(63);
      final wrapped = source.wrapValueInResolvable();
      expect(wrapped, isA<Result<Resolvable<int>>>());
      expect(wrapped.unwrap(), isA<Sync<int>>());
    });

    test('WrapOnResultExt.wrapValueInSync on Ok maps to Ok(Sync(value))', () {
      final Result<int> source = const Ok<int>(64);
      final wrapped = source.wrapValueInSync();
      expect(wrapped, isA<Result<Sync<int>>>());
      expect(wrapped.unwrap().value.unwrap(), 64);
    });

    test('WrapOnResultExt.wrapValueInAsync on Ok maps to Ok(Async(value))', () async {
      final Result<int> source = const Ok<int>(65);
      final wrapped = source.wrapValueInAsync();
      expect(wrapped, isA<Result<Async<int>>>());
      final inner = wrapped.unwrap();
      final settled = await inner.value;
      expect(settled.unwrap(), 65);
    });

    // ─── WrapOnOkExt<T> ─────────────────────────────────────────────────────

    test('WrapOnOkExt.wrapValueInSome maps to Ok(Some(value))', () {
      const source = Ok<int>(71);
      final wrapped = source.wrapValueInSome();
      expect(wrapped, isA<Result<Some<int>>>());
      expect(wrapped.unwrap().value, 71);
    });

    test('WrapOnOkExt.wrapValueInOk maps to Ok(Ok(value))', () {
      const source = Ok<int>(72);
      final wrapped = source.wrapValueInOk();
      expect(wrapped, isA<Result<Ok<int>>>());
      expect(wrapped.unwrap().value, 72);
    });

    test('WrapOnOkExt.wrapValueInResolvable maps to Ok(Sync(value))', () {
      const source = Ok<int>(73);
      final wrapped = source.wrapValueInResolvable();
      expect(wrapped, isA<Result<Resolvable<int>>>());
      expect(wrapped.unwrap(), isA<Sync<int>>());
    });

    test('WrapOnOkExt.wrapValueInSync maps to Ok(Sync(value))', () {
      const source = Ok<int>(74);
      final wrapped = source.wrapValueInSync();
      expect(wrapped, isA<Result<Sync<int>>>());
      expect(wrapped.unwrap().value.unwrap(), 74);
    });

    test('WrapOnOkExt.wrapValueInAsync maps to Ok(Async(value))', () async {
      const source = Ok<int>(75);
      final wrapped = source.wrapValueInAsync();
      expect(wrapped, isA<Result<Async<int>>>());
      final inner = wrapped.unwrap();
      final settled = await inner.value;
      expect(settled.unwrap(), 75);
    });

    // ─── WrapOnErrExt<T> ────────────────────────────────────────────────────

    test('WrapOnErrExt.wrapValueInSome returns an Err preserving the error', () {
      final source = Err<int>('e-some');
      final wrapped = source.wrapValueInSome();
      expect(wrapped, isA<Err<Some<int>>>());
      expect(wrapped.error, 'e-some');
    });

    test('WrapOnErrExt.wrapValueInOk returns an Err preserving the error', () {
      final source = Err<int>('e-ok');
      final wrapped = source.wrapValueInOk();
      expect(wrapped, isA<Err<Ok<int>>>());
      expect(wrapped.error, 'e-ok');
    });

    test('WrapOnErrExt.wrapValueInResolvable returns an Err preserving the error', () {
      final source = Err<int>('e-resolvable');
      final wrapped = source.wrapValueInResolvable();
      expect(wrapped, isA<Err<Resolvable<int>>>());
      expect(wrapped.error, 'e-resolvable');
    });

    test('WrapOnErrExt.wrapValueInSync returns an Err preserving the error', () {
      final source = Err<int>('e-sync');
      final wrapped = source.wrapValueInSync();
      expect(wrapped, isA<Err<Sync<int>>>());
      expect(wrapped.error, 'e-sync');
    });

    test('WrapOnErrExt.wrapValueInAsync returns an Err preserving the error', () {
      final source = Err<int>('e-async');
      final wrapped = source.wrapValueInAsync();
      expect(wrapped, isA<Err<Async<int>>>());
      expect(wrapped.error, 'e-async');
    });
  });
}
