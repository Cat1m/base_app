import 'package:base_app/src/features/home/screens/home_screen.dart';
import 'package:base_app/src/features/theme/app_theme.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Rust Demo',
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}
