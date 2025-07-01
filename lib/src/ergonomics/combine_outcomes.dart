//.title
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//
// Dart/Flutter (DF) Packages by dev-cetera.com & contributors. The use of this
// source code is governed by an MIT-style license described in the LICENSE
// file located in this project's root directory.
//
// See: https://opensource.org/license/mit
//
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//.title~

// ignore_for_file: must_use_unsafe_wrapper_or_error

import '/_common.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// Combines an iterable of [Outcome]s into one containing a list of their
/// values.
///
/// The result is an [Async] if any of the [outcomes] are [Async]
/// If any resolvable contains an [Err], applies [onErr] to combine errors.
Resolvable<List<Option<T>>> combineOutcome<T extends Object>(
  Iterable<Outcome<T>> outcomes, {
  @noFutures Err<List<Option<T>>> Function(List<Result<Option<T>>> allResults)? onErr,
}) {
  final reduced = outcomes.map((e) => e.reduce<T>());
  return combineResolvable<Option<T>>(reduced, onErr: onErr);
}

/// Combines an iterable of [Resolvable]s into one containing a list of their
/// values.
///
/// The result is an [Async] if any of the [resolvables] are [Async]
/// If any resolvable contains an [Err], applies [onErr] to combine errors.
Resolvable<List<T>> combineResolvable<T extends Object>(
  Iterable<Resolvable<T>> resolvables, {
  @noFutures Err<List<T>> Function(List<Result<T>> allResults)? onErr,
}) {
  if (resolvables.isEmpty) {
    return Sync.okValue([]);
  }

  // If any resolvable is async, the result must be async.
  if (resolvables.any((r) => r.isAsync())) {
    final asyncs = resolvables.map((r) => r.toAsync());
    return combineAsync(asyncs, onErr: onErr);
  } else {
    // All are sync, so we can proceed synchronously.
    final syncs = resolvables.map((r) => r as Sync<T>);
    return combineSync(syncs, onErr: onErr);
  }
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
  final successes = <T>[];
  final asList = results.toList();
  for (final result in asList) {
    switch (result) {
      case Ok(value: final value):
        successes.add(value);
      case final Err err:
        if (onErr != null) {
          return onErr(asList);
        } else {
          return err.transfErr();
        }
    }
  }
  return Ok(successes);
}
