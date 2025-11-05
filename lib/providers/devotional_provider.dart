import 'package:flutter/material.dart';
import 'dart:ui';
import '../models/devotional.dart';
import '../services/devotional_service.dart';

class DevotionalProvider with ChangeNotifier {
  final DevotionalService _devotionalService = DevotionalService();

  Devotional? _todayDevotional;
  bool _isLoading = false;
  Locale? _currentLocale;

  Devotional? get todayDevotional => _todayDevotional;
  bool get isLoading => _isLoading;

  DevotionalProvider() {
    loadTodayDevotional();
  }

  DevotionalProvider updateLocale(Locale locale) {
    if (_currentLocale == null || _currentLocale!.languageCode != locale.languageCode) {
      _currentLocale = locale;
      loadTodayDevotional(locale: locale);
    }
    return this;
  }

  Future<void> loadTodayDevotional({Locale? locale}) async {
    _isLoading = true;
    notifyListeners();

    try {
      _todayDevotional = await _devotionalService.getTodayDevotional(locale: locale);
    } catch (e) {
      debugPrint('Error loading devotional: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshDevotional() async {
    await loadTodayDevotional(locale: _currentLocale);
  }
}

