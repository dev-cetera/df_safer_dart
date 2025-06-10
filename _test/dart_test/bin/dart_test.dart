import 'package:df_safer_dart/df_safer_dart.dart';

void main() {
  debugAssertErr = true;
  // This should trigger an assert!
  final err = Err('test');
  print(err);
}
