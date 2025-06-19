import 'package:df_safer_dart/src/_src.g.dart';

void main() {
  // ignore: invalid_use_of_protected_member
  UNSAFE(() => const None().unwrap());
}
