// Example: Using SafeCompleter for synchronous or asynchronous values.

import 'package:df_safer_dart/df_safer_dart.dart';

void main() async {
  final safeCompleter1 = SafeCompleter<int>();

  // Schedule completion of safeCompleter1 after 1 second.
  Future.delayed(const Duration(seconds: 1), () {
    safeCompleter1.complete(42);
  });

  // Process the value from safeCompleter1.resolvable.
  final concur1 = safeCompleter1.resolvable;
  if (concur1.isSync) {
    print('It is sync: ${concur1.unwrapSyncValue()}');
  } else {
    print('It is async: ${await concur1.unwrapAsyncValue()}');
  }

  final safeCompleter2 = SafeCompleter<int>();
  safeCompleter2.complete(43);

  // Process the value from safeCompleter2.resolvable.
  final concur2 = safeCompleter2.resolvable;
  if (concur2.isSync) {
    print('It is sync: ${concur2.unwrapSyncValue()}');
  } else {
    print('It is async: ${await concur2.unwrapAsyncValue()}');
  }
}
