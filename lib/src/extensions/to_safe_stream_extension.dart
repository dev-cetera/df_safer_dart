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
import '../monads/monad.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// An extension on [Stream] to provide a safe way to handle stream events.
extension ToSafeStreamExtension<T extends Object> on Stream<T> {
  /// Transforms a [Stream<T>] into a [Stream<Result<T>>].
  ///
  /// Each data event from the original stream is wrapped in an [Ok<T>].
  /// Each error event is wrapped in an [Err<T>].
  ///
  /// If [cancelOnError] is `true`, the stream will be closed upon the first
  /// error.
  Stream<Result<T>> toSafeStream({required bool cancelOnError}) {
    return transform(
      StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          sink.add(Ok(data));
        },
        handleError: (error, stackTrace, sink) {
          if (error is Err) {
            sink.add(error.transf());
          } else {
            sink.add(Err<T>(error));
          }
          if (cancelOnError) {
            sink.close();
          }
        },
        handleDone: (sink) {
          sink.close();
        },
      ),
    );
  }
}
