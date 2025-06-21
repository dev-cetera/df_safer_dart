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

@pragma('vm:prefer-inline')
Sync<None<T>> syncNone<T extends Object>() => const Sync.unsafe(Ok(None()));

@pragma('vm:prefer-inline')
Async<None<T>> asyncNone<T extends Object>() => Async.unsafe(Future.value(Ok(None<T>())));

@pragma('vm:prefer-inline')
Resolvable<None<T>> resolvableNone<T extends Object>() => syncNone();

@pragma('vm:prefer-inline')
Sync<Unit> syncUnit() => Sync.unsafe(Ok(Unit()));

@pragma('vm:prefer-inline')
Async<Unit> asyncUnit() => Async.unsafe(Future.value(Ok(Unit())));

@pragma('vm:prefer-inline')
Resolvable<Unit> resolvableUnit() => syncUnit();

typedef TReduced<T extends Object> = Resolvable<Option<T>>;
typedef TOptionResult<T extends Object> = Option<Result<T>>;
