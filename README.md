[![banner](https://github.com/dev-cetera/df_safer_dart/blob/v0.17.8/doc/assets/banner.png?raw=true)](https://github.com/dev-cetera)

[![pub](https://img.shields.io/pub/v/df_safer_dart.svg)](https://pub.dev/packages/df_safer_dart)
[![tag](https://img.shields.io/badge/Tag-v0.17.8-purple?logo=github)](https://github.com/dev-cetera/df_safer_dart/tree/v0.17.8)
[![buymeacoffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-FFDD00?logo=buy-me-a-coffee&logoColor=black)](https://www.buymeacoffee.com/dev_cetera)
[![sponsor](https://img.shields.io/badge/Sponsor-grey?logo=github-sponsors&logoColor=pink)](https://github.com/sponsors/dev-cetera)
[![patreon](https://img.shields.io/badge/Patreon-grey?logo=patreon)](https://www.patreon.com/robelator)
[![discord](https://img.shields.io/badge/Discord-5865F2?logo=discord&logoColor=white)](https://discord.gg/gEQ8y2nfyX)
[![instagram](https://img.shields.io/badge/Instagram-E4405F?logo=instagram&logoColor=white)](https://www.instagram.com/dev_cetera/)
[![license](https://img.shields.io/badge/License-MIT-blue.svg)](https://raw.githubusercontent.com/dev-cetera/df_safer_dart/main/LICENSE)

---

<!-- BEGIN _README_CONTENT -->

## Summary

Standard Dart gives you `try-catch` and nullable types. Both put the burden of safety entirely on you. Forget a check, miss an exception, and your app crashes in production.

`df_safer_dart` fixes this with three sealed types: `Option`, `Result`, and `Resolvable`. Exceptions thrown inside these types don't crash your app. They're caught automatically and passed down the chain as `Err` values. You write the happy path; the type system handles the rest.

Inspired by Rust's `Option` and `Result`. Built for Dart.

## Getting Started

- **MEDIUM** [Write Unbreakable Code in Dart](https://medium.com/@dev-cetera/write-unbreakable-code-in-dart-8076e62346b5)
- **DEV.TO** [Write Unbreakable Code in Dart](https://dev.to/dev_cetera/write-unbreakable-code-in-dart-njh)
- **GITHUB** [Write Unbreakable Code in Dart](https://github.com/dev-cetera/df_safer_dart/blob/main/ARTICLE.md)

## The Three Core Types

### `Result<T>` — Operations That Can Fail

Either `Ok<T>` (success value) or `Err<T>` (traceable error). Turns exceptions into data.

```dart
// Sync catches the throw and converts it to Err<Map> automatically.
Sync<Map<String, dynamic>> parseJson(String raw) =>
    Sync(() => jsonDecode(raw) as Map<String, dynamic>);

final result = parseJson('{"name": "Alice"}').value;
switch (result) {
  case Ok(value: final data):
    print(data['name']); // Alice
  case Err(error: final e):
    print('Parse failed: $e');
}
```

### `Option<T>` — Values That Might Not Exist

Either `Some<T>` (present) or `None<T>` (absent). Eliminates null checks.

```dart
Option<String> findUser(Map<String, String> db, String id) =>
    Option.from(db[id]);

final user = findUser({'1': 'Alice'}, '2');
print(user.unwrapOr('Guest')); // Guest
```

### `Resolvable<T>` — Unified Sync/Async

Either `Sync<T>` (immediate `Result<T>`) or `Async<T>` (future `Result<T>`). One API for both.

```dart
Async<String> fetchData() => Async(() async {
      final response = await http.get(Uri.parse('https://api.example.com/data'));
      if (response.statusCode != 200) throw Exception('HTTP ${response.statusCode}');
      return response.body;
    });

// The throw above doesn't crash. It becomes Err<String>.
final result = await fetchData().value;
```

## Chaining Operations

The real power is in chaining. Each `.map()` and `.flatMap()` only runs if the previous step succeeded. If anything fails, the error propagates automatically — no try-catch needed anywhere in the chain.

```dart
Async<Option<String>> getUserNotificationSound(int userId) {
  return fetchUserData(userId)              // Async<String>
      .map((json) => parseJson(json))       // Async<Map> — exceptions become Err
      .map((data) =>
          getFromMap<Map>(data, 'config')    // Option<Map>
              .flatMap((c) => getFromMap<Map>(c, 'notifications'))
              .flatMap((n) => getFromMap<String>(n, 'sound')),
      );
}

// Consume the result with exhaustive pattern matching:
final result = await getUserNotificationSound(1).value;
switch (result) {
  case Ok(value: Some(value: final sound)):
    print('Sound: $sound');
  case Ok(value: None()):
    print('No sound configured');
  case Err(error: final e):
    print('Failed: $e');
}
```

## Working with Collections

The library extends `Iterable`, `Map`, and `String` with safe operations:

```dart
final items = [Some(1), None<int>(), Some(3), Some(5)];

items.whereSome();      // Iterable<Some<int>> → [Some(1), Some(3), Some(5)]
items.values;           // Iterable<int> → [1, 3, 5]
items.sequenceList();   // Option<List<int>> → None (because one element is None)
items.partition();      // (someParts: [...], noneParts: [...])

// Same for Result:
final results = [Ok(1), Err<int>('fail'), Ok(3)];
results.whereOk();      // Iterable<Ok<int>> → [Ok(1), Ok(3)]
results.values;         // Iterable<int> → [1, 3]

// Safe collection access:
[10, 20, 30].elementAtOrNone(5); // None
[10, 20, 30].firstOrNone;       // Some(10)
{'a': 1}.getOption('b');         // None
'hello'.firstOrNone;             // Some('h')
```

## Flattening Nested Types

When operations compose, types can nest: `Result<Result<T>>`, `Option<Option<T>>`, etc. Use `.flatten()` to collapse them:

```dart
final nested = Ok(Ok(42));        // Result<Result<int>>
final flat = nested.flatten();    // Result<int> → Ok(42)

final deep = Some(Some(Some(7))); // Option<Option<Option<int>>>
final flat3 = deep.flatten();     // Option<Option<int>> → Some(Some(7))
final flat3b = deep.flatten().flatten(); // Option<int> → Some(7)
```

For deeply nested `Outcome` types (e.g., `Resolvable<Result<Option<T>>>`), use `reduce()` to collapse everything into a single `Resolvable<Option<T>>`:

```dart
final complex = Sync.okValue(Ok(Some(42)));  // Sync<Result<Option<int>>>
final reduced = complex.reduce<int>();        // Resolvable<Option<int>>
```

## Combining Multiple Results

Combine independent operations without nested callbacks:

```dart
final name = Ok('Alice');
final age = Ok(30);
final email = Err<String>('Email service unavailable');

// combine2 returns Ok((Alice, 30)) or the first Err encountered.
final profile = Result.combine2(name, age);

// combine3 would short-circuit with the email Err.
final full = Result.combine3(name, age, email); // Err

// Works for Option, Sync, and Async too:
final both = Option.combine2(Some('a'), Some('b')); // Some(('a', 'b'))
final nope = Option.combine2(Some('a'), None<String>()); // None
```

## Safe Type Conversion

Convert between types safely without casting or exceptions:

```dart
// Safe conversions from dynamic/unknown data:
letIntOrNone('42');           // Some(42)
letIntOrNone('hello');        // None
letDoubleOrNone('3.14');      // Some(3.14)
letBoolOrNone('true');        // Some(true)
letAsOrNone<List>(someValue); // Some(list) or None — never throws

// Transform between Outcome types:
final r = Ok(42).transf<String>((n) => n.toString()); // Ok('42')
```

## The `UNSAFE` Label Convention

Operations that could throw are marked `@unsafeOrError` and enforced by custom lint rules. When you must use them, the `UNSAFE:` label makes it explicit:

```dart
// The linter warns if you call unwrap() without the UNSAFE label:
UNSAFE:
final value = someResult.unwrap(); // Throws if Err

// Prefer safe alternatives:
final value = someResult.unwrapOr(defaultValue);
// Or pattern matching:
switch (someResult) {
  case Ok(value: final v): /* use v */
  case Err(): /* handle error */
}
```

## When to Use This Package

**Use it for:** core business logic, data parsing and validation, network/database interactions, authoring library APIs, and any module where a silent failure is unacceptable.

**Skip it for:** simple UI display code (Dart's `??` and `?.` are fine), rapid prototyping, tight performance-critical loops, and codebases that rely on exceptions for control flow.

## Setup

1. Add dependencies to `pubspec.yaml`:

```yaml
dependencies:
  df_safer_dart: any

dev_dependencies:
  custom_lint: any
  df_safer_dart_lints: any
```

2. Configure `analysis_options.yaml`:

```yaml
analyzer:
  plugins:
    - custom_lint

# Optional — tune individual rules:
custom_lint:
  rules:
    - must_await_all_futures: true
    - must_be_anonymous: true
    - must_use_outcome_or_error: true
    - must_use_unsafe_wrapper_or_error: true
    - no_future_outcome_type_or_error: true
    - no_futures: true

# Optional — suppress label warnings:
errors:
  unused_label: ignore
  non_constant_identifier_names: ignore
```

<!-- END _README_CONTENT -->

---

🔍 For more information, refer to the [API reference](https://pub.dev/documentation/df_safer_dart/).

---

## 💬 Contributing and Discussions

This is an open-source project, and we warmly welcome contributions from everyone, regardless of experience level. Whether you're a seasoned developer or just starting out, contributing to this project is a fantastic way to learn, share your knowledge, and make a meaningful impact on the community.

### ☝️ Ways you can contribute

- **Find us on Discord:** Feel free to ask questions and engage with the community here: https://discord.gg/gEQ8y2nfyX.
- **Share your ideas:** Every perspective matters, and your ideas can spark innovation.
- **Help others:** Engage with other users by offering advice, solutions, or troubleshooting assistance.
- **Report bugs:** Help us identify and fix issues to make the project more robust.
- **Suggest improvements or new features:** Your ideas can help shape the future of the project.
- **Help clarify documentation:** Good documentation is key to accessibility. You can make it easier for others to get started by improving or expanding our documentation.
- **Write articles:** Share your knowledge by writing tutorials, guides, or blog posts about your experiences with the project. It's a great way to contribute and help others learn.

No matter how you choose to contribute, your involvement is greatly appreciated and valued!

### ☕ We drink a lot of coffee...

If you're enjoying this package and find it valuable, consider showing your appreciation with a small donation. Every bit helps in supporting future development. You can donate here: https://www.buymeacoffee.com/dev_cetera

<a href="https://www.buymeacoffee.com/dev_cetera" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/default-orange.png" height="40"></a>

## LICENSE

This project is released under the [MIT License](https://raw.githubusercontent.com/dev-cetera/df_safer_dart/main/LICENSE). See [LICENSE](https://raw.githubusercontent.com/dev-cetera/df_safer_dart/main/LICENSE) for more information.
