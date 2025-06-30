import 'package:df_safer_dart/df_safer_dart.dart';
import 'dart:convert';

typedef KeyValueMap = Map<String, dynamic>;

// A network call that can fail. Async handles both success and exceptions.
Async<String> fetchUserData(int userId) => Async(() async {
  await Future<void>.delayed(
    const Duration(milliseconds: 10),
  ); // Simulate network latency
  if (userId == 1) {
    return '{"config":{"notifications":{"sound":"chime.mp3"}}}';
  }
  if (userId == 2) {
    return '{"config":{}}';
  }
  if (userId == 3) {
    return '{"config": "bad_data"}';
  }
  throw Exception(
    'User Not Found',
  ); // This will be caught by Async and become an Err
});

// A parser that can fail. Sync automatically catches the jsonDecode exception.
Sync<KeyValueMap> parseJson(String json) =>
    Sync(() => jsonDecode(json) as KeyValueMap);

// A helper to safely extract a typed value. It cannot fail, it can only be absent,
// so it returns an Option.
Option<T> getFromMap<T extends Object>(KeyValueMap map, String key) {
  final value = map[key];
  return letAsOrNone<T>(value); // A safe-cast helper from the library
}

/// This is the logic pipeline. It reads like a description of the happy path.
/// There are no try-catch blocks and no null checks.
Async<Option<String>> getUserNotificationSound(int userId) {
  return fetchUserData(userId) // Starts with Async<String>
      .map(
        // The .unwrap() here will throw if parseJson created an Err.
        // The Async monad's .map will catch that throw and turn the
        // whole chain into an Err state.
        (jsonString) => parseJson(jsonString).unwrap(),
      )
      .map(
        // This .map only runs if fetching and parsing were successful.
        (data) =>
            // Start the Option chain to safely drill into the data.
            // .flatMap is used to chain functions that return another Option.
            getFromMap<KeyValueMap>(data, 'config')
                .flatMap(
                  (config) => getFromMap<KeyValueMap>(config, 'notifications'),
                )
                .flatMap(
                  (notifications) => getFromMap<String>(notifications, 'sound'),
                ),
      );
}

void main() async {
  for (var id in [1, 2, 3, 4, 5]) {
    print('Processing User ID: $id');

    // Execute the pipeline. `await value` opens the Async box.
    final finalResult = await getUserNotificationSound(id).value;

    switch (finalResult) {
      case Ok(value: final optionSound):
        switch (optionSound) {
          // Success! The value is an Option<String>.
          // Now open the Option box.
          case Some(value: final sound):
            print('  -> Success: Sound setting is "$sound"\n');
          case None():
            print('  -> Success: Sound setting was not specified.\n');
        }
      case Err err:
        // The entire pipeline failed at some point.
        print('  -> Failure: An error occurred: ${err.error}\n');
    }
  }
}
