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

import 'dart:async';

import '/src/_src.g.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

const NONE = None<Never>();

const SYNC_NONE = TSyncNone.unsafe(Ok(None<Never>()));

const TResolvableNone<Never> RESOLVABLE_NONE = SYNC_NONE;

@pragma('vm:prefer-inline')
Sync<None<T>> syncNone<T extends Object>() =>
    const TSyncNone.unsafe(Ok(None()));

@pragma('vm:prefer-inline')
Async<None<T>> asyncNone<T extends Object>() =>
    TAsyncNone.unsafe(Future.value(Ok(None<T>())));

@pragma('vm:prefer-inline')
Resolvable<None<T>> resolvableNone<T extends Object>() => syncNone();

typedef TReduced<T extends Object> = Resolvable<Option<T>>;
typedef TOptionResult<T extends Object> = Option<Result<T>>;
typedef TResolvableNone<T extends Object> = Resolvable<None<T>>;
typedef TSyncNone<T extends Object> = Sync<None<T>>;
typedef TAsyncNone<T extends Object> = Async<None<T>>;
typedef TResolvableSome<T extends Object> = Resolvable<Some<T>>;
typedef TSyncSome<T extends Object> = Sync<Some<T>>;
typedef TAsyncSome<T extends Object> = Async<Some<T>>;
