import 'package:df_safer_dart/df_safer_dart.dart';

void main() {
  final seq = SafeSequencer();
  seq.pushTask((_) {
    return doWait().toResolvable();
  }).end();
  seq.pushTask((_) {
    return doNotWait().toResolvable();
  }).end();
  seq.pushTask((_) {
    return doWait().toResolvable();
  }).end();
  seq.pushTask((_) {
    return doNotWait().toResolvable();
  }).end();
}

Future<None> doWait() async {
  await Future<void>.delayed(const Duration(milliseconds: 100));
  print('A');
  return const None();
}

None doNotWait() {
  print('B');
  return const None();
}
