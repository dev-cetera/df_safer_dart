// Example: Using Result instead of try-catch blocks to produce safer code.

import 'package:df_safer_dart/df_safer_dart.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  fetchIpAddress().map(
    (e) => e.ifOk((e) {
      print('IP address: $e');
    }).ifErr((e) {
      print(e);
    }),
  );
}

Async<String> fetchIpAddress() {
  // Wrap a potentially throwing function with Concur.wrap. This contains
  // all errors.
  return Concur.wrap(
    () async {
      final response = await http.get(Uri.parse('https://api.ipify.org?format=json'));
      // Throw an Err if the status code is not 200. Any other exceptions within
      // Concur.wrap will be caught and wrapped in an Err.
      if (response.statusCode != 200) {
        throw const Err('Failed to fetch IP address');
      }
      final data = jsonDecode(response.body);
      final ip = data['ipeee'] as String;
      return ip;
    },
    // ignore: invalid_use_of_visible_for_testing_member
  ).async.unwrap();
}
