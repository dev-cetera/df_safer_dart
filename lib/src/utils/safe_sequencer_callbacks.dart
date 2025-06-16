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

import 'package:df_safer_dart_annotations/df_safer_dart_annotations.dart' show noFuturesAllowed;

import '/df_safer_dart.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

class SafeSequencerCallbacks<TParam extends Object> {
  //
  //
  //

  final _seq = SafeSequencer();
  final _callbacks = <Object, TSafeCallback<TParam>>{};

  //
  //
  //

  _CallbackRemover addCallback(
    @noFuturesAllowed TSafeCallback<TParam> callback, {
    Object? callbackKey,
  }) {
    final key = callbackKey ?? callback;
    _callbacks[key] = callback;
    return _CallbackRemover(() => _callbacks.remove(key));
  }

  //
  //
  //

  bool callbackExists(dynamic callbackKey) => _callbacks.containsKey(callbackKey);

  //
  //
  //

  bool removeCallback(Object callbackKey) => _callbacks.remove(callbackKey) != null;

  //
  //
  //

  void clearCallbacks() => _callbacks.clear();

  //
  //
  //

  Resolvable<Option<Object>> call(
    Object callbackKey,
    TParam param, {
    bool eagerError = false,
    dynamic Function(Err err)? onError,
  }) {
    final callback = _callbacks.getOption(callbackKey);
    if (callback.isNone()) {
      return Sync.value(
        Err('No callback associated with $callbackKey exists!'),
      );
    }
    return _seq.addSafe((prev) {
      if (prev.isErr()) {
        onError?.call(prev.err().unwrap());
        if (eagerError) {
          return Sync.value(prev);
        }
      }
      return callback.unwrap()(callbackKey, param);
    });
  }

  //
  //
  //

  Resolvable<Map<Object, Result<Option<Object>>>> callAll(
    TParam param, {
    Set<dynamic>? include,
    Set<dynamic> exclude = const {},
    bool eagerError = true,
    dynamic Function(Err err)? onError,
  }) {
    final results = <Object, Result<Option<Object>>>{};
    for (final e in _callbacks.entries) {
      if (include == null || include.contains(e)) {
        if (exclude.isEmpty || !exclude.contains(e)) {
          final callbackKey = e.key;
          call(
            callbackKey,
            param,
            eagerError: eagerError,
            onError: onError,
          ).end();
          _seq.addSafe((e) {
            results[callbackKey] = e;
            return const Sync.unsafe(Ok(None()));
          }).end();
        }
      }
    }
    return _seq.addSafe((_) {
      return Sync.value(Ok(Some(results)));
    }).map((e) => e.unwrap());
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

typedef TSafeCallback<T> = Resolvable<Option<Object>> Function(
  Object callbackKey,
  T param,
);

class _CallbackRemover {
  final void Function() _remover;
  bool _didRemove = false;
  _CallbackRemover(this._remover);

  void remove() {
    assert(!_didRemove, 'Callback already removed!');
    if (_didRemove) return;
    _didRemove = true;
    _remover();
  }
}
