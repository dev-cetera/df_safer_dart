import '../monads/monad.dart';

import 'dart:convert';

extension SaferString on String {
  Option<int> toIntOrNone() {
    return Option.fromNullable(int.tryParse(this));
  }

  Option<double> toDoubleOrNone() {
    return Option.fromNullable(double.tryParse(this));
  }

  Option<bool> toBoolOrNone() {
    return Option.fromNullable(bool.tryParse(this, caseSensitive: false));
  }

  Result<T> decodeJson<T extends Object>() {
    try {
      return Ok(jsonDecode(this) as T);
    } catch (e) {
      return Err(e);
    }
  }
}
