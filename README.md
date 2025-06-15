<a href="https://www.buymeacoffee.com/dev_cetera" target="_blank"><img align="right" src="https://cdn.buymeacoffee.com/buttons/default-orange.png" height="48"></a>
<a href="https://discord.gg/gEQ8y2nfyX" target="_blank"><img align="right" src="https://raw.githubusercontent.com/dev-cetera/resources/refs/heads/main/assets/discord_icon/discord_icon.svg" height="48"></a>

Dart & Flutter Packages by dev-cetera.com & contributors.

[![Pub Package](https://img.shields.io/pub/v/df_safer_dart.svg)](https://pub.dev/packages/df_safer_dart)
[![MIT License](https://img.shields.io/badge/License-MIT-blue.svg)](https://raw.githubusercontent.com/dev-cetera/df_safer_dart/main/LICENSE)

---

## Read this Article on Medium.com

[An Introduction to Monads in Dart: Building Unbreakable Code](https://medium.com/@dev-cetera/an-introduction-to-monads-in-dart-building-unbreakable-code-8909705a2451)

## Summary

This package, inspired by [Rust](<https://en.wikipedia.org/wiki/Rust_(programming_language)>) and [functional programming](https://en.wikipedia.org/wiki/Functional_programming), aims to enhance the structure, safety and debuggability of your applications by leveraging [monads](<https://en.wikipedia.org/wiki/Monad_(functional_programming)>) and other advanced mechanisms.

Dart’s traditional error-handling approach depends on null checks, try-catch blocks, and Futures that can throw errors at any time, necessitating asynchronous error handling. This often leads to complex and unpredictable error management.

Aiming to address these challenges, this package offers safer alternatives and more predictable mechanisms.

While it introduces some boilerplate and incurs a minor performance trade-off due to safety checks, it is best suited for mission critical sections of your project where reliability and safety are essential. For less sensitive code, standard approaches like Future, FutureOr, try-catch, and nullable types may be more appropriate.

This package introduces three core monads (`Result`, `Option`, and `Resolvable`) that work seamlessly together:

- `Result<T>`: Represents the outcome of an operation that can fail. It will either be:

  - `Ok<T>`: A success value of type T.
  - `Err<T>`: A failure value containing details about the error.

`Result` eliminates the need for try-catch blocks by making failure an explicit and manageable part of the type system.

- `Option<T>`: Represents a value that may or may not be present. It will either be:

  - `Some<T>`: A present value of type T.
  - `None<T>`: The absence of a value.

`Option` eliminates null values and forces the developer to explicitly handle the "absent" case, preventing NullPointerExceptions.

- `Resolvable<T>`: A powerful wrapper that unifies synchronous and asynchronous operations. It will either be:

  - `Sync<T>`: For immediate, failable operations.
  - `Async<T>`: For time-based, failable operations.

`Resolvable` provides a consistent API for chaining operations, regardless of whether they are synchronous or asynchronous.

These monads form the foundation for more predictable, expressive, and maintainable error handling in Dart.

Additionally, the package includes two complementary mechanisms:

- `SafeCompleter<T>`: A safer, more powerful alternative to Dart’s Completer. It allows you to resolve a value (or an error) from any context (synchronous or asynchronous) and provides a `Resolvable<T>` to listen for the result, maintaining type safety throughout.

- `SafeSequential`: A utility for executing a series of failable, synchronous, or asynchronous operations in a guaranteed sequential order. It simplifies the management of complex workflows and provides an alternative to patterns like Future.wait while staying entirely within the monadic world.

With these tools, the package provides a solid framework for improving the reliability and readability of your Dart applications.

For a full feature set, please refer to the [API reference](https://pub.dev/documentation/df_safer_dart/).

## How We Avoid `null`

Instead of returning `null` when a value might be absent (e.g., a missing key in a map, an empty list), you return an `Option`.

- `Some(value)`: If the value is present.
- `None()`: If the value is absent.

The type system then forces you to handle both cases using methods like `.match()` or `.flatMap()`, making it impossible to accidentally use a `null` value.

## How We Avoid Direct `Future`

A standard `Future` in Dart can complete with a value or an error. Handling this often requires `await` inside a `try-catch` block. The `Async` monad improves upon this:

- It encapsulates a `Future`.
- It automatically catches any error the `Future` might throw and converts it into an `Err` state.
- It allows you to chain subsequent operations using `.map()` without needing to `await` at each step.

This creates clean, linear "pipelines" of asynchronous logic, where you only handle the final `Result` at the very end, rather than managing errors at every step.

## The Rules of `Async`

- **ALWAYS `await` inside the `Async` closure**: When you provide a function to the `Async` constructor, you must `await` any `Future` inside it. This is crucial for the `Async` monad to be able to catch the error if the `Future` fails.
- **NEVER `await` the `Async` monad itself**: The point is to chain operations using `.map()`. You should only "exit" the monad (e.g., by accessing `.value`) at the end of your program or function.

We definitely need a linter for this!

## Usage Example

Example of avoiding try-catch blocks in Dart, to produce safer code:

```dart
void main() async {
  // Fetch the IP address and handle both success and error results.
  fetchIpAddress().match((result) {
    print('IP address: $result');
    return NONE; // Returning `null` is deliberately not supported!
  }, (err) {
    print(err);
    return NONE;
  });
}

Async<String> fetchIpAddress() {
  // Async, Sync or Resolvable can be used to wrap
  // potentially throwing code.
  //
  // The only rules here are:
  //
  // 1. ALWAYS await all asynchronous operations inside Async
  // (or Resolvable) to ensure that exceptions are properly caught and
  // wrapped in a Result.
  //
  // 2. Only deal with asynchronous operations in Async or
  // Resolvable. Not in Sync.
  //
  // 3. You can throw any Objects within the closure, but prefer
  // throwing Err objects as it is the standard and will help
  // with debugging. You can also wrap any of your exceptions
  // with Err.
  return Async(() async {
    final response = await http.get(
      Uri.parse('https://api.ipify.org?format=json'),
    );
    // Throw an Err if the status code is not 200. Any other exceptions within
    // Resolvable.wrap will be caught and wrapped in an Err.
    if (response.statusCode != 200) {
      throw Err('Failed to fetch IP address');
    }
    final data = jsonDecode(response.body);
    final ip = data['ip'] as String;
    return ip;
  });
}
```

---

## Contributing and Discussions

This is an open-source project, and we warmly welcome contributions from everyone, regardless of experience level. Whether you're a seasoned developer or just starting out, contributing to this project is a fantastic way to learn, share your knowledge, and make a meaningful impact on the community.

### Ways you can contribute

- **Buy me a coffee:** If you'd like to support the project financially, consider [buying me a coffee](https://www.buymeacoffee.com/dev_cetera). Your support helps cover the costs of development and keeps the project growing.
- **Find us on Discord:** Feel free to ask questions and engage with the community here: https://discord.gg/gEQ8y2nfyX.
- **Share your ideas:** Every perspective matters, and your ideas can spark innovation.
- **Help others:** Engage with other users by offering advice, solutions, or troubleshooting assistance.
- **Report bugs:** Help us identify and fix issues to make the project more robust.
- **Suggest improvements or new features:** Your ideas can help shape the future of the project.
- **Help clarify documentation:** Good documentation is key to accessibility. You can make it easier for others to get started by improving or expanding our documentation.
- **Write articles:** Share your knowledge by writing tutorials, guides, or blog posts about your experiences with the project. It's a great way to contribute and help others learn.

No matter how you choose to contribute, your involvement is greatly appreciated and valued!

### We drink a lot of coffee...

If you're enjoying this package and find it valuable, consider showing your appreciation with a small donation. Every bit helps in supporting future development. You can donate here: https://www.buymeacoffee.com/dev_cetera

<a href="https://www.buymeacoffee.com/dev_cetera" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/default-orange.png" height="40"></a>

## License

This project is released under the MIT License. See [LICENSE](https://raw.githubusercontent.com/dev-cetera/df_safer_dart/main/LICENSE) for more information.
