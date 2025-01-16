// Example:
//
// Unlike Completer, SafeCompleter can be used to manage both sync and async
// values, and in a safe functional manner.

import 'package:df_safer_dart/df_safer_dart.dart';

void main() async {
  final safeCompleter1 = SafeCompleter<int>();

  // Schedule completion of safeCompleter1 after 1 second.
  Future.delayed(const Duration(seconds: 1), () {
    safeCompleter1.complete(42);
  });

  // Process the value from safeCompleter1.resolvable.
  final r1 = safeCompleter1.resolvable;
  if (r1.isSync()) {
    // ignore: invalid_use_of_visible_for_testing_member
    print('It is sync: ${r1.unwrapSyncValue()}');
  } else {
    // ignore: invalid_use_of_visible_for_testing_member
    print('It is async: ${await r1.unwrapAsyncValue()}');
  }

  final safeCompleter2 = SafeCompleter<int>();
  safeCompleter2.complete(43);

  // Process the value from safeCompleter2.resolvable.
  final r2 = safeCompleter2.resolvable;
  if (r2.isSync()) {
    // ignore: invalid_use_of_visible_for_testing_member
    print('It is sync: ${r2.unwrapSyncValue()}');
  } else {
    // ignore: invalid_use_of_visible_for_testing_member
    print('It is async: ${await r2.unwrapAsyncValue()}');
  }
}
