# CLAUDE.md — df_safer_dart

Working notes for AI agents collaborating on this package. The user has stated the goal is **military-/medical-grade reliability** — code must not fail under abuse or misuse. Treat that as a hard design constraint, not a slogan.

## Package role

`df_safer_dart` is the **foundation layer** of a four-package Flutter state-management stack. The full stack lives next to this package in `/Users/robmllze/Projects/flutter/dev_cetera/df_packages/packages/`:

| Package | Path | Role |
| --- | --- | --- |
| `df_safer_dart` *(this)* | `.` | Core types (`Option`, `Result`, `Resolvable`), extensions, concurrency tools (`SafeCompleter`, `TaskSequencer`, `ConcurrentTaskBatch`, `SequencedTaskBatch` on a shared `TaskBatchBase`) |
| `df_di` | `../df_di` | DI container hierarchy (`DI.root`/`global`/`session`/`user`), `Service`/`ServiceMixin`, `StreamServiceMixin`, `PollingStreamServiceMixin` |
| `df_pod` | `../df_pod` | Reactive containers (`Pod<T>`, `ChildPod`, `ReducerPod`, `SharedPod`), `WeakChangeNotifier`, `PodBuilder` and friends |
| `df_flutter_services` | `../df_flutter_services` | `ObservedService`, `ObservedDataStreamService`, `HandleServiceLifecycleStateMixin` (Flutter app-lifecycle glue) |

Tightly-coupled siblings used only inside this package:

| Package | Path | Role |
| --- | --- | --- |
| `df_safer_dart_annotations` | `../df_safer_dart_annotations` | Marker annotations: `@noFutures`, `@unsafeOrError`, `@mustBeAnonymous`, `@mustAwaitAllFutures`, `@mustHandleReturn`, `@mustBeStrongRef`, `@experimental` |
| `df_safer_dart_lints` | `../df_safer_dart_lints` | `custom_lint` plugin enforcing the annotations as compile-time rules |
| `df_type` | `../df_type` | Type-checking, conversion helpers (`isSubtype`, `letOrNull`, etc.), `FutureOr` plumbing |

`pubspec_overrides.yaml` pins siblings to local paths. Edits take effect without publishing.

### State-management guide

For how `Option` / `Result` / `Resolvable` flow through services, DI scopes, and Flutter widgets, read **`doc/state_management_approach.md`**. The same file is mirrored in every package of the stack (`df_safer_dart`, `df_di`, `df_pod`, `df_flutter_services`) — keep the copies in sync when editing.

## Architecture in one screen

- `Outcome<T>` (sealed) is the root. Subtree sealed classes: `Option`, `Result`, `Resolvable`.
- `Option<T>` = `Some<T>` | `None<T>` — absence-as-data.
- `Result<T>` = `Ok<T>` | `Err<T>` — fallibility-as-data. `Err` implements `Exception`.
- `Resolvable<T>` = `Sync<T>` | `Async<T>` — sync/async unified. Both wrap `Result<T>`.
- `Outcome.reduce<R>()` collapses any nested chain into `Resolvable<Option<R>>`.
- `Outcome.unwrap()` throws on `Err`/`None`. Always annotated `@unsafeOrError` — call sites must be inside an `UNSAFE(...)` block or be flagged by lints.

Everything is exported by `lib/df_safer_dart.dart` → `lib/src/_src.g.dart` (generated index — regenerate with `df_generate_dart_indexes`, do not hand-edit).

`lib/_common.dart` is the internal umbrella — every `src/**.dart` imports it via `'/_common.dart'`. It re-exports `dart:async`, `equatable`, `meta`, `stack_trace`, plus the sibling annotation/type packages.

`ARTICLE.md` is the user-facing introduction to the package — a tutorial-style explainer covering `Option`, `Result`, and `Resolvable` with worked examples. Read it before answering conceptual questions about the package or onboarding new consumers; keep it in sync if the public API of those three types changes. The end-to-end runnable counterpart lives in `example/example.dart`.

## Conventions

- **No raw `Future`.** Use `Resolvable<T>`. Linter rule `no_futures` enforces this in client code; internal code that needs Futures uses `// ignore_for_file: no_future_outcome_type_or_error`.
- **No raw `try/catch` in business logic.** `Sync(() => …)` and `Async(() async => …)` absorb throws into `Err`. `unwrap()` calls outside `UNSAFE { … }` are a lint violation.
- **`@noFutures`** on a parameter means: the closure must return `T`, not `Future<T>`. Enforced by the linter.
- **`@mustBeAnonymous`** on a closure parameter forbids passing a named/captured function ref (forces inline lambdas the linter can see).
- **`@unsafeOrError`** marks members that throw — callers must wrap with `UNSAFE { … }` or accept the lint error.
- **Generated files** end in `.g.dart`. Do not hand-edit. `_src.g.dart` indexes are produced by `df_generate_dart_indexes`.
- **License header**: every Dart file starts with the `▓▓▓` banner — preserve when editing.
- Imports use the `'/_common.dart'` relative shortcut; `prefer_relative_imports` is enforced.

## Tests

Test files live in `test/` and follow the standard `*_test.dart` naming, so `dart test` discovers them all. Two zones:

- `test/*.dart` — broad behaviour suites: `hardening_test.dart`, `propagation_test.dart`, the `abuse_*_test.dart` family, `medical_grade_test.dart`, `chain_propagation_test.dart`, `err_preservation_test.dart`, `error_propagation_systematic_test.dart`, `audit_round_test.dart`, `isolate_sendability_test.dart`, `int64_boundary_vm_test.dart`, `safe_completer_test.dart`. Add new abuse/hardening cases here.
- `test/unit/src/…` — mirror of `lib/src/…`. New unit tests for a source file at `lib/src/foo/bar.dart` go to `test/unit/src/foo/bar_test.dart`, not the top level.

Runnable sequencer demos (no `test()` calls) live under `example/lib/sequencer_demos/` — they are not tests.

## Commands

```bash
dart pub get
dart analyze
dart test                                          # run all tests
dart test test/safe_completer_test.dart            # individual test files
dart run custom_lint                               # run the safety lints
```

## Hardening sweep (2026-05-20)

A robustness audit produced `test/hardening_test.dart`, which exercises each defect found. All abuse cases now pass. Summary of fixes applied (breaking changes were authorized):

- **`letIntOrNone`** now returns `None` for `NaN`, `±Infinity`, and any double outside the int64 range, instead of throwing `UnsupportedError`.
- **`combineResolvable`** materializes its iterable once, so single-pass `sync*` generators no longer silently lose elements.
- **`Err.transfErr()`** preserves the original `stackTrace` (and `statusCode`) when transferring the generic type.
- **`fold()` and `transf()` in Ok/Err/Some/None/Sync/Async** no longer use `assert(false, error)` — debug and release builds now behave identically: the captured error is returned as an `Err` with stack trace intact. `transf()` error messages now include the original error.
- **`TaskSequencer._processReentrantQueue`** drains iteratively (guarded by `_draining`) — a 200 000-task reentrant burst no longer recurses on the stack.
- **`SafeCompleter.isCompleted`** reports `true` from the moment a resolve is accepted (the "committed" point), not only after the future settles. **Breaking change**: code that relied on `isCompleted` being `false` during an in-flight future must update — the new contract makes the resolve-once invariant observable.
- **`Outcome.reduce<R>()`** was rewritten:
  - The previous `switch` had **dead code**: the broad `Some(value: final someValue)` case shadowed the `Some(value: Outcome<Object> outcomeValue)` case, so nested `Some(Some(...))` / `Ok(Ok(...))` chains were **never actually flattened**. Now correctly peels every layer.
  - Implementation is iterative: 10 000-deep nesting no longer consumes 10 000 stack frames.
- **`Outcome.raw()`** dive loop is also iterative for sync layers; async hops still go through `Future.then(dive)`.

### Design choices that look like defects but are intentional
- `UNSAFE(...)` in `ergonomics/unsafe.dart` is documented as a marker that provides "no actual safety guarantees" — it re-throws, exists only for lint enforcement. Don't "fix" it to swallow errors.
- `Lazy.singleton` doesn't lock — Dart is single-threaded per isolate, so the "race" is only a problem if the constructor itself suspends. Document that, don't add fake locks.
- `Some/Ok.transf()` already wrap the `as R` cast in try/catch; cast failures become `Err` correctly. The cast itself does not need replacement.

## What to do when the user asks for hardening

The user has explicitly asked for this package to be robust under abuse. When in doubt: write a failing test first that demonstrates the abuse, then fix. Don't refactor speculatively. Confirm scope before mass-rewriting any of the core sealed types — they are exported as the package's public API surface and breaking them ripples across every consumer in this monorepo.
