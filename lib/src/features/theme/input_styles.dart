import 'package:flutter/material.dart';
import 'colors.dart';

class AppInputStyles {
  // Input decoration
  static InputDecorationTheme inputDecorationTheme = InputDecorationTheme(
    fillColor: AppColors.surface,
    filled: true,
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: AppColors.primary, width: 1),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: AppColors.error, width: 1),
    ),
    hintStyle: TextStyle(color: AppColors.textDisabled),
  );
}
