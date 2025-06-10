// ignore_for_file: inference_failure_on_instance_creation, strict_raw_type

import 'package:df_safer_dart/df_safer_dart.dart';

// -----------------------------------------------------------------------------
// THE SCENARIO: A REAL-WORLD PROBLEM
// -----------------------------------------------------------------------------
//
// We need to process a series of user IDs, and for each one, fetch its config,
// parse the JSON, and extract a deeply nested, optional setting:
// `config.notifications.sound`.
//
// This demonstrates how to handle a sequence of fully independent, asynchronous,
// failable pipelines in a purely monadic way, without `await`, `try-catch`,
// `null`, or even `Future`.

// -----------------------------------------------------------------------------
// THE MONADIC PIPELINE
// -----------------------------------------------------------------------------

/// This is the logic pipeline for a single user. It reads like a description of
/// the "happy path," while all potential errors and absent values are handled
/// automatically by the monads.
///
/// It returns an `Async` monad, which encapsulates the entire asynchronous flow.
Async<Option<String>> getUserNotificationSound(int userId) {
  return fetchUserData(userId)
      // 1. `map` chains the next operation. If `fetchUserData` produced an `Err`,
      //    this entire block is skipped, propagating the `Err` state.
      .map(
        // 2. We `unwrap` the synchronous `parseJson` result. If parsing
        //    fails, `unwrap` throws, which the `Async` monad immediately
        //    catches and converts into a failed result for the whole chain.
        (json) => parseJson(json).unwrap(),
      )
      // 3. This is the key monadic pattern for safely accessing nested data.
      .map(
        (data) =>
            // a. Start with the top-level data as `Some`.
            Some(data)
                // b. `flatMap` safely accesses the `config` key.
                //    If `config` is missing or not a Map, `letAsOrNone`
                //    returns `None`, and the rest of the chain is skipped.
                .flatMap((d) => letAsOrNone<Map>(d['config']))
                // c. Chain another `flatMap` to access `notifications`.
                .flatMap((config) => letAsOrNone<Map>(config['notifications']))
                // d. Finally, access `sound`.
                .flatMap(
                  (notifications) =>
                      letAsOrNone<String>(notifications['sound']),
                ),
      );
}

/// Async - Use Case: An operation over time that might fail.
Async<String> fetchUserData(int userId) => Async(() async {
  await Future.delayed(const Duration(milliseconds: 10));
  if (userId == 1) return '{"config":{"notifications":{"sound":"chime.mp3"}}}';
  if (userId == 2) return '{"config":{"notifications":{}}}';
  if (userId == 3) return '{"config":{}}';
  if (userId == 4) return '{"config": "bad_data"}';
  throw Err('User Not Found');
});

/// Sync - Use Case: An immediate operation that might fail (e.g., parsing).
Sync<Map<String, dynamic>> parseJson(String json) =>
    Sync(() => json.decodeJson<Map<String, dynamic>>().unwrap());

// -----------------------------------------------------------------------------
// MAIN EXECUTION (The Pure Monadic Way with `Sequential`)
// -----------------------------------------------------------------------------

void main() {
  print('--- Monadic Pipeline Results using Sequential ---');

  // `Sequential` is the library's tool for managing a series of monadic
  // operations without ever exposing a `Future`.
  final processor = Sequential();
  final userIds = [1, 2, 3, 4, 5];

  // We add each user's processing pipeline to the sequential queue.
  // The `_` in `add((_) => ...)` indicates we don't care about the result
  // of the *previous* operation in the queue, as our tasks are independent.
  for (final id in userIds) {
    processor.add((_) {
      // 1. Run the main pipeline for the current user ID.
      return getUserNotificationSound(id)
          // 2. Chain a final `map` to format the result for display.
          //    This map only runs if the pipeline was successful.
          .map((option) => formatResult(Ok(option)))
          // 3. Use `match` to handle the final `Result` (Ok or Err).
          //    This is the final "exit" from the monad for this one operation.
          .match(
            (successString) {
              print('User $id -> $successString');
              return NONE;
            },
            (err) {
              print('User $id -> ${formatResult(err.transf())}');
              return NONE;
            },
          );
    });
  }
}

/// Helper to safely format the final `Result<Option<String>>`.
String formatResult(Result<Option<String>> result) {
  return result.match(
    (option) => option.match(
      (sound) => '${option.runtimeType}: $sound',
      () => option.runtimeType.toString(),
    ),
    (err) => err.toString(),
  );
}
