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
        // Persist normalized id if an old preset was stored.
        if (theme.id != themeId) {
          await prefs.setString('reader_theme', theme.id);
        }
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
      await prefs.setString('reader_theme', theme.id);

      notifyListeners();
    } catch (e) {
      debugPrint('Error setting theme: $e');
    }
  }

  /// Keep scripture page in step with app light/dark chrome.
  Future<void> syncWithAppBrightness(bool isDark) async {
    final targetId = isDark ? 'dark' : 'light';
    if (_currentTheme.id == targetId) return;
    // Don't yank the user out of Eye Comfort when flipping app chrome
    // unless they are already on a light/dark scripture theme.
    if (_currentTheme.id == 'eye_comfort') return;
    await setTheme(targetId);
  }
}
