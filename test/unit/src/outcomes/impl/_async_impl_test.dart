import 'package:df_safer_dart/df_safer_dart.dart';
import 'package:test/test.dart';

void main() {
  group('_async_impl', () {
    test('Async implements AsyncImpl<T>', () {
      final async = Async<int>.okValue(1);
      expect(async, isA<AsyncImpl<int>>());
    });

    test('AsyncImpl.value is a Future<Object>', () async {
      final AsyncImpl<int> impl = Async<int>.okValue(42);
      final raw = impl.value;
      expect(raw, isA<Future<Object>>());
      final resolved = await raw;
      expect(resolved, isA<Ok<int>>());
      expect((resolved as Ok).value, 42);
    });

    test('AsyncImpl.value resolves to an Err when the chain failed', () async {
      final AsyncImpl<int> impl =
          Async<int>.errValue((error: 'bad', statusCode: null));
      final resolved = await impl.value;
      expect(resolved, isA<Err>());
      expect((resolved as Err).error, 'bad');
    });

    test('Sync does NOT implement AsyncImpl', () {
      final sync = Sync<int>.okValue(1);
      expect(sync is AsyncImpl, isFalse);
    });

    test('None, Some, Ok and Err do NOT implement AsyncImpl', () {
      expect(const Some<int>(1) is AsyncImpl, isFalse);
      expect(const None<int>() is AsyncImpl, isFalse);
      expect(const Ok<int>(1) is AsyncImpl, isFalse);
      expect(Err<int>('e') is AsyncImpl, isFalse);
    });

    test('private impl — covered transitively via Async round-trip', () async {
      final async = Async<int>.okValue(3).map((v) => v + 1).map((v) => v * 2);
      expect(async, isA<AsyncImpl<int>>());
      expect(await async.unwrap(), 8);
    });
  });
}
