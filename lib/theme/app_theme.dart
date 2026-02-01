import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.accentViolet,
          secondary: AppColors.headerViolet,
          surface: AppColors.cardDark,
          background: AppColors.surfaceBlack,
          onPrimary: Colors.black,
          onSecondary: Colors.white,
          onSurface: Colors.white,
          onBackground: Colors.white,
        ),
        scaffoldBackgroundColor: AppColors.surfaceBlack,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: AppColors.headerViolet,
          foregroundColor: Colors.white,
        ),
        cardTheme: CardTheme(
          elevation: 0,
          color: AppColors.cardDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(
              color: AppColors.borderDark,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.cardDark,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppColors.inputBorderDark,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppColors.inputBorderDark,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppColors.accentViolet,
              width: 1.5,
            ),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accentViolet,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.cardDark,
          selectedItemColor: AppColors.accentViolet,
          unselectedItemColor: AppColors.unselectedDark,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
        ),
      );

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: AppColors.headerViolet,
          secondary: AppColors.accentViolet,
          surface: Colors.white,
          background: Color(0xFFF5F5F9),
          onPrimary: Colors.white,
          onSecondary: Colors.black,
          onSurface: Colors.black87,
          onBackground: Colors.black87,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F5F9),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: AppColors.headerViolet,
          foregroundColor: Colors.white,
        ),
        cardTheme: CardTheme(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(
              color: Color(0xFFE0E0EC),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFFCCCCDD),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFFCCCCDD),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppColors.headerViolet,
              width: 1.5,
            ),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.headerViolet,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.headerViolet,
          unselectedItemColor: Color(0xFF757595),
          elevation: 0,
          type: BottomNavigationBarType.fixed,
        ),
      );
}
