// Example 4:
//
//

import 'package:df_safer_dart/df_safer_dart.dart';

void main() async {
  // ignore: invalid_use_of_protected_member
  print(Err<String>('!!!').unwrap());
}
