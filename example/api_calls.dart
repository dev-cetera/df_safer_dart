// Example: Using Resolvable and Result for safer error handling without try-catch
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
  // Wrap a potentially throwing function with Async. This contains all errors.
  // The idea is to never use try-catch blocks and instead use explicit
  // functional error handling by placing potentiall throwing functions
  // in Async.
  return Async.resolve(
    // Always await all asynchronous operations inside Async to ensure that
    // exceptions are properly caught and wrapped in a Result. This is one
    // of very few things you must remember for Resolvable.
    () async {
      final response = await http.get(Uri.parse('https://api.ipify.org?format=json'));
      // Throw an Err if the status code is not 200. Any other exceptions within
      // Resolvable.wrap will be caught and wrapped in an Err.
      if (response.statusCode != 200) {
        throw const Err('Failed to fetch IP address');
      }
      final data = jsonDecode(response.body);
      final ip = data['ipeee'] as String;
      return ip;
    },
  );
}
