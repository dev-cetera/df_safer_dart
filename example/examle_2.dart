// Example 2:
//
//

import 'package:df_safer_dart/df_safer_dart.dart';

void main() async {
  if (Some('Robert') == Some('Robert')) {
    print('Same!');
  }
}

Option<String> personName1 = const Some('Robert');
Option<String> personName2 = const None();
Option<String> personName3 = const Some('Hollie');
