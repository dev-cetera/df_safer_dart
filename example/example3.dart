// Example: Using Concur to deal with either a sync or async value.

import 'package:df_safer_dart/df_safer_dart.dart';

void main() async {
  final string = const Sync(Ok('Hello World!'));
  final string1 = stringMapper(string);
  print(string1.uwSyncValue());

  final futureString = Concur.tryCatch(
    () => Future.delayed(const Duration(seconds: 1), () => 'Hello World!'),
  );
  final futureString1 = stringMapper(futureString);
  print(await futureString1.uwAsyncValue());
}

Concur<String> stringMapper(Concur<String> input) {
  return input.map((e) => e.map((e) => e.toUpperCase()));
}
