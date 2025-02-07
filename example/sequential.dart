// Example:
//
// Dealing with sync and/or async functions back-to-back in a safe and
// functional manner.

import 'dart:async';

import 'package:df_safer_dart/df_safer_dart.dart';

void main() async {
  final sequential = Sequential();
  print(sequential.isEmpty);
  sequential
    ..add(f1)
    ..add(f2)
    ..add(f3)
    ..add(f4)
    ..add(f5);
  print(sequential.isEmpty);
  // ignore: invalid_use_of_visible_for_testing_member
  await sequential.last.value;
  print(sequential.isEmpty);
}

Future<Option> f1(_) async {
  await Future<void>.delayed(const Duration(seconds: 2));
  print(1);
  return const None();
}

Future<Option> f2(_) async {
  await Future<void>.delayed(const Duration(seconds: 1));
  print(2);
  return const None();
}

Option f3(_) {
  print(3);
  return const None();
}

Option f4(_) {
  print(4);
  return const None();
}

Future<Option> f5(_) async {
  await Future<void>.delayed(const Duration(seconds: 1));
  print(5);
  return const None();
}
