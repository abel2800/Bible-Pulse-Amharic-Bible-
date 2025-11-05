import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/color_theme.dart';

class ColorThemeProvider extends ChangeNotifier {
  ReaderColorTheme _currentTheme = ReaderColorTheme.presets[0];
  List<HighlightColor> _highlightColors = HighlightColor.presets;
  int _selectedHighlightIndex = 0;
  
  ReaderColorTheme get currentTheme => _currentTheme;
  List<ReaderColorTheme> get availableThemes => ReaderColorTheme.presets;
  List<HighlightColor> get highlightColors => _highlightColors;
  HighlightColor get selectedHighlightColor => _highlightColors[_selectedHighlightIndex];
  
  Future<void> loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeId = prefs.getString('reader_theme') ?? 'light';
      
      final theme = ReaderColorTheme.getById(themeId);
      if (theme != null) {
        _currentTheme = theme;
      }
      
      _selectedHighlightIndex = prefs.getInt('selected_highlight_index') ?? 0;
      
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
  
  Future<void> setCustomTheme({
    required Color backgroundColor,
    required Color textColor,
    required Color verseNumberColor,
    required Color headerColor,
  }) async {
    try {
      _currentTheme = ReaderColorTheme(
        id: 'custom',
        name: 'Custom',
        backgroundColor: backgroundColor,
        textColor: textColor,
        verseNumberColor: verseNumberColor,
        headerColor: headerColor,
        isDark: backgroundColor.computeLuminance() < 0.5,
      );
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('reader_theme', 'custom');
      await prefs.setInt('custom_bg_color', backgroundColor.value);
      await prefs.setInt('custom_text_color', textColor.value);
      await prefs.setInt('custom_verse_number_color', verseNumberColor.value);
      await prefs.setInt('custom_header_color', headerColor.value);
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error setting custom theme: $e');
    }
  }
  
  Future<void> setSelectedHighlightColor(int index) async {
    if (index < 0 || index >= _highlightColors.length) return;
    
    try {
      _selectedHighlightIndex = index;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('selected_highlight_index', index);
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error setting highlight color: $e');
    }
  }
  
  HighlightColor getHighlightColorById(String id) {
    try {
      return _highlightColors.firstWhere((c) => c.id == id);
    } catch (e) {
      return _highlightColors[0];
    }
  }
}

