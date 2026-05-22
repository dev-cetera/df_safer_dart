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

part 'option/_option.dart';
part 'option/_some.dart';
part 'option/_none.dart';
part 'result/_result.dart';
part 'result/_ok.dart';
part 'result/_err.dart';
part 'resolvable/_resolvable.dart';
part 'resolvable/_async.dart';
part 'resolvable/_sync.dart';

part 'impl/_sync_impl.dart';
part 'impl/_async_impl.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// The foundational sealed class for all [Outcome] types like [Option],
/// [Result] and [Resolvable].
sealed class Outcome<T extends Object> implements Equatable {
  const Outcome(this.value);

  final FutureOr<Object> value;

  /// Reduces any nested [Outcome] structure into a single [TResolvableOption].
  ///
  /// This flattens all [Outcome] layers ([Option], [Result], [Resolvable]) into
  /// a final container that is always a [Resolvable] holding an [Option].
  /// An [Err] state at any level will result in a failed [Resolvable].
  ///
  /// The implementation is iterative: a chain of `Some(Some(Some(... 42)))`
  /// thousands deep does not consume a stack frame per layer. Only crossing
  /// into an asynchronous layer (`Async`, or a `Future` lurking inside a
  /// `Some`/`Ok`) hands off to a single async continuation.
  TResolvableOption<R> reduce<R extends Object>() {
    // The loop variable is reassigned to various sealed-Outcome subtypes plus
    // raw payload values, so the static type must widen to `Object`. The cast
    // achieves that without an explicit-type annotation the lint dislikes.
    var current = this as Object;
    while (true) {
      if (current is None) {
        return syncNone<R>();
      }
      if (current is Err) {
        final err = current;
        return Sync.err(
          Err<Option<R>>(
            err.error,
            statusCode: err.statusCode.orNull(),
            stackTrace: err.stackTrace,
          ),
        );
      }
      if (current is Async) {
        final futureResult = current.value;
        return Async<Option<R>>(() async {
          final result = await futureResult;
          return (await result.reduce<R>().value).unwrap();
        });
      }
      if (current is Outcome) {
        final inner = current.value;
        if (inner is Future) {
          return Async<Option<R>>(() async {
            final resolved = await inner;
            if (resolved is Outcome<Object>) {
              return (await resolved.reduce<R>().value).unwrap();
            }
            return Some(resolved as R);
          });
        }
        current = inner;
        continue;
      }
      // Innermost raw, non-Outcome value.
      final raw = current;
      return Sync(() => Some(raw as R));
    }
  }

  /// The low-level primitive for reducing a [Outcome] chain. It recursively
  /// unwraps all [Outcome] layers to return the innermost raw value, forcing the
  /// caller to handle terminal states via callbacks.
  ///
  /// - [onErr]: A function that is called when an [Err] is encountered.
  /// - [onNone]: A function that is called when a [None] is encountered.
  FutureOr<Object> raw({
    required FutureOr<Object> Function(Err<Object> err) onErr,
    required FutureOr<Object> Function() onNone,
  }) {
    FutureOr<Object> dive(Object start) {
      // Iterative peel for all synchronous layers. Recursion is reserved for
      // crossing into a Future via `.then(dive)`, so the call depth is bounded
      // by the number of async hops in the chain, not the total nesting depth.
      var current = start;
      while (true) {
        if (current is Err) {
          return onErr(current);
        }
        if (current is None) {
          return onNone();
        }
        if (current is Outcome) {
          final inner = current.value;
          if (inner is Future<Object>) {
            return inner.then(dive);
          }
          current = inner;
          continue;
        }
        return current;
      }
    }

    return dive(this);
  }

  /// Safely reduces any [Outcome] chain to a single [Sync].
  ///
  /// It provides a direct way to get a raw synchronous value while collapsing
  /// all failure, empty, or asynchronous states into an [Err].
  ///
  /// ### Example
  /// ```dart
  /// final success = Ok(Some(42)).rawSync();      // Contains Ok(42)
  /// final empty = Ok(None<int>()).rawSync();   // Contains Err(...)
  /// final failed = Err('fail').rawSync();      // Contains Err('fail')
  /// final isAsync = Async(() => 1).rawSync(); // Contains Err(...)
  /// ```
  Sync rawSync() {
    return Sync(() {
      final value = raw(
        onErr: (err) => err,
        onNone: () => Err('The Outcome resolved to a None (empty) state!'),
      );
      if (value is Future) {
        throw Err(
          'The Outcome contains an asynchronous value! Use rawAsync instead.',
        );
      }
      if (value is Err) {
        throw value;
      }
      return value;
    });
  }

  /// Reduces any [Outcome] chain to a single [Async].
  ///
  /// It provides a direct way to get a raw value while collapsing
  /// all failure and empty states into an [Err].
  ///
  /// ### Example
  /// ```dart
  /// final result = await Async(() => 'hello').rawAsync().value; // Ok('hello')
  /// final emptyResult = await Some(None<int>()).rawAsync().value; // Err(...)
  /// ```
  Async rawAsync() {
    return Async(() async {
      final value = await raw(
        onErr: (err) => err,
        onNone: () => Err('The Outcome resolved to a None (empty) state!'),
      );
      if (value is Err) {
        throw value;
      }
      return value;
    });
  }

  /// **Strongly discouraged:** Unsafely returns the contained value.
  ///
  /// This method is the equivalent of the `!` (bang) operator for nullable
  /// types. It subverts the safety provided by the [Outcome] by throwing an
  /// exception instead of allowing you to handle the failure state through
  /// the type system. A thrown exception from `unwrap()` should be considered a
  /// critical programming error.
  ///
  /// ---
  /// ### ⚠️ DANGER
  ///
  /// This method will throw an [Err] if the [Outcome] is in a failure state
  /// ([Err] or [None]).
  ///
  /// ---
  /// ### Prefer Safer Alternatives:
  ///
  /// #### 1. To handle both success and failure cases:
  /// Use pattern matching with a `switch` expression. This is the most
  /// idiomatic and safest way to handle all possibilities.
  ///
  /// ```dart
  /// // For a Result<T>
  /// switch (myResult) {
  ///   case Ok(value: final data):
  ///     print('Success: $data');
  ///   case Err(error: final e):
  ///     print('Failure: $e');
  /// }
  ///
  /// // For an Option<T>
  /// switch (myOption) {
  ///   case Some(value: final data):
  ///     print('Found: $data');
  ///   case None():
  ///     print('Not found.');
  /// }
  /// ```
  ///
  /// #### 2. To provide a fallback value:
  /// Use [unwrapOr] to safely get the value or a default if it's absent.
  ///
  /// ```dart
  /// final user = findUser(id).unwrapOr(GuestUser());
  /// ```
  ///
  /// #### 3. To perform a side-effect only on success:
  /// Use `ifOk()` or `ifSome()` to run code without breaking the chain.
  ///
  /// ```dart
  //.   myResult.ifOk((ok) => logSuccess(ok.value));
  /// ```
  ///
  /// #### When is it okay to use `unwrap()`?
  /// The only acceptable time is within a test or a trusted context where a
  /// failure is a logic bug that *should* crash the test or program.
  /// Even then, it is best to wrap it in an `UNSAFE` block to signal this
  /// explicit breach of safety.
  ///
  /// ```dart
  /// final value = UNSAFE(() => Ok(1).unwrap()); // Signals deliberate unsafe access
  /// ```
  @unsafeOrError
  FutureOr<T> unwrap();

  /// Returns the contained value, or the `fallback` if the [Outcome] is in an
  /// [Err] or [None] state.
  FutureOr<T> unwrapOr(T fallback);

  /// Transforms the contained value using the mapper function
  /// [noFutures] while preserving the [Outcome]'s structure.
  ///
  /// ### Throw behaviour
  ///
  /// `map` absorbs throws into [Err] when the receiver's *static* type has
  /// somewhere to put one (any [Result]/[Resolvable]-shaped chain). On
  /// [Option] subtypes ([Some], [None]) the return type does not include an
  /// [Err] variant, so a throwing callback escapes to the caller — use
  /// [fold] or [transf] for fallible Option transformations.
  Outcome<R> map<R extends Object>(@noFutures R Function(T value) noFutures);

  /// Transforms the [Outcome]'s generic type from `T` to `R`.
  ///
  /// Uses the transformer function [noFutures] if provided, otherwise
  /// attempts a direct cast.
  Outcome transf<R extends Object>([@noFutures R Function(T e)? noFutures]);

  /// Suppresses the linter error `must_use_outcome`. Returns [void] in every
  /// subtype — calling `.end()` is the "I am intentionally discarding this
  /// Outcome" marker, so the call site never needs to think about a Future.
  /// For [Async] this means the underlying future is detached internally via
  /// `unawaited(...)`; if you actually need to await completion, use `.value`.
  void end();

  @override
  @pragma('vm:prefer-inline')
  List<Object?> get props => [value];

  @override
  @pragma('vm:prefer-inline')
  bool? get stringify => false;
}
