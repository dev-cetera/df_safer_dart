// Example: Using Result instead of try-catch blocks to produce safer code.

import 'package:df_safer_dart/df_safer_dart.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  fetchIpAddress().map(
    (e) => e.fold((e) {
      print('IP address: $e');
      return const Ok(None());
    }, (e) {
      print('Error: $e');
      return const Ok(None());
    }),
  );
}

Concur<String> fetchIpAddress() {
  return Concur.tryCatch(
    () async {
      final response = await http.get(Uri.parse('https://api.ipify.org?format=json'));
      // This panics (throws an exception) if the status code is not 200.
      PanicIf(
        response.statusCode != 200,
        'Failed to fetch IP address',
      );
      final data = jsonDecode(response.body);
      final ip = data['ip'] as String;
      return ip;
    },
  );
}
