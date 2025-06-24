// import 'package:df_safer_dart/df_safer_dart.dart';

// void main() async {
//   print('Starting sequence...');
//   await sequencer.pushTask(handlerA).end();
//   print('Sequence finished.');

//   // The final execution order should be sequential, not interleaved.
//   print('Execution Order: $executionOrder');
//   // Expected: [A starts, A ends, B starts, B ends, C starts and ends]
// }

// final executionOrder = <String>[];
// final sequencer = SeriesTaskExecutor<int>();

// Resolvable<Option<int>> handlerA(Result<Option<int>> previous) {
//   executionOrder.add('A starts');
//   // Re-entrant call: Schedule B to run after A is done.
//   return sequencer.pushTask(handlerB).map((e) {
//     executionOrder.add('A ends');
//     return e;
//   });
// }

// Resolvable<Option<int>> handlerB(Result<Option<int>> previous) {
//   executionOrder.add('B starts');
//   // Re-entrant call: Schedule C to run after B is done.
//   return sequencer.pushTask(handlerC).map((e) {
//     executionOrder.add('B ends');
//     return e;
//   });
// }

// Resolvable<Option<int>> handlerC(Result<Option<int>> previous) {
//   executionOrder.add('C starts and ends');
//   return Resolvable(() => const Some(3));
// }
