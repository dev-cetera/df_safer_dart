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

/// The foundational sealed class for all monadic types like [Option], [Result],
/// and [Resolvable].
sealed class Monad<T extends Object> implements Equatable {
  const Monad(this.value);

  final FutureOr<Object> value;

  /// Reduces any nested [Monad] structure into a single [TResolvableOption].
  ///
  /// This flattens all [Monad] layers ([Option], [Result], [Resolvable]) into
  /// a final container that is always a [Resolvable] holding an [Option].
  /// An [Err] state at any level will result in a failed [Resolvable].
  TResolvableOption<R> reduce<R extends Object>() {
    return switch (this) {
      Some(value: final someValue) => Resolvable(() => Some(someValue as R)),
      Some(value: Monad<Object> monadValue) => monadValue.reduce<R>(),
      None() => syncNone<R>(),
      Ok(value: final someValue) => Resolvable(() => Some(someValue as R)),
      Ok(value: Monad<Object> monadValue) => monadValue.reduce<R>(),
      Err(error: final error) => Sync.err(Err(error)),
      Sync(value: final result) => result.reduce<R>(),
      Async(value: final futureResult) => Async<Option<R>>(() async {
          final result = await futureResult;
          final innerResolvable = result.reduce<R>();
          return (await innerResolvable.value).unwrap();
        }),
    };
  }

  /// The low-level primitive for reducing a [Monad] chain. It recursively
  /// unwraps all [Monad] layers to return the innermost raw value, forcing the
  /// caller to handle terminal states via callbacks.
  ///
  /// - [onErr]: A function that is called when an [Err] is encountered.
  /// - [onNone]: A function that is called when a [None] is encountered.
  FutureOr<Object> raw({
    required FutureOr<Object> Function(Err<Object> err) onErr,
    required FutureOr<Object> Function() onNone,
  }) {
    FutureOr<Object> dive(Object obj) {
      return switch (obj) {
        Err() => onErr(obj),
        None() => onNone(),
        Monad(value: final okValue) =>
          okValue is Future<Object> ? okValue.then(dive) : dive(okValue),
        Object() => obj,
      };
    }

    return dive(this);
  }

  /// Safely reduces any [Monad] chain to a single [Sync].
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
      // ignore: no_futures
      final value = raw(
        onErr: (err) => err,
        onNone: () => Err('The Monad resolved to a None (empty) state!'),
      );
      if (value is Future) {
        throw Err(
          'The Monad contains an asynchronous value! Use rawAsync instead.',
        );
      }
      if (value is Err) {
        throw value;
      }
      return value;
    });
  }

  /// Reduces any [Monad] chain to a single [Async].
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
        onNone: () => Err('The Monad resolved to a None (empty) state!'),
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
  /// types. It subverts the safety provided by the [Monad] by throwing an
  /// exception instead of allowing you to handle the failure state through
  /// the type system. A thrown exception from `unwrap()` should be considered a
  /// critical programming error.
  ///
  /// ---
  /// ### ⚠️ DANGER
  ///
  /// This method will throw an [Err] if the [Monad] is in a failure state
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

  /// Returns the contained value, or the `fallback` if the [Monad] is in an
  /// [Err] or [None] state.
  FutureOr<T> unwrapOr(T fallback);

  /// Transforms the contained value using the mapper function
  /// [noFutures] while preserving the [Monad]'s structure.
  Monad<R> map<R extends Object>(
    @noFutures R Function(T value) noFutures,
  );

  /// Transforms the [Monad]'s generic type from `T` to `R`.
  ///
  /// Uses the transformer function [noFutures] if provided, otherwise
  /// attempts a direct cast.
  Monad transf<R extends Object>([
    @noFutures R Function(T e)? noFutures,
  ]);

  /// Suppresses the linter error `must_use_monad`.
  FutureOr<void> end();

  @override
  @pragma('vm:prefer-inline')
  List<Object?> get props => [value];

  @override
  @pragma('vm:prefer-inline')
  bool? get stringify => false;
}
