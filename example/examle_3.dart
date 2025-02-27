//
//
//

import 'package:df_safer_dart/df_safer_dart.dart';

void main() async {
  final finisher = SafeFinisher<Resolvable<Option<int>>>();
  finisher.finish(Resolvable(() => const Some(1)));
  final aa = await finisher.resolvable().unwrap();
  final bb = await aa.unwrap();
  print(bb.unwrap());
}
