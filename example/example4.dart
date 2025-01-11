// Example: Using Concur to deal with either a sync or async value.

import 'package:df_safer_dart/df_safer_dart.dart';

void main() async {
  print(await Future.value(1).then((value) {
    throw 3;
    return 1;
  }).catchError((e) => 33));

  final seq = SafeSeq();
  print('0');
  final a = seq.addAll<Object>(
    [
      (previous) {
        print('1');
        return const Sync(None());
      },
      (previous) => Concur.unsafe(
            () async {
              await Future<void>.delayed(const Duration(seconds: 1));
              print('2');
              return const None();
            },
          ),
      (previous) {
        print('3');
        return const Sync(None());
      },
    ],
  );
  await a.last.value;
  print('5');
}
