// Example:
//
// Dealing with sync and/or async functions back-to-back in a safe and
// functional manner.

// ignore_for_file: body_might_complete_normally_nullable

import 'dart:async';

import 'package:df_safer_dart/df_safer_dart.dart';

void main() async {
  final sequential = SafeSequential();
  print(sequential.isEmpty);
  sequential
    ..add(
      unsafe: (previous) {
        throw 1;
      },
    )
    ..add(
      unsafe: (previous) async {
        print(previous);
        await Future<void>.delayed(const Duration(seconds: 1));
        print(2);
      },
    )
    ..add(
      unsafe: (previous) {
        print(3);
      },
    )
    ..add(
      unsafe: (previous) {
        print(4);
      },
    )
    ..add(
      unsafe: (previous) {
        print(5);
      },
    );
  print(sequential.isEmpty);
  // ignore: invalid_use_of_visible_for_testing_member
  await sequential.last.value;
  print(sequential.isEmpty);
}
