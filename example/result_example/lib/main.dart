import 'package:df_safer_dart/df_safer_dart.dart';

// A function that parses a string to an integer, with ZERO try-catch blocks.
// It returns a Sync, which holds a Result<int>.
Sync<int> parseInt(String value) {
  // The Sync Outcome executes this function.
  // - If int.parse() succeeds, it returns Ok(result).
  // - If int.parse() throws a FormatException, Sync catches it and returns Err(exception).
  return Sync(() => int.parse(value));
}

void main() {
  final syncResult =
      parseInt('100') // This returns a Sync<int> holding an Ok(100)
          .map((number) => number * 2); // .map only runs on the Ok value

  final result1 = syncResult.value; // This returns a Result<int>

  switch (result1) {
    case Ok(value: final number):
      print('Result: $number');
    case Err():
      print('Failed to parse');
  }
  final result2 = parseInt('Hello!').map((number) => number * 2).value;

  switch (result2) {
    case Ok(value: final number):
      print('Result: $number');
    case Err err:
      print('Failed to parse: ${err.error}');
  }
}
