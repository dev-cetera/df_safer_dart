// Example: Using Concur and Result for safer error handling without try-catch
// blocks. Explicit error handling is enforced, providing compile-time safety.

import 'package:df_safer_dart/df_safer_dart.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  // Fetch the IP address and handle both success and error results.
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
  // all errors. The idea is to never use try-catch blocks and instead
  // use explicit error handling by placing potentiall throwing functions
  // in Concur.wrap.
  return Resolvable.wrap(
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
    // This will deliberately trrigger a linter warning, to make you aware
    // that unwrap() is a potentially throwing function and that you need
    // to only use it when you're certain it won't throw. You can disable lints
    // for this line with "// ignore: invalid_use_of_visible_for_testing_member"
  ).async.unwrap();
}
