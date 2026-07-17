import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bible_verse.dart';
import '../models/bible_book.dart';
import '../services/bible_service.dart';
import '../services/bible_search_service.dart';

class BibleProvider with ChangeNotifier {
  BibleProvider({BibleService? bibleService})
      : _bibleService = bibleService ?? BibleService() {
    _searchService = BibleSearchService(bibleService: _bibleService);
    ready = _initialize();
  }

  final BibleService _bibleService;
  late final BibleSearchService _searchService;
  late final Future<void> ready;
  int _searchRequest = 0;

  String _currentVersion = 'WEB';
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

  BibleVerse? get verseOfTheDay => _verseOfTheDay;

  BibleVerse? _lastReadVerse;
  BibleVerse? _verseOfTheDay;

  Future<void> _initialize() async {
    await loadBooks();
    if (_books.isNotEmpty) {
      final dailyChapter =
          await _bibleService.getChapter(_currentVersion, 43, 3);
      if (dailyChapter.isNotEmpty) {
        final day =
            DateTime.now().toUtc().difference(DateTime.utc(2024)).inDays;
        _verseOfTheDay = dailyChapter[day % dailyChapter.length];
      }

      final prefs = await SharedPreferences.getInstance();
      final bookId = prefs.getInt('last_read_book') ?? 1;
      final chapter = prefs.getInt('last_read_chapter') ?? 1;
      final verse = prefs.getInt('last_read_verse') ?? 1;
      await loadChapter(bookId, chapter);
      final verseIndex =
          _currentChapter.indexWhere((item) => item.verse == verse);
      _lastReadVerse = verseIndex == -1
          ? (_currentChapter.isEmpty ? null : _currentChapter.first)
          : _currentChapter[verseIndex];
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
      if (_currentChapter.isNotEmpty) {
        _lastReadVerse = _currentChapter.first;
        await _saveLastRead(_lastReadVerse!);
      }
    } catch (e) {
      debugPrint('Error loading chapter: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> changeVersion(String version) async {
    _currentVersion = version;
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
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty) {
      clearSearch();
      return;
    }
    final request = ++_searchRequest;
    _isSearching = true;
    _searchResults = [];
    notifyListeners();

    try {
      final results = await _searchService.search(
        _currentVersion,
        normalizedQuery,
        limit: 200,
      );
      if (request == _searchRequest) {
        _searchResults = results;
      }
    } catch (e) {
      debugPrint('Error during search: $e');
    }

    if (request == _searchRequest) {
      _isSearching = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _searchRequest++;
    _isSearching = false;
    _searchResults = [];
    notifyListeners();
  }

  Future<void> goToVerse(int bookId, int chapter, int verse) async {
    _pendingScrollBookId = bookId;
    _pendingScrollChapter = chapter;
    _pendingScrollVerse = verse;
    notifyListeners();

    await loadChapter(bookId, chapter);
    final index = _currentChapter.indexWhere((item) => item.verse == verse);
    if (index != -1) {
      _lastReadVerse = _currentChapter[index];
      await _saveLastRead(_lastReadVerse!);
    }
  }

  Future<void> _saveLastRead(BibleVerse verse) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setInt('last_read_book', verse.book),
      prefs.setInt('last_read_chapter', verse.chapter),
      prefs.setInt('last_read_verse', verse.verse),
      prefs.setString('last_read_version', _currentVersion),
    ]);
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
    final index = _books.indexWhere((book) => book.id == verse.book);
    if (index == -1) return '${verse.book} ${verse.chapter}:${verse.verse}';
    return '${_books[index].name} ${verse.chapter}:${verse.verse}';
  }
}
