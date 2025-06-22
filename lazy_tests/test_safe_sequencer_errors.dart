import 'package:df_safer_dart/df_safer_dart.dart';

void main() {
  UNSAFE:
  SafeSequencer(eagerError: true)
    ..addSafe((prev) {
      print(prev);
      return const Sync.unsafe(Ok(Some(1)));
    })
    ..addSafe((prev) {
      print(prev);
      throw Err('Oh no!');
    })
    ..addSafe(
      (prev) {
        return const Sync.unsafe(Ok(Some(1)));
      },
      eagerError: false,
      onPrevErr: (err) {
        print('ERROR!!!');
      },
    )
    ..addSafe((prev) {
      print(prev);
      return const Sync.unsafe(Ok(Some(1)));
    }).end();
}
