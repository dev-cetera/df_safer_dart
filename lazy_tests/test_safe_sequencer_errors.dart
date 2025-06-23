// ignore_for_file: must_use_unsafe_wrapper_or_error
import 'package:df_safer_dart/df_safer_dart.dart';

void main() {
  UNSAFE:
  SafeSequencer(eagerError: true)
    ..pushTask((prev) {
      print(prev);
      return const Sync.unsafe(Ok(Some(1)));
    })
    ..pushTask((prev) {
      print(prev);
      throw Err('Oh no!');
    })
    ..pushTask(
      (prev) {
        return const Sync.unsafe(Ok(Some(1)));
      },
      eagerError: false,
      onPrevErr: (err) {
        print('ERROR!!!');
      },
    )
    ..pushTask((prev) {
      print(prev);
      return const Sync.unsafe(Ok(Some(1)));
    }).end();
}
