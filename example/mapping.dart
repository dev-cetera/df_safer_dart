// // Example:
// //
// // Using Resolvable to deal with either a sync or async value.

// import 'package:df_safer_dart/df_safer_dart.dart';

// void main() async {
//   final string = const Sync(Ok('Hello World!'));
//   final string1 = stringMapper(string);
//   // ignore: invalid_use_of_visible_for_testing_member
//   print(string1.unwrapSyncValue());

//   final futureString = Resolvable.unsafe(
//     () => Future.delayed(const Duration(seconds: 1), () => 'Hello World!'),
//   );
//   final futureString1 = stringMapper(futureString);
//   // ignore: invalid_use_of_visible_for_testing_member
//   print(await futureString1.unwrapAsyncValue());
// }

// Resolvable<String> stringMapper(Resolvable<String> input) {
//   return input.map((e) => e.toUpperCase());
// }
