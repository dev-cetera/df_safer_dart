// ignore_for_file: must_use_unsafe_wrapper_or_error
import 'package:df_safer_dart/df_safer_dart.dart';

void main() {
  UNSAFE:
  TaskSequencer(eagerError: true)
    ..then((prev) {
      print(prev);
      return Sync.okValue(const Some(1));
    })
    ..then((prev) {
      print(prev);
      throw Err('Oh no!');
    })
    ..then(
      (prev) {
        return Sync.okValue(const Some(2));
      },
      eagerError: false,
      onPrevError: (err) {
        print('ERROR!!!');
        return syncNone();
      },
    )
    ..then((prev) {
      print(prev);
      return Sync.okValue(const Some(3));
    }).end();
}
