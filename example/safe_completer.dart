import 'package:df_safer_dart/src/_index.g.dart';

void main() {
  final finisher = SafeFinisher<List<num>>();
  print(finisher.resolvable().unwrap());
  finisher.finish([1]);

  final aa = finisher.trans<List<int>>((e) => e.cast());
  print(aa.resolvable().value);
}
