import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/bible_version.dart';
import 'package:uuid/uuid.dart';

class NavigationHistoryProvider extends ChangeNotifier {
  final Uuid _uuid = const Uuid();
  List<NavigationHistory> _history = [];
  int _maxHistorySize = 100;
  
  List<NavigationHistory> get history => _history;
  List<NavigationHistory> get recentHistory => 
      _history.take(20).toList();
  
  Future<void> loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString('navigation_history');
      
      if (historyJson != null) {
        final List<dynamic> decoded = json.decode(historyJson);
        _history = decoded.map((h) => NavigationHistory.fromJson(h)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading history: $e');
    }
  }
  
  Future<void> addToHistory(String reference, {String? bibleVersion}) async {
    try {
      if (_history.isNotEmpty && _history.first.reference == reference) {
        return;
      }
      
      final entry = NavigationHistory(
        id: _uuid.v4(),
        reference: reference,
        timestamp: DateTime.now(),
        bibleVersion: bibleVersion,
      );
      
      _history.insert(0, entry);
      
      if (_history.length > _maxHistorySize) {
        _history = _history.take(_maxHistorySize).toList();
      }
      
      await _saveHistory();
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding to history: $e');
    }
  }
  
  Future<void> clearHistory() async {
    try {
      _history.clear();
      await _saveHistory();
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing history: $e');
    }
  }
  
  Future<void> removeFromHistory(String id) async {
    try {
      _history.removeWhere((h) => h.id == id);
      await _saveHistory();
      notifyListeners();
    } catch (e) {
      debugPrint('Error removing from history: $e');
    }
  }
  
  List<NavigationHistory> searchHistory(String query) {
    final lowerQuery = query.toLowerCase();
    return _history.where((h) {
      return h.reference.toLowerCase().contains(lowerQuery);
    }).toList();
  }
  
  List<NavigationHistory> getHistoryByDate(DateTime date) {
    return _history.where((h) {
      return h.timestamp.year == date.year &&
             h.timestamp.month == date.month &&
             h.timestamp.day == date.day;
    }).toList();
  }
  
  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = json.encode(
        _history.map((h) => h.toJson()).toList(),
      );
      await prefs.setString('navigation_history', historyJson);
    } catch (e) {
      debugPrint('Error saving history: $e');
    }
  }
}

