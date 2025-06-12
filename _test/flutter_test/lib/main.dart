import 'package:df_safer_dart/df_safer_dart.dart';
import 'package:flutter/material.dart';

void main() {
  final err = Err('test');
  print(err);
  runApp(const MaterialApp(home: SizedBox.shrink()));
}
