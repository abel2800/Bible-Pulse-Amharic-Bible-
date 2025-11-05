import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryIndigo = Color(0xFF0B2545);
  static const Color accentTeal = Color(0xFF2EC4B6);
  static const Color parchment = Color(0xFFF7F3EA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1F2D3D);

  static const Color darkBackground = Color(0xFF071329);
  static const Color darkSurface = Color(0xFF0B2233);
  static const Color darkText = Color(0xFFF4F2EE);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: primaryIndigo,
      secondary: accentTeal,
      surface: surfaceLight,
      background: parchment,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: textDark,
    ),
    scaffoldBackgroundColor: parchment,
    textTheme: GoogleFonts.merriweatherTextTheme().apply(
      bodyColor: textDark,
      displayColor: textDark,
    ).copyWith(
      bodyLarge: GoogleFonts.openSans(fontSize: 16, color: textDark),
      titleLarge: GoogleFonts.merriweather(fontSize: 20, fontWeight: FontWeight.w700, color: textDark),
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: primaryIndigo,
      foregroundColor: Colors.white,
      titleTextStyle: GoogleFonts.merriweather(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: surfaceLight,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryIndigo,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        textStyle: GoogleFonts.openSans(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceLight,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.all(14),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: primaryIndigo,
      secondary: accentTeal,
      surface: darkSurface,
      background: darkBackground,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: darkText,
    ),
    scaffoldBackgroundColor: darkBackground,
    textTheme: GoogleFonts.merriweatherTextTheme().apply(
      bodyColor: darkText,
      displayColor: darkText,
    ).copyWith(
      bodyLarge: GoogleFonts.openSans(fontSize: 16, color: darkText),
      titleLarge: GoogleFonts.merriweather(fontSize: 20, fontWeight: FontWeight.w700, color: darkText),
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: false,
  backgroundColor: darkBackground,
  foregroundColor: darkText,
      titleTextStyle: GoogleFonts.merriweather(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: darkText,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: darkSurface,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentTeal,
        foregroundColor: darkBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        textStyle: GoogleFonts.openSans(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkSurface,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.all(14),
    ),
  );

  static const List<Color> highlightColors = [
    Color(0xFFFDE047), // Yellow
    Color(0xFF4ADE80), // Green
    Color(0xFF60A5FA), // Blue
    Color(0xFFFB923C), // Orange
    Color(0xFFF472B6), // Pink
    Color(0xFFA78BFA), // Purple
    Color(0xFF22D3EE), // Cyan
    Color(0xFFF87171), // Red
  ];
}

