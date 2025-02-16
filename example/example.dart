// Example:
//
// Using Resolvable and Result for safer error handling without try-catch
// blocks.
//
// Explicit error handling is enforced, providing compile-time safety.

import 'package:df_safer_dart/df_safer_dart.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  // Fetch the IP address and handle both success and error results.
  fetchIpAddress().flatMap(
    (result) => result
        .ifOk((e) {
          print('IP address: ${result.unwrap()}');
        })
        .ifErr((e) {
          print('Error: $e');
        }),
  );
}

Async<String> fetchIpAddress() {
  // Async.unsafe, Sync.unsafe or Resolvable.unsafe can be used to wrap
  // potentially throwing code.
  //
  // The only rules here are:
  //
  // 1. ALWAYS await all asynchronous operations inside Async.unsafe
  // (or Resolvable.unsafe) to ensure that exceptions are properly caught and
  // wrapped in a Result.
  //
  // 2. Only deal with asynchronous operations in Async.unsafe or
  // Resolvable.unsafe. Not in Sync.unsafe.
  //
  // 3. You can throw any Objects within unsafe, but prefer throwing Err
  // objects as it is the standard and will help with debugging.
  return Async.unsafe(() async {
    final response = await http.get(
      Uri.parse('https://api.ipify.org?format=json'),
    );
    // Throw an Err if the status code is not 200. Any other exceptions within
    // Resolvable.wrap will be caught and wrapped in an Err.
    if (response.statusCode != 200) {
      throw Err(
        // The debugPath will be printed when the error is thrown.
        debugPath: ['fetchIpAddress'],
        error: 'Failed to fetch IP address',
      );
    }
    final data = jsonDecode(response.body);
    final ip = data['ip'] as String;
    return ip;
  });
}
