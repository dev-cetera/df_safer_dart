import 'dart:async';

import 'package:df_safer_dart/df_safer_dart.dart';
import 'package:test/test.dart';

void main() {
  group('to_safe_stream_ext', () {
    test('data events are wrapped in Ok', () async {
      final controller = StreamController<int>();
      final events = <Result<int>>[];
      final sub = controller.stream
          .toSafeStream(cancelOnError: false)
          .listen(events.add);
      controller.add(1);
      controller.add(2);
      controller.add(3);
      await controller.close();
      await sub.cancel();
      expect(events, hasLength(3));
      expect(events.every((e) => e is Ok<int>), isTrue);
      expect(events.map((e) => e.unwrap()).toList(), [1, 2, 3]);
    });

    test('error events become Err and do not kill the stream', () async {
      final controller = StreamController<int>();
      final events = <Result<int>>[];
      final sub = controller.stream
          .toSafeStream(cancelOnError: false)
          .listen(events.add);
      controller.add(1);
      controller.addError(StateError('boom'));
      controller.add(2);
      await controller.close();
      await sub.cancel();
      expect(events, hasLength(3));
      expect(events[0], isA<Ok<int>>());
      expect(events[1], isA<Err<int>>());
      expect(events[2], isA<Ok<int>>());
      expect((events[0] as Ok<int>).value, 1);
      expect((events[2] as Ok<int>).value, 2);
    });

    test(
      'cancelOnError: true closes the safe stream after the first error',
      () async {
        final controller = StreamController<int>();
        final events = <Result<int>>[];
        var done = false;
        final sub = controller.stream
            .toSafeStream(cancelOnError: true)
            .listen(events.add, onDone: () => done = true);
        controller.add(1);
        controller.addError(StateError('boom'));
        // Give the transformer a turn to process the error + close the sink.
        await Future<void>.delayed(Duration.zero);
        controller.add(2); // Should not reach the listener.
        await controller.close();
        await sub.cancel();
        expect(done, isTrue);
        expect(events, hasLength(2));
        expect(events[0], isA<Ok<int>>());
        expect(events[1], isA<Err<int>>());
      },
    );

    test('an upstream Err thrown as a stream error is preserved', () async {
      final controller = StreamController<int>();
      final events = <Result<int>>[];
      final sub = controller.stream
          .toSafeStream(cancelOnError: false)
          .listen(events.add);
      final originalErr = Err<int>('upstream', statusCode: 418);
      controller.addError(originalErr);
      await controller.close();
      await sub.cancel();
      expect(events, hasLength(1));
      final err = events.single;
      expect(err, isA<Err<int>>());
      expect((err as Err<int>).error, 'upstream');
      expect(err.statusCode.unwrap(), 418);
    });

    test('done event closes the safe stream', () async {
      final controller = StreamController<int>();
      var done = false;
      final sub = controller.stream
          .toSafeStream(cancelOnError: false)
          .listen((_) {}, onDone: () => done = true);
      await controller.close();
      await sub.cancel();
      expect(done, isTrue);
    });
  });
}
