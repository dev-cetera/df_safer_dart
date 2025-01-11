// Example: Using SafeCompleter for synchronous or asynchronous values.

import 'package:df_safer_dart/df_safer_dart.dart';

void main() async {
  final safeCompleter1 = SafeCompleter<int>();

  // Schedule completion of safeCompleter1 after 1 second.
  Future.delayed(const Duration(seconds: 1), () {
    safeCompleter1.complete(42);
  });

  // Process the value from safeCompleter1.concur.
  final concur1 = safeCompleter1.concur;
  if (concur1.isSync) {
    print('It is sync: ${concur1.uwSyncValue()}');
  } else {
    print('It is async: ${await concur1.uwAsyncValue()}');
  }

  final safeCompleter2 = SafeCompleter<int>();
  safeCompleter2.complete(43);

  // Process the value from safeCompleter2.concur.
  final concur2 = safeCompleter2.concur;
  if (concur2.isSync) {
    print('It is sync: ${concur2.uwSyncValue()}');
  } else {
    print('It is async: ${await concur2.uwAsyncValue()}');
  }
}
