import 'package:flutter/material.dart';

class AppTheme {
  static const Color accent1 = Color(0xFF00897B);
  static const Color accent2 = Color(0xFF00BFA5);
  static const Color success = Color(0xFF00C853);
  static const Color warning = Color(0xFFFFB300);
  static const Color danger = Color(0xFFE53935);
  static const Color info = Color(0xFF039BE5);

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent1, accent2],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: accent1,
      scaffoldBackgroundColor: const Color(0xFFF0F7F4),
      cardColor: const Color(0xFFFFFFFF),
      canvasColor: const Color(0xFFFFFFFF), // Used for bottom sheet/dialogs
      dividerColor: const Color(0x1F00897B),
      colorScheme: const ColorScheme.light(
        primary: accent1,
        secondary: accent2,
        surface: Color(0xFFFFFFFF),
        error: danger,
      ),
      fontFamily: 'Inter',
      textTheme: ThemeData.light().textTheme.copyWith(
        bodyLarge: const TextStyle(color: Color(0xFF0D1F1A)),
        bodyMedium: const TextStyle(color: Color(0xFF4A6B62)),
        bodySmall: const TextStyle(color: Color(0xFF7A9990)),
        titleLarge: const TextStyle(
          color: Color(0xFF0D1F1A),
          fontWeight: FontWeight.bold,
        ),
      ).apply(fontFamily: 'Inter'),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xB8FFFFFF),
        elevation: 0,
        iconTheme: IconThemeData(color: accent1),
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          color: Color(0xFF0D1F1A),
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
        actionsIconTheme: IconThemeData(color: accent1, size: 24),
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: const Color(0xFFF4F9F7),
        filled: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0x1F00897B), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0x1F00897B), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: accent1, width: 1.5),
        ),
        hintStyle: const TextStyle(color: Color(0xFF7A9990)),
      ),
      useMaterial3: true,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: accent2,
      scaffoldBackgroundColor: const Color(0xFF0A1612),
      cardColor: const Color(0xFF162119),
      canvasColor: const Color(0xFF162119),
      dividerColor: const Color(0x1F00BFA5),
      colorScheme: const ColorScheme.dark(
        primary: accent2,
        secondary: accent1,
        surface: Color(0xFF162119),
        error: danger,
      ),
      fontFamily: 'Inter',
      textTheme: ThemeData.dark().textTheme.copyWith(
        bodyLarge: const TextStyle(color: Color(0xFFE8F5F0)),
        bodyMedium: const TextStyle(color: Color(0xFF80B8AA)),
        bodySmall: const TextStyle(color: Color(0xFF4A7A6E)),
        titleLarge: const TextStyle(
          color: Color(0xFFE8F5F0),
          fontWeight: FontWeight.bold,
        ),
      ).apply(fontFamily: 'Inter'),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xD9162119),
        elevation: 0,
        iconTheme: IconThemeData(color: accent2),
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          color: Color(0xFFE8F5F0),
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
        actionsIconTheme: IconThemeData(color: accent2, size: 24),
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: const Color(0xFF1A2B24),
        filled: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0x1F00BFA5), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0x1F00BFA5), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: accent2, width: 1.5),
        ),
        hintStyle: const TextStyle(color: Color(0xFF4A7A6E)),
      ),
      useMaterial3: true,
    );
  }
}
