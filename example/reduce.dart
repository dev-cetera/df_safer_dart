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
  final b = Async.value(Future.value(const Ok(1))).reduce();
  _check(b);

  print('C');
  final c = const Ok(1).reduce();
  _check(c);

  print('D');
  final d = Err('!!!').reduce();
  _check(d);

  print('E');
  final e = Ok(Some(Some(Ok(Err('!!!'))))).reduce();
  _check(e);
}

void _check<R extends Object>(Resolvable<Option<R>> src) {
  internal(Result<Option<Object>> src) {
    src
        .ifOk((e) {
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
        })
        .ifErr((e) {
          final src = e.error;
          print('Error: $src!');
        });
  }

  src
      .ifAsync((e) async {
        // ignore: invalid_use_of_visible_for_testing_member
        final src = await e.value;
        internal(src);
        print('Async!');
      })
      .ifSync((e) {
        // ignore: invalid_use_of_visible_for_testing_member
        final src = e.value;
        internal(src);
      });
}
