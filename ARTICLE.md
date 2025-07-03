[![banner](https://github.com/dev-cetera/df_safer_dart/blob/main/doc/assets/banner.png?raw=true)](https://github.com/dev-cetera)

In software development, we spend an enormous amount of time writing defensive code. **We check for null, handle exceptions with try-catch, and manage asynchronous operations with async/await.** While these tools are essential, they often lead to code that is nested, verbose, and difficult to read. The core logic — the “happy path” — gets buried under layers of error handling.

What if there was a way to write clean, linear code that describes the happy path, while all the messy details of null values, failures, and asynchronicity are handled automatically in the background?

This is the promise of using **Outcomes**, a powerful concept from functional programming that you can use in Dart today to make your code dramatically more robust.

## What is an Outcome? (The Simple Explanation)
Forget complicated academic definitions. For our purposes, an outcome is just a **wrapper** or a **box** around a value.

This box has a superpower: it understands **context**.

- Is the value present or absent (null)?
- Was the computation to get this value successful, or did it fail?
- Is the value available now, or will it arrive in the future?

An outcome provides a simple, consistent API to chain operations together. The box itself manages the context. If something goes wrong — a value is missing or an operation fails — **the chain is automatically short-circuited, and the failure context is passed along instead.**

## The Three Core Outcomes You Need to Know

While you can build your own, a library like [df_safer_dart](https://pub.dev/packages/df_safer_dart) on pub.dev provides these outcome types out of the box, seamlessly linked and ready to use. Let’s explore the three fundamental types it offers.

### 1. The `Option` Outcome: Eliminating null and `if (x != null)`

The `Option` outcome tackles the problem of null. Instead of a value that can be `T` or `null`, an `Option` can be one of two things:

- `Some`: A box containing a value of type `T`.
- `None`: A box representing the absence of a value.

**Why is this better than null?** Because the type system forces you to deal with the absence. No more “**Error: Unexpected null value**” or **NoSuchMethodError**. You must open the box to get the value!

```dart
import 'package:df_safer_dart/df_safer_dart.dart';

// A function that might not find a user.
Option<String> findUsername(int id) {
  final users = {1: 'Alice', 2: 'Bob'};
  final username = users[id];
  // Option.from handles the null check for us.
  return Option.from(username);
}

// Chaining operations:
final result = findUsername(1) // This returns Some('Alice')
    .map((name) => name.toUpperCase()); // .map only runs if it's a Some

// Prints "Username is: ALICE"
switch (result) {
  case Some(value: final name):
    print('Username is: $name');
  case None():
    print('User not found.');
}
```

Notice how clean that is? No `if (user != null)` check. The `Option` box handles it.

### 2. The `Sync` and `Result` Outcomes: Eliminating try-catch

Operations that can fail, like parsing a number or decoding JSON, traditionally force us to write try-catch blocks. The outcome-based approach is to make failure a predictable, manageable value instead of an application-halting exception.

- A `Result` is a simple wrapper that is either `Ok` (success) or `Err` (failure).
- A `Sync` is a powerful constructor for a `Result`. It executes a synchronous function for you and automatically catches any exceptions, wrapping the outcome in a `Result`.

**Why is this better than try-catch?** It transforms unpredictable runtime exceptions into a predictable return value. Your function’s signature declares that it can fail, and the caller must handle that possibility. There are no hidden exceptions waiting to crash your program.

Let’s write a parsing function that is truly exception-free.

```dart
// A function that parses a string to an integer, with ZERO try-catch blocks.
// It returns a Sync, which holds a Result<int>.
Sync<int> parseInt(String value) {
  // The Sync outcome executes this function.
  // - If int.parse() succeeds, it returns Ok(result).
  // - If int.parse() throws a FormatException, Sync catches it and returns Err(exception).
  return Sync(() => int.parse(value));
}

final syncResult = parseInt('100') // This returns a Sync<int> holding an Ok(100)
    .map((number) => number * 2); // .map only runs on the Ok value

final result1 = syncResult.value; // This returns a Result<int>

switch (result1) {
  case Ok(value: final number):
    print('Result: $number');
  case Err err:
    print('Failed to parse');
}

final result2 = parseInt('Hello!').map((number) => number * 2).value;

switch (result2) {
  case Ok(value: final number):
    print('Result: $number');
  case Err err:
    print('Failed to parse: ${result2.error}');
}
```
```sh
Result: 200
Failed to parse: FormatException: Invalid radix-10 number (at character 1)
Hello!
^
```

### 3. The `Async` Outcome: Taming Asynchronous Failures

An `Async` outcome combines the concepts of `Future` and `Result`. It’s a box that represents a value that will resolve in the future to either an `Ok` or an `Err`. It’s the ultimate tool for robust asynchronous pipelines, as it handles both network/IO exceptions and logical failures.

## The Big Payoff: Building an Unbreakable Pipeline

Let’s put it all together. Imagine a common real-world scenario:

For a given user ID, fetch the user’s configuration data from an API, parse it as JSON, and then safely extract a deeply nested, optional setting: `config.notifications.sound`.

This process can fail at every single step:

- The network request to fetch `userData` could fail (no internet, 404, etc.).
- The response body might not be valid JSON.
- The JSON might be valid, but the `config` key could be missing.
- The `notifications` key could be missing.
- The `sound` key could be missing.

Here’s how you’d build this logic robustly with outcomes from the [df_safer_dart](https://pub.dev/packages/df_safer_dart) package.

### Step 1: Define the failable operations using outcomes
We wrap our primitive operations, letting the outcome types handle the error context.

```dart
import 'package:df_safer_dart/df_safer_dart.dart';
import 'dart:convert';

// A network call that can fail. Async handles both success and exceptions.
Async<String> fetchUserData(int userId) => Async(() async {
  await Future.delayed(const Duration(milliseconds: 10)); // Simulate network latency
  if (userId == 1) return '{"config":{"notifications":{"sound":"chime.mp3"}}}';
  if (userId == 2) return '{"config":{}}';
  if (userId == 3) return '{"config": "bad_data"}';
  throw Exception('User Not Found'); // This will be caught by Async and become an Err
});

// A parser that can fail. Sync automatically catches the jsonDecode exception.
Sync<Map<String, dynamic>> parseJson(String json) => Sync(() => jsonDecode(json));

// A helper to safely extract a typed value. It cannot fail, it can only be absent,
// so it returns an Option.
Option<T> getFromMap<T extends Object>(Map map, String key) {
  final value = map[key];
  return letAsOrNone<T>(value); // A safe-cast helper from the library
}
```

### Step 2: Chain them together into a beautiful, linear flow
Now we compose these functions. We’ll use `.map()` to chain operations. If any step produces an `Err`, all subsequent `.map()` calls in the chain are automatically skipped.

```dart
/// This is the logic pipeline. It reads like a description of the happy path.
/// There are no try-catch blocks and no null checks.
Async<Option<String>> getUserNotificationSound(int userId) {
  return fetchUserData(userId) // Starts with Async<String>
      .map(
        // The .unwrap() here will throw if parseJson created an Err.
        // The Async outcome's .map will catch that throw and turn the
        // whole chain into an Err state.
        (jsonString) => UNSAFE(() => parseJson(jsonString).unwrap()),
      )
      .map(
        // This .map only runs if fetching and parsing were successful.
        (data) =>
            // Start the Option chain to safely drill into the data.
            // .flatMap is used to chain functions that return another Option.
            getFromMap<Map>(data, 'config')
                .flatMap((config) => getFromMap<Map>(config, 'notifications'))
                .flatMap((notifications) => getFromMap<String>(notifications, 'sound')),
      );
}
```

### Step 3: Execute and handle the final result

Finally, we run our pipeline and use `switch` to handle the final outcome in a type-safe way.

```dart
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
          print('  -> Success: Sound setting is $sound\n');
        case None():
          print('  -> Success: Sound setting was not specified.\n');
      }
    case Err err:
      // The entire pipeline failed at some point.
      print('  -> Failure: An error occurred: ${finalResult.error}\n');
  }
}
```
```sh
Processing User ID: 1
  -> Success: Sound setting is chime.mp3

Processing User ID: 2
  -> Success: Sound setting was not specified.

Processing User ID: 3
  -> Success: Sound setting was not specified.

Processing User ID: 4
  -> Failure: An error occurred: Exception: User Not Found

Processing User ID: 5
  -> Failure: An error occurred: Exception: User Not Found
```

This is the power of outcome-based design in Dart. The `getUserNotificationSound` function is a clean, declarative, and robust description of a complex operation. Every potential point of failure is handled gracefully and implicitly by the outcome wrappers. You write the code for the ideal scenario, and the outcomes take care of the messy reality.

## Why You Should Use This Pattern

1. **Eliminates Error-Prone Boilerplate:** You no longer write `if (x != null)` or `try-catch`. This removes entire classes of common bugs.
2. **Explicitness and Predictability:** Failures are not hidden exceptions; they are predictable values encoded in the type system. You are forced to handle them.
3. **Composability:** You build complex operations from small, simple, and independently testable functions.
4. **Readability:** Your code describes what you want to achieve (the happy path), not the low-level mechanics of how you’re avoiding crashes.
5. **Unbreakable Core Logic:** For the critical parts of your application, this pattern creates pipelines that don’t just handle errors — they are fundamentally designed around them, making them resilient by construction.

To get started with these powerful patterns in your own Dart or Flutter projects, check out the [df_safer_dart](https://pub.dev/packages/df_safer_dart) package on pub.dev.