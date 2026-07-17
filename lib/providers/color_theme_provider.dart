import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/color_theme.dart';

class ColorThemeProvider extends ChangeNotifier {
  ReaderColorTheme _currentTheme = ReaderColorTheme.presets[0];

  ReaderColorTheme get currentTheme => _currentTheme;
  List<ReaderColorTheme> get availableThemes => ReaderColorTheme.presets;

  Future<void> loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeId = prefs.getString('reader_theme') ?? 'light';

      final theme = ReaderColorTheme.getById(themeId);
      if (theme != null) {
        _currentTheme = theme;
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading theme: $e');
    }
  }

  Future<void> setTheme(String themeId) async {
    try {
      final theme = ReaderColorTheme.getById(themeId);
      if (theme == null) return;

      _currentTheme = theme;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('reader_theme', themeId);

      notifyListeners();
    } catch (e) {
      debugPrint('Error setting theme: $e');
    }
  }
}
