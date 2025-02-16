import 'package:df_safer_dart/src/_index.g.dart';

void main() {
  final finisher = SafeFinisher<Iterable<num>>();
  finisher.finish([1, 2, 3]);

  final aa = finisher.castOrConvert<List<int>>();
  aa.resolvable().value;
}
