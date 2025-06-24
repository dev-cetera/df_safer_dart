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

import '/_common.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
//
// Option Combinations
//
// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// Represents an `Option` that contains a `Result`.
typedef TOptionResult<T extends Object> = Option<Result<T>>;

/// Represents an `Option` that contains an `Ok`.
typedef TOptionOk<T extends Object> = Option<Ok<T>>;

/// Represents an `Option` that contains an `Err`.
typedef TOptionErr<T extends Object> = Option<Err<T>>;

/// Represents an `Option` that contains a `Resolvable`.
typedef TOptionResolvable<T extends Object> = Option<Resolvable<T>>;

/// Represents an `Option` that contains a `Sync`.
typedef TOptionSync<T extends Object> = Option<Sync<T>>;

/// Represents an `Option` that contains an `Async`.
typedef TOptionAsync<T extends Object> = Option<Async<T>>;

/// Represents a nested `Option`.
typedef TOptionOption<T extends Object> = Option<Option<T>>;

/// Represents an `Option` that contains a `Some`.
typedef TOptionSome<T extends Object> = Option<Some<T>>;

/// Represents an `Option` that contains a `None`.
typedef TOptionNone<T extends Object> = Option<None<T>>;

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
//
// Result Combinations
//
// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// Represents a `Result` that contains an `Option`.
typedef TResultOption<T extends Object> = Result<Option<T>>;

/// Represents a `Result` that contains a `Some`.
typedef TResultSome<T extends Object> = Result<Some<T>>;

/// Represents a `Result` that contains a `None`.
typedef TResultNone<T extends Object> = Result<None<T>>;

/// Represents a `Result` that contains a `Resolvable`.
typedef TResultResolvable<T extends Object> = Result<Resolvable<T>>;

/// Represents a `Result` that contains a `Sync`.
typedef TResultSync<T extends Object> = Result<Sync<T>>;

/// Represents a `Result` that contains an `Async`.
typedef TResultAsync<T extends Object> = Result<Async<T>>;

/// Represents a nested `Result`.
typedef TResultResult<T extends Object> = Result<Result<T>>;

/// Represents a `Result` that contains an `Ok`.
typedef TResultOk<T extends Object> = Result<Ok<T>>;

/// Represents a `Result` that contains an `Err`.
typedef TResultErr<T extends Object> = Result<Err<T>>;

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
//
// Resolvable Combinations
//
// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// Represents a `Resolvable` that contains an `Option`.
typedef TResolvableOption<T extends Object> = Resolvable<Option<T>>;

/// Represents a `Resolvable` that contains a `Some`.
typedef TResolvableSome<T extends Object> = Resolvable<Some<T>>;

/// Represents a `Resolvable` that contains a `None`.
typedef TResolvableNone<T extends Object> = Resolvable<None<T>>;

/// Represents a `Resolvable` that contains a `Result`.
typedef TResolvableResult<T extends Object> = Resolvable<Result<T>>;

/// Represents a `Resolvable` that contains an `Ok`.
typedef TResolvableOk<T extends Object> = Resolvable<Ok<T>>;

/// Represents a `Resolvable` that contains an `Err`.
typedef TResolvableErr<T extends Object> = Resolvable<Err<T>>;

/// Represents a nested `Resolvable`.
typedef TResolvableResolvable<T extends Object> = Resolvable<Resolvable<T>>;

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
//
// Sync Combinations
//
// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// Represents a `Sync` that contains an `Option`.
typedef TSyncOption<T extends Object> = Sync<Option<T>>;

/// Represents a `Sync` that contains a `Some`.
typedef TSyncSome<T extends Object> = Sync<Some<T>>;

/// Represents a `Sync` that contains a `None`.
typedef TSyncNone<T extends Object> = Sync<None<T>>;

/// Represents a `Sync` that contains a `Result`.
typedef TSyncResult<T extends Object> = Sync<Result<T>>;

/// Represents a `Sync` that contains an `Ok`.
typedef TSyncOk<T extends Object> = Sync<Ok<T>>;

/// Represents a `Sync` that contains an `Err`.
typedef TSyncErr<T extends Object> = Sync<Err<T>>;

/// Represents a `Sync` that contains a `Resolvable`.
typedef TSyncResolvable<T extends Object> = Sync<Resolvable<T>>;

/// Represents a nested `Sync`.
typedef TSyncSync<T extends Object> = Sync<Sync<T>>;

/// Represents a `Sync` that contains an `Async`.
typedef TSyncAsync<T extends Object> = Sync<Async<T>>;

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
//
// Async Combinations
//
// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// Represents an `Async` that contains an `Option`.
typedef TAsyncOption<T extends Object> = Async<Option<T>>;

/// Represents an `Async` that contains a `Some`.
typedef TAsyncSome<T extends Object> = Async<Some<T>>;

/// Represents an `Async` that contains a `None`.
typedef TAsyncNone<T extends Object> = Async<None<T>>;

/// Represents an `Async` that contains a `Result`.
typedef TAsyncResult<T extends Object> = Async<Result<T>>;

/// Represents an `Async` that contains an `Ok`.
typedef TAsyncOk<T extends Object> = Async<Ok<T>>;

/// Represents an `Async` that contains an `Err`.
typedef TAsyncErr<T extends Object> = Async<Err<T>>;

/// Represents an `Async` that contains a `Resolvable`.
typedef TAsyncResolvable<T extends Object> = Async<Resolvable<T>>;

/// Represents an `Async` that contains a `Sync`.
typedef TAsyncSync<T extends Object> = Async<Sync<T>>;

/// Represents a nested `Async`.
typedef TAsyncAsync<T extends Object> = Async<Async<T>>;

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
//
// Some Combinations
//
// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// Represents a `Some` that contains a `Result`.
typedef TSomeResult<T extends Object> = Some<Result<T>>;

/// Represents a `Some` that contains an `Ok`.
typedef TSomeOk<T extends Object> = Some<Ok<T>>;

/// Represents a `Some` that contains an `Err`.
typedef TSomeErr<T extends Object> = Some<Err<T>>;

/// Represents a `Some` that contains a `Resolvable`.
typedef TSomeResolvable<T extends Object> = Some<Resolvable<T>>;

/// Represents a `Some` that contains a `Sync`.
typedef TSomeSync<T extends Object> = Some<Sync<T>>;

/// Represents a `Some` that contains an `Async`.
typedef TSomeAsync<T extends Object> = Some<Async<T>>;

/// Represents a `Some` that contains an `Option`.
typedef TSomeOption<T extends Object> = Some<Option<T>>;

/// Represents a nested `Some`.
typedef TSomeSome<T extends Object> = Some<Some<T>>;

/// Represents a `Some` that contains a `None`.
typedef TSomeNone<T extends Object> = Some<None<T>>;

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
//
// Ok Combinations
//
// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// Represents an `Ok` that contains an `Option`.
typedef TOkOption<T extends Object> = Ok<Option<T>>;

/// Represents an `Ok` that contains a `Some`.
typedef TOkSome<T extends Object> = Ok<Some<T>>;

/// Represents an `Ok` that contains a `None`.
typedef TOkNone<T extends Object> = Ok<None<T>>;

/// Represents an `Ok` that contains a `Resolvable`.
typedef TOkResolvable<T extends Object> = Ok<Resolvable<T>>;

/// Represents an `Ok` that contains a `Sync`.
typedef TOkSync<T extends Object> = Ok<Sync<T>>;

/// Represents an `Ok` that contains an `Async`.
typedef TOkAsync<T extends Object> = Ok<Async<T>>;

/// Represents an `Ok` that contains a `Result`.
typedef TOkResult<T extends Object> = Ok<Result<T>>;

/// Represents a nested `Ok`.
typedef TOkOk<T extends Object> = Ok<Ok<T>>;

/// Represents an `Ok` that contains an `Err`.
typedef TOkErr<T extends Object> = Ok<Err<T>>;

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
//
// Err Combinations
//
// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// Represents an `Err` that contains an `Option`.
typedef TErrOption<T extends Object> = Err<Option<T>>;

/// Represents an `Err` that contains a `Some`.
typedef TErrSome<T extends Object> = Err<Some<T>>;

/// Represents an `Err` that contains a `None`.
typedef TErrNone<T extends Object> = Err<None<T>>;

/// Represents an `Err` that contains a `Resolvable`.
typedef TErrResolvable<T extends Object> = Err<Resolvable<T>>;

/// Represents an `Err` that contains a `Sync`.
typedef TErrSync<T extends Object> = Err<Sync<T>>;

/// Represents an `Err` that contains an `Async`.
typedef TErrAsync<T extends Object> = Err<Async<T>>;

/// Represents an `Err` that contains a `Result`.
typedef TErrResult<T extends Object> = Err<Result<T>>;

/// Represents an `Err` that contains an `Ok`.
typedef TErrOk<T extends Object> = Err<Ok<T>>;

/// Represents a nested `Err`.
typedef TErrErr<T extends Object> = Err<Err<T>>;
