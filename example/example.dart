// Example of avoiding try-catch blocks in Dart, to produce safer code:

import 'package:df_safer_dart/df_safer_dart.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  fetchIpAddress().fold(
    (value) => print('IP address: $value'),
    (error) => print('Error: $error'),
  );
}

Result<String> fetchIpAddress() {
  return Result(() async {
    final response = await http.get(Uri.parse('https://api.ipify.org?format=json'));
    // This throws an exception if the status code is not 200.
    PanicIf(response.statusCode != 200, 'Failed to fetch IP address');
    final data = jsonDecode(response.body);
    final ip = data['ip'] as String;
    // Return the result.
    return ip;
  });
}
