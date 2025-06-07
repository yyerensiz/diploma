// lib/theme.dart
import 'package:flutter/material.dart';

class CareNestTheme {
  static const Color primaryColor = Color(0xFF3366FF); // NEW for specialist
  static const Color secondaryColor = Color(0xFF003399); // NEW for specialist
  static const Color backgroundColor = Color.fromARGB(255, 255, 255, 255);

  static const MaterialColor customPrimary = MaterialColor(0xFF3366FF, {
    50: Color(0xFFE3EFFF),
    100: Color(0xFFB3D4FF),
    200: Color(0xFF80B9FF),
    300: Color(0xFF4D9EFF),
    400: Color(0xFF2688FF),
    500: Color(0xFF3366FF),
    600: Color(0xFF004DE6),
    700: Color(0xFF003BB3),
    800: Color(0xFF002980),
    900: Color(0xFF00174D),
  });

  static ThemeData light() {
    return ThemeData(
      primarySwatch: customPrimary,
      scaffoldBackgroundColor: backgroundColor,

      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: secondaryColor.withOpacity(0.5),
      ),

      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: primaryColor,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(color: secondaryColor),
        bodyLarge: TextStyle(color: Colors.black),
        bodyMedium: TextStyle(color: Colors.black),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}
