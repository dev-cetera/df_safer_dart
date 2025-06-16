# TODO

- [ ] Rename the linter rules to something more explicit and precise.
- [ ] When using `await Future.wait([Future.value(1)])` in an Async for example, the linter shows a warning when it shouldn't. It thinks `Future.value(1)` isn't beiing awaited.
- [ ] Improve package by studying `fpdart` and `ribs_core` by using it in a project and parsing it through AI.
- [ ] Update the rule that discourages `Future` in some functions that it will allow it if there are futures in an `Async` or similar functions that are annotated to allow futures. All linter rules must be robust!
- [ ] Perhaps create a technique or linter rule that ensures that no function returns `Future<Monad>`, `FutureOr<Monad>` and that there are no futures in any function that returns a `Monad` except if they are in an `Async`.