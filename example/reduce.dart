// Example:
//
// Using the reduce function to reduce long complicated chains of Monads
// to a single result of type ResolvableOption.

import 'package:df_safer_dart/df_safer_dart.dart';

void main() async {
  print('A');
  final a = const None().reduce();
  _check(a);

  print('B');
  final b = Async(Future.value(const Ok(1))).reduce();
  _check(b);

  print('C');
  final c = const Ok(1).reduce();
  _check(c);

  print('D');
  final d = const Err(error: '!!!', stack: []).reduce();
  _check(d);

  print('E');
  final e = const Ok(Some(Some(Ok(Err(error: '!!!', stack: []))))).reduce();
  _check(e);
}

void _check<R extends Object>(ResolvableOption<R> src) {
  internal(Result<Option<Object>> src) {
    src.ifOk((e) {
      final src = e.value;
      print('Ok!');
      src
          .ifSome((e) {
            final src = e.value;
            print('Some: $src!');
          })
          .unwrap()
          .ifNone(() {
            print('None!');
          });
    }).ifErr((e) {
      final src = e.error;
      print('Error: $src!');
    });
  }

  src.ifAsync((e) async {
    final src = await e.value;
    internal(src);
    print('Async!');
  }).ifSync((e) {
    final src = e.value;
    internal(src);
  });
}
