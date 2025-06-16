import '../monads/monad.dart';

import 'dart:convert';

extension SaferString on String {
  Option<int> toIntOrNone() {
    return Option.from(int.tryParse(this));
  }

  Option<double> toDoubleOrNone() {
    return Option.from(double.tryParse(this));
  }

  Option<bool> toBoolOrNone() {
    return Option.from(bool.tryParse(this, caseSensitive: false));
  }

  Result<T> decodeJson<T extends Object>() {
    try {
      return Ok(jsonDecode(this) as T);
    } catch (e) {
      return Err(e);
    }
  }
}
