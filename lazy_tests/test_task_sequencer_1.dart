import 'package:df_safer_dart/df_safer_dart.dart';

void main() {
  final seq = TaskSequencer();
  seq.then((_) {
    print(1);
    return seq.then((_) {
      print(2);
      seq.then((_) {
        print(3);
        return syncNone();
      }).end();
      return seq.then((_) {
        print(4);
        return seq.then((_) {
          print(5);
          return seq.then((_) {
            print(6);
            return seq.then((_) {
              print(7);
              return syncNone();
            });
          });
        });
      });
    });
  }).end();

  seq.then((_) {
    print(8);
    return seq.then((_) {
      print(9);
      return seq.then((_) {
        print(10);
        return seq.then((_) {
          print(11);
          return syncNone();
        });
      });
    });
  }).end();

  seq.then((_) {
    print(12);
    return syncNone();
  }).end();

  seq.then((_) {
    print(13);
    return syncNone();
  }).end();
}
