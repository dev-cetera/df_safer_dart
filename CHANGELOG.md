# Changelog

## 0.20.0

### Breaking

- **`Outcome.end()` now returns `void` everywhere** (previously
  `FutureOr<void>`, with `Async.end()` returning `Future<void>`). Calling
  `.end()` is the "intentionally discarding this Outcome" marker — there is
  no longer a Future to await. `Async.end()` detaches its internal cleanup
  via `unawaited(...)` internally. If you actually need to wait for the
  async value, use `.value`.

### Cleanup

- Removed every `// ignore_for_file:` and `// ignore:` comment that was
  patching over a structural lint issue. The only ignores that remain are:
    - the generated `_err_model.g.dart` header (codegen-owned),
    - the `_ErrModel` generator-input class,
    - the `UNSAFE` all-caps function name.
- `discarded_futures` sites in `TaskSequencer` are now resolved by an
  explicit `unawaited(...)` at the one place that produces a long-lived
  future, instead of suppressing the lint package-wide.
- `omit_local_variable_types` site in `Outcome.reduce()` removed by widening
  via `this as Object` instead of an explicit type annotation.
- `cast_nullable_to_non_nullable` in `Resolvable._withMinDuration` removed by
  switching to a Dart-3 record `.wait` whose per-position types preserve `R`.

## 0.19.0

### Breaking

- **`Ok.map<R>` now returns `Result<R>`** (was `Ok<R>`). A throwing callback
  is absorbed into an `Err` instead of escaping. Call sites that type-annotate
  the result as `Ok<R>` must switch to `Result<R>`.
- **`Ok.flatMap<R>` now absorbs throws** into an `Err` (previously rethrew).
  Return type was already `Result<R>` — no signature change.
- **`Ok.mapOk` now returns `Result<T>`** (was `Ok<T>`). Same absorb-throws fix.
- **`WrapOnOkExt.wrapValueInX`** widened from `Ok<X>` to `Result<X>` (cascades
  from `Ok.map` change).
- **`ToUnitOnVoidOk.toUnit`** and **`ToUnitOnObjectOk.toUnit`** widened from
  `Ok<Unit>` to `Result<Unit>` (same cascade).

### Added

- **`Err.breadcrumbs: List<String>`** — ordered labels identifying the
  pipeline step(s) that produced the error. Empty by default. Preserved by
  `transfErr<R>()` and surfaced in `toJson()` (only when non-empty).
- **`.named(String label)` extensions** on `Result`, `Sync`, `Async`, and
  `Resolvable`. Tags any `Err` flowing through with the label, but only if
  the `Err` has no breadcrumbs yet — preserving the first failing step's
  attribution.
- `test/propagation_test.dart` — 30-test propagation matrix covering every
  combinator on every concrete `Outcome` flavour with throwing callbacks and
  multi-step `.named()` pipelines.

### Improved

- **`UNSAFE`** — removed the dead `try { return block(); } catch (e, _) { rethrow; }`
  body, which added a stack frame on every call for no observable effect.
- **`UNSAFE`** docstring now documents both supported invocation forms
  (function-call and labeled-statement) — both are recognised by the lint.
- ~70 sites converted from explicit lambdas (`(e) => Ok(e)`) to tear-offs
  (`Ok.new`) across `wrap_outcome_ext.dart`, `swap/*_ext.dart`,
  `let_or_none_collections.dart`, `_async.dart`, `task_sequencer.dart`.
  No behavioural change; fewer closure allocations and zero
  `unnecessary_lambdas` diagnostics.

### Documented

- `Option.flatMap` / `Option.filter` carry an explicit "callback must not
  throw" contract — `Option<R>` has no `Err` slot to absorb a throw. Doc
  comment points at `.fold()` / `.transf()` / `Sync(() => ...)` for fallible
  work.
- `Outcome.map` doc comment clarifies the same nuance globally.

## 0.18.0

- Tightened `analysis_options.yaml`: added strict-but-additive safety lints
  (`unawaited_futures`, `cancel_subscriptions`, `close_sinks`,
  `control_flow_in_finally`, `throw_in_finally`, `empty_catches`,
  `void_checks`, `cast_nullable_to_non_nullable`,
  `null_check_on_nullable_type_parameter`, `hash_and_equals`,
  `test_types_in_equals`, `recursive_getters`) and promoted the most
  load-bearing ones to `error` severity.
- Cleaned all custom_lint violations from the package's own source
  (`shortcuts.dart`, `wrap_outcome_ext.dart`).
- Fixed `_withMinDuration` to suppress the `cast_nullable_to_non_nullable`
  diagnostic locally with an explanation of why the cast is safe.
- Converted the former `test_task_sequencer_2.dart` (which lived under
  `example/lib/sequencer_demos/` and incorrectly imported `package:test`)
  into a runnable demo that uses `main()` with inline assertions.
- README and ARTICLE rewritten to reflect the actual API surface, the
  hardening guarantees, and the full list of lints the consumer gets.
