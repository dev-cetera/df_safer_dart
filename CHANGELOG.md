# Changelog

## 0.20.0

- **breaking**: `Outcome.end()` now returns `void` everywhere (previously
  `FutureOr<void>`, with `Async.end()` returning `Future<void>`). Calling
  `.end()` is the "intentionally discarding this Outcome" marker — there is
  no longer a Future to await. `Async.end()` detaches its internal cleanup
  via `unawaited(...)`. If you actually need the async value, use `.value`.