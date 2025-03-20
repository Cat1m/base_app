import 'package:flutter/material.dart';
import 'colors.dart';

// Extension cho những trường hợp cần thay đổi theme cục bộ
extension ThemeExtensions on ThemeData {
  // Tạo theme với nút màu đỏ cho màn hình cảnh báo
  ThemeData get warningButtonTheme => copyWith(
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.disabled)) {
            return AppColors.textDisabled;
          }
          return AppColors.error;
        }),
      ),
    ),
  );

  // Tạo theme với nền tối
  ThemeData get darkScreenTheme => copyWith(
    scaffoldBackgroundColor: AppColors.primaryDark,
    textTheme: textTheme.apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
  );
}
