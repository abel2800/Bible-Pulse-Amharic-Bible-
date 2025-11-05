import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/highlight.dart';
import '../models/note.dart';
import '../models/bookmark.dart';
import '../services/database_service.dart';

class StudyProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  
  List<Highlight> _highlights = [];
  List<Note> _notes = [];
  List<Bookmark> _bookmarks = [];
  
  List<Highlight> get highlights => _highlights;
  List<Note> get notes => _notes;
  List<Bookmark> get bookmarks => _bookmarks;
  
  StudyProvider() {
    if (!kIsWeb) {
      loadAll();
    }
  }
  
  Future<void> loadAll() async {
    if (kIsWeb) return; // Skip database operations on web
    
    await Future.wait([
      loadHighlights(),
      loadNotes(),
      loadBookmarks(),
    ]);
  }
  
  Future<void> loadHighlights() async {
    if (kIsWeb) return;
    _highlights = await _databaseService.getHighlights();
    notifyListeners();
  }
  
  Future<void> loadNotes() async {
    if (kIsWeb) return;
    _notes = await _databaseService.getNotes();
    notifyListeners();
  }
  
  Future<void> loadBookmarks() async {
    if (kIsWeb) return;
    _bookmarks = await _databaseService.getBookmarks();
    notifyListeners();
  }
  
  Future<void> addHighlight(String verseReference, String text, Color color) async {
    final highlight = Highlight(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      verseReference: verseReference,
      text: text,
      color: color.value,
      createdAt: DateTime.now(),
    );
    
    if (!kIsWeb) {
      await _databaseService.insertHighlight(highlight);
      await loadHighlights();
    } else {
      _highlights.add(highlight);
      notifyListeners();
    }
  }
  
  Future<void> removeHighlight(String verseReference) async {
    if (!kIsWeb) {
      await _databaseService.deleteHighlight(verseReference);
      await loadHighlights();
    } else {
      _highlights.removeWhere((h) => h.verseReference == verseReference);
      notifyListeners();
    }
  }
  
  Future<void> addNote(String verseReference, String noteText) async {
    final note = Note(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      verseReference: verseReference,
      text: noteText,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    if (!kIsWeb) {
      await _databaseService.insertNote(note);
      await loadNotes();
    } else {
      _notes.add(note);
      notifyListeners();
    }
  }
  
  Future<void> updateNote(Note note) async {
    if (!kIsWeb) {
      await _databaseService.updateNote(note);
      await loadNotes();
    } else {
      final index = _notes.indexWhere((n) => n.id == note.id);
      if (index != -1) {
        _notes[index] = note;
        notifyListeners();
      }
    }
  }
  
  Future<void> deleteNote(String id) async {
    if (!kIsWeb) {
      await _databaseService.deleteNote(id);
      await loadNotes();
    } else {
      _notes.removeWhere((n) => n.id == id);
      notifyListeners();
    }
  }
  
  Future<void> addBookmark(String verseReference, String text) async {
    final bookmark = Bookmark(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      verseReference: verseReference,
      text: text,
      createdAt: DateTime.now(),
    );
    
    if (!kIsWeb) {
      await _databaseService.insertBookmark(bookmark);
      await loadBookmarks();
    } else {
      _bookmarks.add(bookmark);
      notifyListeners();
    }
  }
  
  Future<void> removeBookmark(String verseReference) async {
    if (!kIsWeb) {
      await _databaseService.deleteBookmark(verseReference);
      await loadBookmarks();
    } else {
      _bookmarks.removeWhere((b) => b.verseReference == verseReference);
      notifyListeners();
    }
  }
  
  bool isHighlighted(String verseReference) {
    return _highlights.any((h) => h.verseReference == verseReference);
  }
  
  Color? getHighlightColor(String verseReference) {
    final highlight = _highlights.firstWhere(
      (h) => h.verseReference == verseReference,
      orElse: () => Highlight(
        id: '',
        verseReference: '',
        text: '',
        color: 0,
        createdAt: DateTime.now(),
      ),
    );
    
    return highlight.id.isNotEmpty ? Color(highlight.color) : null;
  }
  
  bool isBookmarked(String verseReference) {
    return _bookmarks.any((b) => b.verseReference == verseReference);
  }
  
  Note? getNoteForVerse(String verseReference) {
    try {
      return _notes.firstWhere((n) => n.verseReference == verseReference);
    } catch (e) {
      return null;
    }
  }
}

