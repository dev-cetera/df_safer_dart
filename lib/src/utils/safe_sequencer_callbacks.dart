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

import 'package:df_safer_dart_annotations/df_safer_dart_annotations.dart' show noFuturesAllowed;

import '/df_safer_dart.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

class SafeSequencerCallbacks<T extends Object, TParam extends Object> {
  //
  //
  //

  final _seq = SafeSequencer<T>();
  final _callbacks = <Object, TSafeCallback<T, TParam>>{};

  //
  //
  //

  _CallbackRemover addCallback(
    @noFuturesAllowed TSafeCallback<T, TParam> callback, {
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

  Resolvable<Option<T>> call(
    Object callbackKey,
    TParam param, {
    bool eagerError = false,
    void Function(Err err)? onError,
  }) {
    final callback = _callbacks.getOption(callbackKey);
    if (callback.isNone()) {
      return Sync.unsafe(
        Err('No callback associated with $callbackKey exists!'),
      );
    }
    return _seq.pushTask((prev) {
      if (prev.isErr()) {
        onError?.call(prev.err().unwrap());
        if (eagerError) {
          return Sync.unsafe(prev);
        }
      }
      return callback.unwrap()(callbackKey, param);
    });
  }

  //
  //
  //

  Resolvable<Map<Object, Result<Option<T>>>> callAll(
    TParam param, {
    Set<dynamic>? include,
    Set<dynamic> exclude = const {},
    bool eagerError = true,
    void Function(Err err)? onError,
  }) {
    final results = <Object, Result<Option<T>>>{};
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
          _seq.pushTask((e) {
            results[callbackKey] = e;
            return syncNone();
          }).end();
        }
      }
    }
    return _seq.last.map((e) => results);
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

typedef TSafeCallback<T extends Object, TParam extends Object> = Resolvable<Option<T>> Function(
  Object callbackKey,
  TParam param,
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
