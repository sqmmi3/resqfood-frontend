import 'package:flutter/material.dart';

class AppTheme {
  static const Color _seedGreen = Colors.green;

  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seedGreen,
      brightness: Brightness.light,
      primary: _seedGreen,
      onPrimary: Colors.white,
      primaryContainer: Colors.green.shade100,
      onPrimaryContainer: Colors.green.shade900,
      secondary: Colors.greenAccent.shade700,
      surface: Colors.white,
      onSurface: Colors.black,
      outlineVariant: Colors.grey.shade300,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      backgroundColor: _seedGreen,
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 2,
    ),
    dividerTheme: DividerThemeData(
      color: Colors.grey.shade300,
      thickness: 1,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _seedGreen,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade50,
      floatingLabelStyle: const TextStyle(color: _seedGreen, fontWeight: FontWeight.bold),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: _seedGreen, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );

  // Dark Theme
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seedGreen,
      brightness: Brightness.dark,
      primary: _seedGreen,
      onPrimary: Colors.white,
      primaryContainer: Colors.green.shade900.withValues(alpha: 0.5),
      onPrimaryContainer: Colors.green.shade100,
      surface: const Color(0xFF121212),
      onSurface: Colors.white,
      outlineVariant: Colors.white24,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    dividerTheme: const DividerThemeData(
      color: Colors.white24,
      thickness: 1,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _seedGreen,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.05),
      floatingLabelStyle: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.greenAccent, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white24),
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}