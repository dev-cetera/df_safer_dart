// //.title
// // ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
// //
// // Dart/Flutter (DF) Packages by dev-cetera.com & contributors. The use of this
// // source code is governed by an MIT-style license described in the LICENSE
// // file located in this project's root directory.
// //
// // See: https://opensource.org/license/mit
// //
// // ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
// //.title~

// import 'concur.dart';
// import 'option.dart';

// // ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

// /// A queue that manages the execution of functions sequentially, allowing for
// /// optional throttling.
// class SafeSeq {
//   //
//   //
//   //

//   final Option<Duration> _buffer;

//   /// The current value or future in the queue.
//   Option<Concur<Option>> _current = const None();

//   /// Indicates whether the queue is empty or processing.
//   bool get isEmpty => _isEmpty;
//   bool _isEmpty = true;

//   //
//   //
//   //

//   /// Creates an [SafeSeq] with an optional [buffer] for throttling
//   /// execution.
//   SafeSeq({
//     Duration? buffer,
//   }) : _buffer = Option.fromNullable(buffer);

//   /// Adds a [function] to the queue that processes the previous value.
//   /// Applies an optional [buffer] duration to throttle the execution.
//   ConcurOp<T> add<T extends Object>(
//     ConcurOp<T> Function(Option previous) function, {
//     Duration? buffer,
//   }) {
//     final buffer1 = Option<Duration>.fromNullable(buffer).or(_buffer).cast<Duration>().unwrap();
//     if (buffer1.isNone) {
//       return _enqueue<T>(function);
//     } else {
//       return _enqueue<T>((previous) {
//         return Concur(
//           Future.wait<Object>([
//             Future.value(function(previous)),
//             Future.delayed(buffer1.unwrap()),
//           ]).then((e) => e.first as Option<T>),
//         );
//       });
//     }
//   }

//   /// Adds multiple [functions] to the queue for sequential execution. See
//   /// [add].
//   List<ConcurOp<T>> addAll<T extends Object>(
//     Iterable<ConcurOp<T> Function(Option previous)> functions, {
//     Duration? buffer,
//   }) {
//     final results = <ConcurOp<T>>[];
//     for (final function in functions) {
//       results.add(add(function, buffer: buffer));
//     }
//     return results;
//   }

//   /// Eenqueue a [function] without buffering.
//   ConcurOp<T> _enqueue<T extends Object>(ConcurOp<T> Function(Option previous) function) {
//     _isEmpty = false;
//     final temp = _current.fold((e) => e.flatMap(function), () => function(const None())).map((e) {
//       _isEmpty = true;
//       return e;
//     });

//     _current = Option.fromNullable(temp);
//     return temp;
//   }

//   /// Retrieves the last value in the queue without altering the queue.
//   Concur<Option> get last => add<Option>((e) => const Sync(None()));

//   /// Indicates whether the last value in the queue is a [Future]. Use
//   /// [isEmpty] instead to check if the queue is empty.
//   bool get hasLast => last is Future;
// }

// // ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

// typedef ConcurOp<T extends Object> = Concur<Option<T>>;
