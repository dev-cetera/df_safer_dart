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

/// Adds [.named(label)][NamedResultExt.named] to [Result] for failure
/// attribution: if the receiver is an [Err] that has not yet been labelled by
/// an upstream `.named()`, the label is recorded in [Err.breadcrumbs]. If it
/// already carries breadcrumbs (an upstream node already claimed the failure),
/// this is a no-op so the originating step keeps its credit.
extension NamedResultExt<T extends Object> on Result<T> {
  Result<T> named(String label) {
    final self = this;
    if (self is Err<T> && self.breadcrumbs.isEmpty) {
      return self.withBreadcrumbs([label]);
    }
    return this;
  }
}

/// Adds [.named(label)][NamedSyncExt.named] to [Sync] with the same semantics
/// as [NamedResultExt.named].
extension NamedSyncExt<T extends Object> on Sync<T> {
  Sync<T> named(String label) => Sync.result(value.named(label));
}

/// Adds [.named(label)][NamedAsyncExt.named] to [Async] with the same
/// semantics as [NamedResultExt.named].
extension NamedAsyncExt<T extends Object> on Async<T> {
  Async<T> named(String label) =>
      Async.result(value.then((r) => r.named(label)));
}

/// Adds [.named(label)][NamedResolvableExt.named] to [Resolvable] so both
/// [Sync] and [Async] subtypes are addressable through the base type.
extension NamedResolvableExt<T extends Object> on Resolvable<T> {
  Resolvable<T> named(String label) {
    final self = this;
    if (self is Sync<T>) return self.named(label);
    return (self as Async<T>).named(label);
  }
}
