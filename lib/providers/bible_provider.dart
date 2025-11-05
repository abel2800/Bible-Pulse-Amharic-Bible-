import 'package:flutter/material.dart';
import '../models/bible_verse.dart';
import '../models/bible_book.dart';
import '../services/bible_service.dart';

class BibleProvider with ChangeNotifier {
  final BibleService _bibleService = BibleService();
  
  String _currentVersion = 'KJV';
  String _currentLanguage = 'en';
  List<BibleBook> _books = [];
  List<BibleVerse> _currentChapter = [];
  List<BibleVerse> _searchResults = [];
  bool _isSearching = false;
  int? _pendingScrollVerse;
  int? _pendingScrollBookId;
  int? _pendingScrollChapter;
  BibleBook? _selectedBook;
  int _selectedChapter = 1;
  bool _isLoading = false;
  
  String get currentVersion => _currentVersion;
  String get currentLanguage => _currentLanguage;
  List<BibleBook> get books => _books;
  List<BibleVerse> get currentChapter => _currentChapter;
  BibleBook? get selectedBook => _selectedBook;
  int get selectedChapter => _selectedChapter;
  bool get isLoading => _isLoading;
  List<BibleVerse> get searchResults => _searchResults;
  bool get isSearching => _isSearching;
  int? get pendingScrollVerse => _pendingScrollVerse;
  int? get pendingScrollBookId => _pendingScrollBookId;
  int? get pendingScrollChapter => _pendingScrollChapter;
  
  List<Map<String, dynamic>> get bookmarks => _bookmarks;
  List<Map<String, dynamic>> get notes => _notes;
  List<Map<String, dynamic>> get highlights => _highlights;
  BibleVerse? get lastReadVerse => _lastReadVerse;
  BibleVerse? get verseOfTheDay => _verseOfTheDay;
  
  List<Map<String, dynamic>> _bookmarks = [];
  List<Map<String, dynamic>> _notes = [];
  List<Map<String, dynamic>> _highlights = [];
  BibleVerse? _lastReadVerse;
  BibleVerse? _verseOfTheDay;
  
  BibleProvider() {
    _initialize();
  }
  
  Future<void> _initialize() async {
    await loadBooks();
    if (_books.isNotEmpty) {
      await loadChapter(1, 1);
      if (_currentChapter.isNotEmpty) {
        _verseOfTheDay = _currentChapter.first;
      }
      if (_currentChapter.isNotEmpty) {
        _lastReadVerse = _currentChapter.first;
      }
    }
  }
  
  Future<void> loadBooks() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _books = await _bibleService.getBooks(_currentVersion);
    } catch (e) {
      debugPrint('Error loading books: $e');
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  Future<void> loadChapter(int bookId, int chapter) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _currentChapter = await _bibleService.getChapter(
        _currentVersion,
        bookId,
        chapter,
      );
      _selectedChapter = chapter;
      _selectedBook = _books.firstWhere((book) => book.id == bookId);
    } catch (e) {
      debugPrint('Error loading chapter: $e');
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  Future<void> changeVersion(String version, String language) async {
    _currentVersion = version;
    _currentLanguage = language;
    await loadBooks();
    
    if (_selectedBook != null) {
      await loadChapter(_selectedBook!.id, _selectedChapter);
    }
  }
  
  Future<void> nextChapter() async {
    if (_selectedBook == null) return;
    
    if (_selectedChapter < _selectedBook!.chapters) {
      await loadChapter(_selectedBook!.id, _selectedChapter + 1);
    } else {
      final currentIndex = _books.indexOf(_selectedBook!);
      if (currentIndex < _books.length - 1) {
        await loadChapter(_books[currentIndex + 1].id, 1);
      }
    }
  }

  Future<void> searchVerses(String query) async {
    if (query.isEmpty) return;
    _isSearching = true;
    _searchResults = [];
    notifyListeners();

    final lowerQuery = query.toLowerCase();

    if (_books.isEmpty) await loadBooks();

    try {
      for (final book in _books) {
        for (int chap = 1; chap <= book.chapters; chap++) {
          final verses = await _bibleService.getChapter(_currentVersion, book.id, chap);
          for (final v in verses) {
            if (v.text.toLowerCase().contains(lowerQuery)) {
              _searchResults.add(v);
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error during search: $e');
    }

    _isSearching = false;
    notifyListeners();
  }

  void clearSearch() {
    _searchResults = [];
    notifyListeners();
  }

  Future<void> goToVerse(int bookId, int chapter, int verse) async {
    _pendingScrollBookId = bookId;
    _pendingScrollChapter = chapter;
    _pendingScrollVerse = verse;
    notifyListeners();

    await loadChapter(bookId, chapter);
  }

  void clearPendingScroll() {
    _pendingScrollVerse = null;
    _pendingScrollBookId = null;
    _pendingScrollChapter = null;
    notifyListeners();
  }
  
  Future<void> previousChapter() async {
    if (_selectedBook == null) return;
    
    if (_selectedChapter > 1) {
      await loadChapter(_selectedBook!.id, _selectedChapter - 1);
    } else {
      final currentIndex = _books.indexOf(_selectedBook!);
      if (currentIndex > 0) {
        final prevBook = _books[currentIndex - 1];
        await loadChapter(prevBook.id, prevBook.chapters);
      }
    }
  }
  
  String getVerseReference(BibleVerse verse) {
    if (_selectedBook == null) return '';
    return '${_selectedBook!.name} ${verse.chapter}:${verse.verse}';
  }
}

