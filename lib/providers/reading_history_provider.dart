import 'package:flutter/material.dart';
import '../models/reading_history.dart';
import '../services/database_service.dart';
import 'package:uuid/uuid.dart';

class ReadingHistoryProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  final Uuid _uuid = const Uuid();
  
  List<ReadingHistory> _history = [];
  ReadingStats _stats = ReadingStats();
  
  String? _currentBookName;
  int? _currentChapter;
  DateTime? _sessionStartTime;
  
  List<ReadingHistory> get history => _history;
  ReadingStats get stats => _stats;
  
  Future<void> loadHistory() async {
    try {
      debugPrint('Loading reading history...');
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading reading history: $e');
    }
  }
  
  void startReadingSession(String bookName, int chapter) {
    _currentBookName = bookName;
    _currentChapter = chapter;
    _sessionStartTime = DateTime.now();
  }
  
  Future<void> endReadingSession({int? verse, String? bibleVersion}) async {
    if (_currentBookName == null || _currentChapter == null || _sessionStartTime == null) {
      return;
    }
    
    final duration = DateTime.now().difference(_sessionStartTime!).inSeconds;
    
    if (duration < 5) {
      _currentBookName = null;
      _currentChapter = null;
      _sessionStartTime = null;
      return;
    }
    
    debugPrint('Reading session ended: $_currentBookName $_currentChapter - ${duration}s');
    
    _currentBookName = null;
    _currentChapter = null;
    _sessionStartTime = null;
  }
}

