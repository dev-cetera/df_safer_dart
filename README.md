[![pub](https://img.shields.io/pub/v/df_safer_dart.svg)](https://pub.dev/packages/df_safer_dart)
[![tag](https://img.shields.io/badge/Tag-v0.20.0-purple?logo=github)](https://github.com/dev-cetera/df_safer_dart/tree/v0.20.0)
[![buymeacoffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-FFDD00?logo=buy-me-a-coffee&logoColor=black)](https://www.buymeacoffee.com/dev_cetera)
[![sponsor](https://img.shields.io/badge/Sponsor-grey?logo=github-sponsors&logoColor=pink)](https://github.com/sponsors/dev-cetera)
[![patreon](https://img.shields.io/badge/Patreon-grey?logo=patreon)](https://www.patreon.com/robelator)
[![discord](https://img.shields.io/badge/Discord-5865F2?logo=discord&logoColor=white)](https://discord.gg/gEQ8y2nfyX)
[![instagram](https://img.shields.io/badge/Instagram-E4405F?logo=instagram&logoColor=white)](https://www.instagram.com/dev_cetera/)
[![license](https://img.shields.io/badge/License-MIT-blue.svg)](https://raw.githubusercontent.com/dev-cetera/df_safer_dart/main/LICENSE)

---

## Summary

`df_safer_dart` is a foundation layer for **mission-critical Dart and Flutter
code** — built around three sealed types that turn `null`, exceptions, and
`Future`s into values the compiler forces you to handle.

- `Option<T>` = `Some<T>` ∣ `None<T>` — absence-as-data, no null checks.
- `Result<T>` = `Ok<T>` ∣ `Err<T>` — fallibility-as-data, no `try/catch`.
- `Resolvable<T>` = `Sync<T>` ∣ `Async<T>` — sync/async unified, both wrap a `Result`.

Companion packages enforce the safety contracts at compile time:

- [`df_safer_dart_annotations`](https://pub.dev/packages/df_safer_dart_annotations) —
  marker annotations (`@noFutures`, `@unsafeOrError`, `@mustBeAnonymous`,
  `@mustAwaitAllFutures`, `@mustHandleReturn`, `@mustBeStrongRef`).
- [`df_safer_dart_lints`](https://pub.dev/packages/df_safer_dart_lints) — a
  `custom_lint` plugin that turns the annotations into real lint errors.

See [`ARTICLE.md`](https://github.com/dev-cetera/df_safer_dart/blob/main/ARTICLE.md)
for a tutorial-style walkthrough and `example/lib/example.dart` for an
end-to-end runnable pipeline.

## Installation

```sh
dart pub add df_safer_dart
dart pub add --dev custom_lint df_safer_dart_lints
# or, for a Flutter project:
flutter pub add df_safer_dart
flutter pub add --dev custom_lint df_safer_dart_lints
```

Then enable the lint plugin in `analysis_options.yaml`:

```yaml
analyzer:
  plugins:
    - custom_lint
```

## Quick taste

```dart
import 'package:df_safer_dart/df_safer_dart.dart';

Result<int> parseInt(String s) => Sync(() => int.parse(s)).value;

void main() {
  final r = parseInt('42').map((n) => n * 2);

  switch (r) {
    case Ok(value: final n): print('got $n');     // → got 84
    case Err err:            print('failed: ${err.error}');
  }
}
```

## Reliability guarantees

This package is held to a **military-/medical-grade reliability** standard.
The
[`test/hardening_test.dart`](https://github.com/dev-cetera/df_safer_dart/blob/main/test/hardening_test.dart)
and
[`test/propagation_test.dart`](https://github.com/dev-cetera/df_safer_dart/blob/main/test/propagation_test.dart)
suites encode the rules:

- **No stack overflows on deep nesting.** `Outcome.reduce()` and
  `Outcome.raw()` flatten iteratively. A chain of 10,000 nested
  `Some(Some(Ok(Ok(...))))` collapses without consuming 10,000 frames.
- **Stack traces survive transformations.** `Err.transfErr()` preserves the
  original `stackTrace` and `statusCode`.
- **Debug and release behave identically.** Errors thrown inside `fold()` and
  `transf()` always become an `Err` carrying the original stack — no
  `assert(false)` divergence.
- **Throws inside `map` / `flatMap` / `mapOk` are absorbed.** `Ok.map<R>`,
  `Ok.flatMap<R>` and `Ok.mapOk` return `Result<R>` (not `Ok<R>`); a throwing
  callback becomes an `Err` instead of escaping the pipeline.
- **Concurrency primitives don't blow the stack.** `TaskSequencer` drains its
  re-entrant queue iteratively. `SafeCompleter.isCompleted` flips the moment
  a resolve is accepted, making the resolve-once invariant observable.
- **Safe numeric coercion.** `letIntOrNone` returns `None` for `NaN`,
  `±Infinity`, and out-of-range doubles instead of throwing.
- **Iteration-safe combinators.** `combineResolvable` materializes its input
  once, so single-pass `sync*` generators are handled correctly.

### Failure attribution: `Err.breadcrumbs` and `.named(label)`

Every `Err` carries a `List<String> breadcrumbs` — ordered labels identifying
the pipeline step(s) that produced it. Tag steps with `.named(label)` on any
`Result`, `Sync`, `Async`, or `Resolvable`. The first failing step wins
attribution; downstream `.named(...)` calls don't overwrite it.

```dart
final r = parseInt('not-a-number')
  .named('parse')
  .map((n) => n * 2)
  .named('double');

// r is Err(..., breadcrumbs: ['parse'])
```

The 30-test propagation matrix in `propagation_test.dart` verifies that every
combinator on every concrete `Outcome` flavour preserves error attribution
through multi-step pipelines.

## Compile-time enforcement

The custom_lint plugin in `df_safer_dart_lints` (re-)expresses the same rules
at compile time. Every rule is covered by a fixture under
[`df_safer_dart_lints/example/lib/fixtures/`](https://github.com/dev-cetera/df_safer_dart_lints/tree/main/example/lib/fixtures)
and run by an end-to-end test:

| Lint code                                                | Severity        | What it stops |
|----------------------------------------------------------|-----------------|---------------|
| `must_use_outcome_or_error`                              | error           | dropping an `Outcome` on the floor |
| `no_future_outcome_type_or_error`                        | error           | `Future<Outcome<T>>` / `Outcome<Future<T>>` types |
| `no_futures` / `no_futures_or_error`                     | warning / error | `async`/`await`/`Future` inside `@noFutures` |
| `must_await_all_futures` / `_or_error`                   | warning / error | unhandled futures inside `@mustAwaitAllFutures` |
| `must_be_anonymous` / `_or_error`                        | warning / error | passing a named ref where an inline lambda is required |
| `must_be_strong_ref` / `_or_error`                       | warning / error | passing an anonymous closure where a strong ref is required |
| `must_handle_return` / `_or_error`                       | warning / error | dropping the return value of an annotated function |
| `must_use_unsafe_wrapper` / `_or_error`                  | warning / error | calling `@unsafe` / `@unsafeOrError` code outside an `UNSAFE(() => ...)` block |

## Recommended consumer setup

Drop this into your project's `analysis_options.yaml` to opt into the same
strict-but-additive baseline df_safer_dart uses for itself:

```yaml
include: package:lints/recommended.yaml

linter:
  rules:
    unawaited_futures: true
    discarded_futures: true
    cancel_subscriptions: true
    close_sinks: true
    control_flow_in_finally: true
    throw_in_finally: true
    empty_catches: true
    void_checks: true
    cast_nullable_to_non_nullable: true
    null_check_on_nullable_type_parameter: true
    hash_and_equals: true
    test_types_in_equals: true
    recursive_getters: true

analyzer:
  plugins:
    - custom_lint
  language:
    strict-casts: true
    strict-inference: true
    strict-raw-types: true
  errors:
    unawaited_futures: error
    cancel_subscriptions: error
    empty_catches: error
    void_checks: error
    cast_nullable_to_non_nullable: error
    null_check_on_nullable_type_parameter: error
    hash_and_equals: error
    test_types_in_equals: error
    recursive_getters: error
```

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
