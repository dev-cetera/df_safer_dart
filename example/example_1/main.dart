import 'package:df_safer_dart/df_safer_dart.dart';

// A function that might not find a user.
Option<String> findUsername(int id) {
  final users = {1: 'Alice', 2: 'Bob'};
  final username = users[id];
  // Option.fromNullable handles the null check for us.
  return Option.fromNullable(username);
}

void main() {
  // Chaining operations:
  final result = findUsername(1) // This returns Some('Alice')
      .map((name) => name.toUpperCase()); // .map only runs if it's a Some

// Prints "Username is: ALICE"
  switch (result) {
    case Some(value: final name):
      print('Username is: $name');
    case None():
      print('User not found.');
  }
}
