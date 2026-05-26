[![pub](https://img.shields.io/pub/v/df_safer_dart.svg)](https://pub.dev/packages/df_safer_dart)
[![tag](https://img.shields.io/badge/Tag-v0.21.0-purple?logo=github)](https://github.com/dev-cetera/df_safer_dart/tree/v0.21.0)
[![buymeacoffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-FFDD00?logo=buy-me-a-coffee&logoColor=black)](https://www.buymeacoffee.com/dev_cetera)
[![sponsor](https://img.shields.io/badge/Sponsor-grey?logo=github-sponsors&logoColor=pink)](https://github.com/sponsors/dev-cetera)
[![patreon](https://img.shields.io/badge/Patreon-grey?logo=patreon)](https://www.patreon.com/robelator)
[![discord](https://img.shields.io/badge/Discord-5865F2?logo=discord&logoColor=white)](https://discord.gg/gEQ8y2nfyX)
[![instagram](https://img.shields.io/badge/Instagram-E4405F?logo=instagram&logoColor=white)](https://www.instagram.com/dev_cetera/)
[![license](https://img.shields.io/badge/License-MIT-blue.svg)](https://raw.githubusercontent.com/dev-cetera/df_safer_dart/main/LICENSE)

---

<!-- BEGIN _README_CONTENT -->

## Stop writing defensive code. Write the happy path.

Dart code leaks risk in three places: nullable values, thrown exceptions, and
unawaited futures. `df_safer_dart` turns all three into typed values the
compiler tracks for you — so the noisy parts of your code disappear and the
intent stays.

```dart
import 'package:df_safer_dart/df_safer_dart.dart';
import 'dart:convert';

Async<Option<String>> notificationSound(int userId) =>
    fetchUserData(userId)                                  // Async<String>
        .map((body) => UNSAFE(() => jsonDecode(body)))     // Async<dynamic>
        .map((data) => getFromMap<Map>(data, 'config')     // -> Option chain
            .flatMap((c) => getFromMap<Map>(c, 'notifications'))
            .flatMap((n) => getFromMap<String>(n, 'sound')));
```

No `try / catch`. No `await`. No `if (x != null)`. If anything throws or a key
is missing, the chain short-circuits and the failure arrives at the end with
the original stack trace intact.

## Three sealed types do all the work

| Type | Variants | What it replaces |
|------|----------|------------------|
| `Option<T>` | `Some<T>` ∣ `None<T>` | nullable `T?`, null checks |
| `Result<T>` | `Ok<T>` ∣ `Err<T>` | thrown exceptions, `try / catch` |
| `Resolvable<T>` | `Sync<T>` ∣ `Async<T>` | the `T` vs. `Future<T>` split |

They share a common `Outcome<T>` interface — `map`, `flatMap`, `fold`,
`unwrap`, `named` work uniformly across all three. Sync stays sync;
asynchrony only appears when something genuinely is async.

## Install

```sh
dart pub add df_safer_dart
dart pub add --dev custom_lint df_safer_dart_lints
```

Enable the lint plugin in `analysis_options.yaml`:

```yaml
analyzer:
  plugins:
    - custom_lint
```

## The compiler enforces the discipline

The companion [`df_safer_dart_lints`](https://pub.dev/packages/df_safer_dart_lints)
plugin makes the safety rules non-negotiable. A few examples of what it catches:

- Dropping an `Outcome` on the floor.
- Declaring a `Future<Outcome<T>>` (use `Async<T>` instead).
- Calling `.unwrap()` outside an `UNSAFE(() => ...)` block.
- `async`/`await` inside a function marked `@noFutures`.

You don't have to remember the rules. The analyzer remembers them for you.

## Know which step failed

Every `Err` carries a list of `breadcrumbs`. Tag any step with `.named(label)`
and you'll know exactly where a failure originated:

```dart
parseInt('not-a-number')
    .named('parse')
    .map((n) => n * 2)
    .named('double');

// → Err(FormatException..., breadcrumbs: ['parse'])
```

## Built for code that can't fail

Every guarantee is backed by an abuse test in
[`test/hardening_test.dart`](https://github.com/dev-cetera/df_safer_dart/blob/main/test/hardening_test.dart):

- 10,000-deep nested outcomes flatten without blowing the stack.
- Throws inside `map` / `flatMap` are absorbed — they never escape the pipeline.
- Stack traces survive every transformation, including type changes.
- Debug and release behave identically — no `assert(false)` divergence.
- Numeric coercions return `None` for `NaN` / `±Infinity` instead of throwing.
- Concurrency primitives (`TaskSequencer`, `SafeCompleter`) drain iteratively
  under reentrant bursts.

## Learn more

- **[ARTICLE.md](https://github.com/dev-cetera/df_safer_dart/blob/main/ARTICLE.md)** —
  tutorial-style walkthrough of `Option`, `Result`, and `Resolvable` with
  worked examples.
- **[example/lib/example.dart](https://github.com/dev-cetera/df_safer_dart/blob/main/example/lib/example.dart)** —
  the JSON-fetch pipeline above, runnable end to end.

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
