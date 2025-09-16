import 'package:flutter/material.dart';
import 'app_color.dart';

class AppTheme {
  static ThemeData base = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: AppColor.background,
    textTheme: const TextTheme(
      bodyMedium: TextStyle(
        fontFamily: 'monospace',
        color: AppColor.primary,
      ),
    ),
    textSelectionTheme: TextSelectionThemeData(
      selectionColor: AppColor.primary.withValues(alpha: 0.3),
      selectionHandleColor: AppColor.primary,
      cursorColor: AppColor.primary,
    ),
  );
}