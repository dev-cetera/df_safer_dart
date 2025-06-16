<a href="https://www.buymeacoffee.com/dev_cetera" target="_blank"><img align="right" src="https://cdn.buymeacoffee.com/buttons/default-orange.png" height="48"></a>
<a href="https://discord.gg/gEQ8y2nfyX" target="_blank"><img align="right" src="https://raw.githubusercontent.com/dev-cetera/resources/refs/heads/main/assets/discord_icon/discord_icon.svg" height="48"></a>

Dart & Flutter Packages by dev-cetera.com & contributors.

[![Pub Package](https://img.shields.io/pub/v/df_safer_dart.svg)](https://pub.dev/packages/df_safer_dart)
[![MIT License](https://img.shields.io/badge/License-MIT-blue.svg)](https://raw.githubusercontent.com/dev-cetera/df_safer_dart/main/LICENSE)

---



## Write Unbreakable Code in Dart

In software development, we spend an enormous amount of time writing defensive code. We check for null, handle exceptions with try-catch, and manage asynchronous operations with async/await. While essential, these tools often lead to code that is nested, verbose, and difficult to read. The core logic — the “happy path” — gets buried under layers of error handling.

`df_safer_dart` offers a different approach.

It provides a set of tools inspired by functional programming that allow you to write clean, linear code describing the happy path, while all the messy details of null values, failures, and asynchronicity are handled automatically and safely in the background. This package introduces three core monadic types (`Option`, `Result`, and `Resolvable`) that work seamlessly together to make your code dramatically more robust and readable.

## The Philosophy: Compile-Time Safety First

Many libraries provide tools for safety, but they still allow developers to make mistakes that only appear at runtime. `df_safer_dart` is different. It is designed to be a paternalistic library that actively guides you towards correct usage and flags incorrect patterns at compile time.

- **No More Runtime Future Surprises:** Using a Future in a synchronous context is a compile-time error.
- **Guaranteed await:** Forgetting to await inside an Async block is a compile-time error.
- **Automatic Exception Handling:** You can't forget a try-catch block, because the library's core constructors handle it for you.

This philosophy is enforced by a companion linter package, which is a required part of the setup.

## Getting Started (1/2): The Core Concepts

For an introduction, please refer to this article:

- **MEDIUM.COM** [An Introduction to Monads in Dart: Building Unbreakable Code](https://medium.com/@dev-cetera/an-introduction-to-monads-in-dart-building-unbreakable-code-8909705a245)
- **DEV.TO** [An Introduction to Monads in Dart: Building Unbreakable Code](https://dev.to/dev_cetera/an-introduction-to-monads-in-dart-building-unbreakable-code-4766)

For a full feature set, please refer to the [API reference](https://pub.dev/documentation/df_safer_dart/).

## Getting Started (2/2): Enable the Safety Lints

To get the full benefit of `df_safer_dart`, you must enable its custom linter rules. This is not optional; it is fundamental to the library's design.

1. Add custom_lint and `df_safer_dart_lints` to your `pubspec.yaml`:
```yaml
dependencies:
  df_safer_dart: ^0.14.7

dev_dependencies:
  lints: ^6.0.0
  custom_lint: ^0.7.5
  df_safer_dart_lints: ^0.1.0
```

2. In your `analysis_options.yaml`, add `custom_lint` to the analyzer plugins:
```yaml
analyzer:
  plugins:
    - custom_lint

custom_lint:
  rules:
    - must_await_all_futures: error
    - must_be_anonymous: error
    - must_use_monad: error
    - no_futures_allowed: error
```

## The Core Monads

This package introduces three core monads (`Result`, `Option`, and `Resolvable`) that work seamlessly together:

- `Result`: Represents the outcome of an operation that can fail. It will either be:

  - `Ok`: A success value of type T.
  - `Err`: A failure value containing details about the error.

`Result` eliminates the need for try-catch blocks by making failure an explicit and manageable part of the type system.

- `Option`: Represents a value that may or may not be present. It will either be:

  - `Some`: A present value of type T.
  - `None`: The absence of a value.

`Option` eliminates null values and forces the developer to explicitly handle the "absent" case, preventing NullPointerExceptions.

- `Resolvable`: A powerful wrapper that unifies synchronous and asynchronous operations. It will either be:

  - `Sync`: For immediate, failable operations.
  - `Async`: For time-based, failable operations.

`Resolvable` provides a consistent API for chaining operations, regardless of whether they are synchronous or asynchronous.

These monads form the foundation for more predictable, expressive, and maintainable error handling in Dart.

## Additional

**NOTE:** This packate is best suited for mission critical sections of your project where reliability and safety are essential. For less sensitive code, standard approaches like `Future`, `FutureOr`, try-catch, and nullable types may be more appropriate.

Additionally, the package includes two complementary mechanisms:

- `SafeCompleter`: A safer, more powerful alternative to Dart’s Completer. It allows you to resolve a value (or an error) from any context (synchronous or asynchronous) and provides a `Resolvable` to listen for the result, maintaining type safety throughout.

- `SafeSequential`: A utility for executing a series of failable, synchronous, or asynchronous operations in a guaranteed sequential order. It simplifies the management of complex workflows and provides an alternative to patterns like Future.wait while staying entirely within the monadic world.

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
