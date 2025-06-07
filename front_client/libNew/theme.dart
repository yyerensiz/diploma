//front_client\lib\theme.dart
import 'package:flutter/material.dart';

class CareNestTheme {
  static const Color primaryColor    = Color(0xFFFC3C59);
  static const Color secondaryColor  = Color(0xFFE61A39);
  static const Color backgroundColor = Colors.white;

  static const MaterialColor customPrimary = MaterialColor(
    0xFFFC3C59,
    <int, Color>{
      50:  Color(0xFFFFE0E0),
      100: Color(0xFFFFB3B3),
      200: Color(0xFFFF8080),
      300: Color(0xFFFF4D4D),
      400: Color(0xFFFF2626),
      500: Color(0xFFFC3C59),
      600: Color(0xFFE61A39),
      700: Color(0xFFCC0000),
      800: Color(0xFFB30000),
      900: Color(0xFF990000),
    },
  );

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
