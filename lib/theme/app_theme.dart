import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/font_env_stub.dart'
    if (dart.library.io) '../utils/font_env_io.dart';
import 'app_colors.dart';

class AppText {
  static TextStyle display(
    BuildContext c, {
    double size = 22,
    FontWeight w = FontWeight.w700,
  }) {
    final color = c.colors.ink;
    if (isFlutterTest) {
      return TextStyle(
        fontFamily: 'serif',
        fontSize: size,
        fontWeight: w,
        color: color,
        height: 1.15,
      );
    }
    return GoogleFonts.fraunces(
      fontSize: size,
      fontWeight: w,
      color: color,
      height: 1.15,
    );
  }

  static TextStyle scripture(
    BuildContext c, {
    double size = 16,
    FontStyle style = FontStyle.normal,
    Color? color,
  }) {
    final ink = color ?? c.colors.ink;
    if (isFlutterTest) {
      return TextStyle(
        fontFamily: 'serif',
        fontSize: size,
        fontStyle: style,
        color: ink,
        height: 1.7,
      );
    }
    return GoogleFonts.sourceSerif4(
      fontSize: size,
      fontStyle: style,
      color: ink,
      height: 1.7,
    );
  }

  static TextStyle ui(
    BuildContext c, {
    double size = 13.5,
    FontWeight w = FontWeight.w500,
    Color? color,
  }) {
    final ink = color ?? c.colors.ink;
    if (isFlutterTest) {
      return TextStyle(
        fontFamily: 'sans-serif',
        fontSize: size,
        fontWeight: w,
        color: ink,
      );
    }
    return GoogleFonts.inter(fontSize: size, fontWeight: w, color: ink);
  }

  static TextStyle uiFaint(
    BuildContext c, {
    double size = 11.5,
    FontWeight w = FontWeight.w600,
  }) {
    return ui(c, size: size, w: w, color: c.colors.inkFaint);
  }
}

class ManuscriptTheme {
  static ThemeData _base(AppColors t, Brightness brightness) {
    final interFamily =
        isFlutterTest ? 'sans-serif' : GoogleFonts.inter().fontFamily;
    final frauncesTitle = isFlutterTest
        ? TextStyle(
            fontFamily: 'serif',
            fontSize: 19,
            fontWeight: FontWeight.w600,
            color: t.ink,
          )
        : GoogleFonts.fraunces(
            fontSize: 19,
            fontWeight: FontWeight.w600,
            color: t.ink,
          );
    final buttonText = isFlutterTest
        ? const TextStyle(
            fontFamily: 'sans-serif',
            fontWeight: FontWeight.w700,
            fontSize: 13.5,
          )
        : GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13.5);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: t.appBg,
      fontFamily: interFamily,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: AppBrand.gold,
        onPrimary: AppBrand.onGold,
        secondary: AppBrand.teal,
        onSecondary: Colors.white,
        error: AppBrand.error,
        onError: Colors.white,
        surface: t.surface,
        onSurface: t.ink,
      ),
      extensions: [t],
      appBarTheme: AppBarTheme(
        backgroundColor: t.appBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: t.inkSoft),
        titleTextStyle: frauncesTitle,
      ),
      cardTheme: CardThemeData(
        color: t.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: t.border),
        ),
      ),
      dividerColor: t.border,
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: t.surface,
        selectedItemColor: AppBrand.gold,
        unselectedItemColor: t.inkFaint,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: t.surface,
        indicatorColor: Colors.transparent,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final active = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: active ? AppBrand.gold : t.inkFaint,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final active = states.contains(WidgetState.selected);
          return IconThemeData(
            color: active ? AppBrand.gold : t.inkFaint,
            size: 22,
          );
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: t.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: t.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: t.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppBrand.gold, width: 1.4),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppBrand.gold,
          foregroundColor: AppBrand.onGold,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: t.ink,
          side: BorderSide(color: t.border),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppBrand.onGold;
          return t.surface;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppBrand.gold;
          return t.border;
        }),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: t.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppBrand.gold,
        foregroundColor: AppBrand.onGold,
      ),
    );
  }

  static ThemeData get light => _base(AppColors.light, Brightness.light);
  static ThemeData get dark => _base(AppColors.dark, Brightness.dark);
}
