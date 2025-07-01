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

const OK_UNIT = Ok(UNIT);
const SOME_UNIT = Some(UNIT);
const NONE_UNIT = None<Unit>();

@pragma('vm:prefer-inline')
Sync<Unit> syncUnit() => Sync.okValue(Unit());

@pragma('vm:prefer-inline')
Sync<None<T>> syncNone<T extends Object>() => Sync.okValue(const None());

@pragma('vm:prefer-inline')
Sync<Some<T>> syncSome<T extends Object>(T value) => Sync.okValue(Some(value));

@pragma('vm:prefer-inline')
Async<Unit> asyncUnit() => Async.okValue(Unit());

@pragma('vm:prefer-inline')
Async<None<T>> asyncNone<T extends Object>() => Async.okValue(const None());

@pragma('vm:prefer-inline')
Async<Some<T>> asyncSome<T extends Object>(FutureOr<T> value) {
  assert(!isSubtype<T, Future<Object>>(), '$T must never be a Future.');
  return Async(() async => Some(await value));
}

@pragma('vm:prefer-inline')
Resolvable<None<T>> resolvableNone<T extends Object>() => syncNone();

@pragma('vm:prefer-inline')
Resolvable<Some<T>> resolvableSome<T extends Object>(T value) =>
    syncSome(value);

@pragma('vm:prefer-inline')
Resolvable<Unit> resolvableUnit() => syncUnit();
