import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF7B61FF); // modern real estate purple
  static const background = Color(0xFFFFFFFF);
  static const surface = Color(0xFFF7F7F7);
  static const textPrimary = Color(0xFF111111);
  static const textSecondary = Color(0xFF666666);
  static const border = Color(0xFFE5E5E5);
  static const success = Color(0xFF22C55E);
  static const error = Color(0xFFE02424);
}

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    scaffoldBackgroundColor: AppColors.background,

    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      surface: AppColors.surface,
      error: AppColors.error,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: true,
    ),

    textTheme: const TextTheme(
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      titleMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: 16,
        color: AppColors.textPrimary,
      ),
      bodySmall: TextStyle(
        fontSize: 13,
        color: AppColors.textSecondary,
      ),
      labelSmall: TextStyle(
        fontSize: 12,
        color: AppColors.textSecondary,
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
  );
}