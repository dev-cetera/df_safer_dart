import 'package:df_safer_dart/df_safer_dart.dart';
import 'package:test/test.dart';

void main() {
  group('_sync_impl', () {
    test('Sync implements SyncImpl<T>', () {
      final sync = Sync<int>.okValue(1);
      expect(sync, isA<SyncImpl<int>>());
    });

    test('Some implements SyncImpl<T>', () {
      const some = Some<int>(1);
      expect(some, isA<SyncImpl<int>>());
    });

    test('None implements SyncImpl<T>', () {
      const none = None<int>();
      expect(none, isA<SyncImpl<int>>());
    });

    test('Ok implements SyncImpl<T>', () {
      const ok = Ok<int>(1);
      expect(ok, isA<SyncImpl<int>>());
    });

    test('Err implements SyncImpl<T>', () {
      final err = Err<int>('e');
      expect(err, isA<SyncImpl<int>>());
    });

    test('SyncImpl.value is a non-Future Object for every implementor', () {
      final implementors = <SyncImpl<Object>>[
        Sync<int>.okValue(42),
        const Some<int>(5),
        const None<int>(),
        const Ok<int>(7),
        Err<int>('e'),
      ];
      for (final impl in implementors) {
        expect(impl.value, isNotNull);
        expect(impl.value, isNot(isA<Future<Object>>()));
      }
    });

    test('Async does NOT implement SyncImpl', () {
      final async = Async<int>.okValue(1);
      expect(async is SyncImpl, isFalse);
    });

    test('private impl — covered transitively via Sync round-trip', () {
      final sync = Sync<int>.okValue(3)
          .map((v) => v + 1)
          .map((v) => v * 2);
      expect(sync, isA<SyncImpl<int>>());
      expect(sync.unwrap(), 8);
    });
  });
}
