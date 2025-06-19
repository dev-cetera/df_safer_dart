// --- AI GENERATED TEST ---

import 'package:test/test.dart';
import 'package:df_safer_dart/df_safer_dart.dart';

void main() {
  UNSAFE:
  {
    group('SafeCompleter Tests', () {
      test('should complete successfully with a synchronous value', () async {
        // Arrange
        final completer = SafeCompleter<int>();
        expect(
          completer.isCompleted,
          isFalse,
          reason: 'Completer should not be completed initially',
        );

        // Act
        completer.complete(42).end();

        // Assert
        expect(
          completer.isCompleted,
          isTrue,
          reason: 'Completer should be marked as completed',
        );
        final result = await completer.resolvable().value;
        expect(result, isA<Ok<int>>());
        expect(result.unwrap(), 42);
      });

      // THIS IS THE CORRECTED TEST
      test('should complete successfully with an asynchronous value', () async {
        // Arrange
        final completer = SafeCompleter<String>();
        final futureValue = Future.delayed(
          const Duration(milliseconds: 20),
          () => 'hello world',
        );

        // Act
        completer.complete(futureValue).end();

        // Assert: The completer is NOT yet complete because the future is still running.
        expect(
          completer.isCompleted,
          isFalse,
          reason: 'Completer is not completed until the future resolves',
        );

        // Await for the resolvable to finish, which internally completes the future.
        final result = await completer.resolvable().value;

        // Assert: NOW the completer should be marked as completed.
        expect(
          completer.isCompleted,
          isTrue,
          reason: 'Completer should be completed after awaiting the result',
        );
        expect(result, isA<Ok<String>>());
        expect(result.unwrap(), 'hello world');
      });

      test(
        'should complete with an error when resolve() is called with an Err',
        () async {
          // Arrange
          final completer = SafeCompleter<int>();
          final error = Err<int>('A deliberate test error');

          // Act
          completer.resolve(Sync.value(error)).end();

          // Assert
          expect(completer.isCompleted, isTrue);
          final resolvable = completer.resolvable();

          // Check that the resolvable completes with an error
          await expectLater(resolvable.value, completion(isA<Err>()));

          final result = await resolvable.value;
          expect((result as Err).error, 'A deliberate test error');
        },
      );

      // THIS IS THE CORRECTED TEST
      test('should complete with an error from a failing future', () async {
        // Arrange
        final completer = SafeCompleter<double>();
        final failingFuture = Future<double>.delayed(
          const Duration(milliseconds: 20),
          () => throw Exception('Network Failure'),
        );

        // Act
        completer.complete(failingFuture).end();

        // Assert: Not yet completed.
        expect(completer.isCompleted, isFalse);

        // Await the resolution.
        final resolvable = completer.resolvable();
        await expectLater(resolvable.value, completion(isA<Err>()));

        // Assert: Now it is completed (with an error).
        expect(completer.isCompleted, isTrue);

        final result = await resolvable.value;
        expect((result as Err).error, isA<Exception>());
        expect(
          (result.err().unwrap() as Exception).toString(),
          'Exception: Network Failure',
        );
      });

      test(
        'should prevent double completion and return an Err on the second attempt',
        () async {
          // Arrange
          final completer = SafeCompleter<String>();

          // Act: First, successful completion
          completer.complete('first value').end();
          expect(completer.isCompleted, isTrue);

          // Act: Second, failing completion attempt
          final secondAttemptResult = completer.complete('second value');

          // Assert
          expect(secondAttemptResult, isA<Sync<String>>());
          final result = secondAttemptResult.sync().unwrap().value;

          expect(
            result,
            isA<Err>(),
            reason: 'Second completion should result in an Err',
          );
          expect(
            (result as Err).error,
            'SafeCompleter<String> is already completed!',
          );

          // Verify that the original value remains unchanged
          final originalValue = await completer.resolvable().unwrap();
          expect(originalValue, 'first value');
        },
      );

      test(
        'should transform a successful value correctly using transf()',
        () async {
          // Arrange
          final intCompleter = SafeCompleter<int>();
          final stringCompleter = intCompleter.transf<String>(
            (i) => 'Value is $i',
          );

          // Act
          intCompleter.complete(123).end();

          // Assert
          final result = await stringCompleter.resolvable().value;
          expect(result, isA<Ok<String>>());
          expect(result.unwrap(), 'Value is 123');
        },
      );

      test(
        'should complete with an error if transf() causes a type cast failure',
        () async {
          // Arrange
          final intCompleter = SafeCompleter<int>();
          // Attempt to transform an int to a double without a converter function, which fails the `as` cast.
          final doubleCompleter = intCompleter.transf<double>();

          // Act
          intCompleter.complete(42).end();

          // Assert
          final result = await doubleCompleter.resolvable().value;
          expect(result, isA<Err>());
          expect(
            (result as Err).error,
            'Failed to transform type int to double.',
          );
        },
      );
    });
  }
}
