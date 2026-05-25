//.title
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//
// Copyright © dev-cetera.com & contributors.
//
// The use of this source code is governed by an MIT-style license described in
// the LICENSE file located in this project's root directory.
//
// See: https://opensource.org/license/mit
//
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//.title~

import '/_common.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// Combines an iterable of [Outcome]s into one containing a list of their
/// values.
///
/// The result is an [Async] if any of the [outcomes] are [Async]
/// If any resolvable contains an [Err], applies [onErr] to combine errors.
@pragma('vm:prefer-inline')
Resolvable<List<Option<T>>> combineOutcome<T extends Object>(
  Iterable<Outcome<T>> outcomes, {
  @noFutures
  Err<List<Option<T>>> Function(List<Result<Option<T>>> allResults)? onErr,
}) {
  final reduced = outcomes.map((e) => e.reduce<T>());
  return combineResolvable<Option<T>>(reduced, onErr: onErr);
}

/// Combines an iterable of [Resolvable]s into one containing a list of their
/// values.
///
/// The result is an [Async] if any of the [resolvables] are [Async]
/// If any resolvable contains an [Err], applies [onErr] to combine errors.
///
/// The input iterable is consumed exactly once, so it is safe to pass a
/// single-pass iterable (e.g. a `sync*` generator).
Resolvable<List<T>> combineResolvable<T extends Object>(
  Iterable<Resolvable<T>> resolvables, {
  @noFutures Err<List<T>> Function(List<Result<T>> allResults)? onErr,
}) {
  // Materialize once. Single-pass iterables (sync* generators) would
  // otherwise be exhausted by the `.any()` probe below and the subsequent
  // `.map()` would silently see zero elements.
  final list = resolvables.toList(growable: false);
  if (list.isEmpty) {
    return Sync.okValue([]);
  }

  // If any resolvable is async, the result must be async.
  var hasAsync = false;
  for (final r in list) {
    if (r.isAsync()) {
      hasAsync = true;
      break;
    }
  }
  if (hasAsync) {
    return combineAsync(list.map((r) => r.toAsync()), onErr: onErr);
  }
  return combineSync(list.map((r) => r as Sync<T>), onErr: onErr);
}

/// Combines an iterable of [Sync]s into one containing a list of their values.
///
/// If any [Sync] contains an [Err], applies the [onErr] function to combine
/// errors.
Sync<List<T>> combineSync<T extends Object>(
  Iterable<Sync<T>> syncs, {
  @noFutures Err<List<T>> Function(List<Result<T>> allResults)? onErr,
}) {
  if (syncs.isEmpty) {
    return Sync.okValue([]);
  }

  return Sync(() {
    final results = syncs.map((s) => s.value).toList();
    final combined = combineResult(results, onErr: onErr);
    switch (combined) {
      case Ok(value: final value):
        return value;
      case Err err:
        throw err;
    }
  });
}

/// Combines an iterable of [Async]s into one containing a list of their values.
///
/// The inputs are awaited concurrently. If any resolves to an [Err], applies
/// the [onErr] function to combine errors.
Async<List<T>> combineAsync<T extends Object>(
  Iterable<Async<T>> asyncs, {
  @noFutures Err<List<T>> Function(List<Result<T>> allResults)? onErr,
}) {
  if (asyncs.isEmpty) {
    return Async.okValue([]);
  }

  return Async(() async {
    final results = await Future.wait(asyncs.map((a) => a.value));
    final combined = combineResult(results, onErr: onErr);
    switch (combined) {
      case Ok(value: final value):
        return value;
      case Err err:
        throw err;
    }
  });
}

/// Combines an iterable of [Option]s into one containing a list of their values.
///
/// If any [Option] is a [None], the result is a [None].
Option<List<T>> combineOption<T extends Object>(Iterable<Option<T>> options) {
  final values = <T>[];
  for (final option in options) {
    switch (option) {
      case Some(value: final value):
        values.add(value);
      case None():
        return const None();
    }
  }
  return Some(values);
}

/// Combines an iterable of [Result]s into one containing a list of their values.
///
/// If any [Result] is an [Err], applies the [onErr] function to combine errors.
Result<List<T>> combineResult<T extends Object>(
  Iterable<Result<T>> results, {
  @noFutures Err<List<T>> Function(List<Result<T>> allResults)? onErr,
}) {
  // Fast path: when no aggregating error handler is configured we never need
  // to keep the original list around — iterate the input directly and
  // propagate the first Err immediately. Skips one List allocation per call.
  if (onErr == null) {
    final successes = <T>[];
    for (final result in results) {
      switch (result) {
        case Ok(value: final value):
          successes.add(value);
        case final Err err:
          return err.transfErr();
      }
    }
    return Ok(successes);
  }
  // Slow path: onErr wants the full original list, so materialize once.
  final asList = results.toList();
  final successes = <T>[];
  for (final result in asList) {
    switch (result) {
      case Ok(value: final value):
        successes.add(value);
      case final Err _:
        return onErr(asList);
    }
  }
  return Ok(successes);
}
