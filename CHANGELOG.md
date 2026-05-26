# Changelog

## 0.21.0

- **feat**: `df_safer_dart` now re-exports `df_safer_dart_annotations`. Consumers
  can use `@sendable`, `@noFutures`, `@mustBeAnonymous`, etc. without adding a
  separate dependency.
- **feat**: new `Resolvable.flatMap(...)` — monadic bind that absorbs throws and
  short-circuits on `Err`.
- **feat**: new `Option.mapNone`, `Resolvable.mapSync`, `Resolvable.mapAsync`
  (all `@visibleForTesting`) for pair-axis symmetry with `mapSome` / `mapOk` /
  `mapErr`.
- **fix**: user-thrown `Err` is now preserved verbatim (statusCode and
  breadcrumbs intact) across every transform method — `mapOk`, `mapErr`,
  `mapSome`, `transf`, `flatMap`, `ifOk`/`ifErr`, `ifSync`/`ifAsync`,
  `whenComplete`, `resultMap`, `Outcome.reduce`, `SafeCompleter.transf`,
  `ConcurrentTaskBatch.onError`, `TaskSequencer`. Previously these would
  re-wrap the `Err` and drop its metadata.
- **fix**: `onFinalize` throws in `Sync(...)`, `Async(...)`, and
  `Resolvable(...)` are now absorbed into the result instead of escaping the
  factory or rejecting `Async.value` with an uncaught error.
- **fix**: `letIntOrNone(...)` now correctly rejects `double.infinity` and
  out-of-range doubles on dart2js (where `is int` accepts integer-valued
  doubles).
- **fix**: `combineSync(...)` and `combineAsync(...)` now consume their
  iterable input exactly once — single-pass generators no longer silently
  lose all elements.
- **fix**: `Lazy.singleton` and `Lazy.factory` now absorb constructor throws
  into `Sync.err(...)` and detect re-entrant access, returning a structured
  `Err` instead of a stack overflow.
- **fix**: `SafeCompleter.transf(...)` now forwards errors from the source
  completer — an `Err` source no longer leaves the derived completer dangling
  forever.
- **fix**: `Stream.toSafe()` now preserves the upstream `stackTrace` on `Err`
  instead of capturing a new one at the wrapper call site.
- **fix**: `Err(...)`, `Err.toString()`, and `Here.call()` / `basepath` /
  `location` no longer crash on dart2wasm — the WASM-host trap in
  `path.Style.platform` is caught and falls back to an empty trace / `None`.
- **fix**: `Async.end()` is now guaranteed not to throw, even on hosts where
  the underlying future chain could surface an error synchronously.
- **perf**: `Async.value` skips an unnecessary `Future.value(...)` wrap for
  `Async.new`-constructed instances.
- **perf**: `combineResult(...)` fast path skips the materialized-list
  allocation when no `onErr` aggregator is configured.
- **perf**: many hot helpers (`combineOutcome`, `flatten`, `named`,
  `noneIfEmpty`, iterable filters, `SafeCompleter.resolvable`, task-batch
  queue methods) gained `@pragma('vm:prefer-inline')` and shed per-call
  closure allocations.
- `Outcome.raw(...)` is now annotated `@unsafeOrError` — `df_safer_dart_lints`
  will flag direct call sites that aren't inside an `UNSAFE(...)` block. Use
  `rawSync` / `rawAsync` for the safe variants.
- `Sync`/`Async` constructors and `toAsync` / `toSync` / `UNSAFE` / `asyncSome`
  assertions now correctly allow `Never` type arguments.

## 0.20.0

- **breaking**: `Outcome.end()` now returns `void` everywhere (previously
  `FutureOr<void>`, with `Async.end()` returning `Future<void>`). Calling
  `.end()` is the "intentionally discarding this Outcome" marker — there is
  no longer a Future to await. `Async.end()` detaches its internal cleanup
  via `unawaited(...)`. If you actually need the async value, use `.value`.