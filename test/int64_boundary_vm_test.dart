//.title
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//
// Copyright © dev-cetera.com & contributors.
//
// The use of this source code is governed by an MIT-style license described in
// the LICENSE file located in this project's root directory.
//
// See: https://opensource.org/license/mit
//
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//.title~

// VM-and-WASM-only int64 boundary tests. The literals `0x7FFFFFFFFFFFFFFF`
// (int64.max) and `-0x8000000000000000` (int64.min) can't be represented
// exactly in JS-Numbers — dart2js refuses to compile them. The `@TestOn('vm')`
// directive keeps these literals out of the JS compilation entirely.

@TestOn('vm')
library;

import 'package:df_safer_dart/df_safer_dart.dart';
import 'package:test/test.dart';

void main() {
  group('letIntOrNone — int64 boundary (VM/WASM only)', () {
    test('int64.max passes', () {
      expect(letIntOrNone(0x7FFFFFFFFFFFFFFF).unwrap(), 0x7FFFFFFFFFFFFFFF);
    });

    test('int64.min passes', () {
      expect(
        letIntOrNone(-0x8000000000000000).unwrap(),
        -0x8000000000000000,
      );
    });
  });
}
