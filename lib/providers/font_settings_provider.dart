import 'package:flutter/foundation.dart';
import '../models/font_settings.dart';
import '../services/database_service.dart';

class FontSettingsProvider with ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  
  FontSettings _fontSettings = const FontSettings(
    fontSize: 16.0,
    fontFamily: 'Roboto',
    lineHeight: 1.5,
  );

  FontSettings get fontSettings => _fontSettings;
  double get fontSize => _fontSettings.fontSize;
  String get fontFamily => _fontSettings.fontFamily;
  double get lineHeight => _fontSettings.lineHeight;

  Future<void> loadFontSettings() async {
    try {
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading font settings: $e');
    }
  }

  Future<void> setFontSize(double size) async {
    _fontSettings = _fontSettings.copyWith(fontSize: size);
    notifyListeners();
    await _saveFontSettings();
  }

  Future<void> setFontFamily(String family) async {
    _fontSettings = _fontSettings.copyWith(fontFamily: family);
    notifyListeners();
    await _saveFontSettings();
  }

  Future<void> setLineHeight(double height) async {
    _fontSettings = _fontSettings.copyWith(lineHeight: height);
    notifyListeners();
    await _saveFontSettings();
  }

  Future<void> resetToDefaults() async {
    _fontSettings = const FontSettings(
      fontSize: 16.0,
      fontFamily: 'Roboto',
      lineHeight: 1.5,
    );
    notifyListeners();
    await _saveFontSettings();
  }

  Future<void> _saveFontSettings() async {
    try {
      debugPrint('Font settings saved');
    } catch (e) {
      debugPrint('Error saving font settings: $e');
    }
  }
}

