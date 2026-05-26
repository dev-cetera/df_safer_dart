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

/// An extension on [Stream] to provide a safe way to handle stream events.
extension ToSafeStreamExt<T extends Object> on Stream<T> {
  /// Transforms a [Stream] into a [Stream].
  ///
  /// Each data event from the original stream is wrapped in an [Ok].
  /// Each error event is wrapped in an [Err].
  ///
  /// If [cancelOnError] is `true`, the stream will be closed upon the first
  /// error.
  TResultStream<T> toSafeStream({required bool cancelOnError}) {
    return transform(
      StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          sink.add(Ok(data));
        },
        handleError: (error, stackTrace, sink) {
          if (error is Err) {
            sink.add(error.transfErr());
          } else {
            // Forward the trace handed to us by the upstream stream — a
            // life-critical audit trail can't reconstruct where the error
            // originated from a trace captured at the Err() call site.
            sink.add(Err<T>(error, stackTrace: stackTrace));
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
