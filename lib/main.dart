import 'package:flutter/material.dart';
import 'package:base_app/src/app.dart';
import 'package:base_app/src/rust/frb_generated.dart';

Future<void> main() async {
  await RustLib.init();
  runApp(const MyApp());
}
