import 'package:df_safer_dart/df_safer_dart.dart';

void main() {
  final seq = TaskSequencer();
  seq.then((_) {
    return doWait().toResolvable();
  }).end();
  seq.then((_) {
    return doNotWait().toResolvable();
  }).end();
  seq.then((_) {
    return doWait().toResolvable();
  }).end();
  seq.then((_) {
    return doNotWait().toResolvable();
  }).end();
}

// ignore: no_future_monad_type_or_error
Future<None> doWait() async {
  await Future<void>.delayed(const Duration(milliseconds: 100));
  print('A');
  return const None();
}

None doNotWait() {
  print('B');
  return const None();
}
