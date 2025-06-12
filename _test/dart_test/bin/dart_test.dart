import 'package:df_safer_dart/df_safer_dart.dart';

void main() {
  final err = Err('test');
  print(err);
  // Async(() {
  //   throw 1;
  // }).value.then((e) => e.unwrap());
}
