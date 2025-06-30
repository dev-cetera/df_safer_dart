import 'package:df_safer_dart/df_safer_dart.dart';

void main() {
  print(const Ok<int>(1).value); // 1
  print(const Ok<int>(1).value.runtimeType); // int
  print(Err<int>('Oh no!').error); // Oh no!
  print(Err<int>('Oh no!').error.runtimeType); // String
  print(Option.from('Hello World!').value); // Hello World!
  print(Option.from('Hello World!').value.runtimeType); // String
  print(const Some('Hello World!').value); // Hello World!
  print(const Some('Hello World!').value.runtimeType); // String
  print(const None<String>().value); // Unit()
  print(const None<String>().value.runtimeType); // Unit
}
