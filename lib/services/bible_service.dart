import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/bible_verse.dart';
import '../models/bible_book.dart';

class BibleService {
  final Map<String, Map<String, dynamic>> _bibleCache = {};
  final Map<String, List<BibleVerse>> _chapterCache = {};
  
  final Map<String, String> _availableVersions = {
    'KJV': 'assets/bible/kjv.json',
    'ASV': 'assets/bible/asv.json',
    'AMHARIC': 'assets/bible/amharic.json',
  };
  
  Future<List<BibleBook>> getBooks(String version) async {
    try {
      if (!_bibleCache.containsKey(version)) {
        await _loadBibleFromAssets(version);
      }
      
      final bible = _bibleCache[version];
      if (bible == null || !bible.containsKey('books')) {
        return _getFallbackBooks();
      }
      
      List<BibleBook> books = [];
      final booksRaw = bible['books'];

      List<dynamic> booksJson;
      if (booksRaw is List) {
        booksJson = booksRaw;
      } else if (booksRaw is Map) {
        booksJson = booksRaw.values.toList();
      } else {
        return _getFallbackBooks();
      }

      for (int i = 0; i < booksJson.length; i++) {
        final bookJson = booksJson[i] as Map<String, dynamic>;
        final bookId = i + 1; // Generate ID from index (1-66)
        final bookName = (bookJson['name'] ?? bookJson['title'] ?? 'Book $bookId').toString();

        final rawChapters = bookJson['chapters'];
        int chapterCount = 0;
        if (rawChapters is List) {
          chapterCount = rawChapters.length;
        } else if (rawChapters is Map) {
          chapterCount = rawChapters.length;
        }

        final testament = bookId <= 39 ? 'OT' : 'NT';

        books.add(BibleBook(
          id: bookId,
          name: bookName,
          chapters: chapterCount,
          testament: testament,
        ));
      }
      
      return books;
    } catch (e) {
      print('Error loading books: $e');
      return _getFallbackBooks();
    }
  }
  
  Future<List<BibleVerse>> getChapter(String version, int bookId, int chapter) async {
    final cacheKey = '$version-$bookId-$chapter';
    
    if (_chapterCache.containsKey(cacheKey)) {
      return _chapterCache[cacheKey]!;
    }
    
    try {
      if (!_bibleCache.containsKey(version)) {
        await _loadBibleFromAssets(version);
      }
      
      final bible = _bibleCache[version];
      if (bible == null || !bible.containsKey('books')) {
        return _getFallbackChapter(bookId, chapter);
      }
      
      final booksRaw = bible['books'];
      List<dynamic> booksJson;
      if (booksRaw is List) {
        booksJson = booksRaw;
      } else if (booksRaw is Map) {
        booksJson = booksRaw.values.toList();
      } else {
        return _getFallbackChapter(bookId, chapter);
      }

      if (bookId < 1 || bookId > booksJson.length) {
        print('Book ID $bookId out of range (1-${booksJson.length})');
        return _getFallbackChapter(bookId, chapter);
      }

      final bookJson = booksJson[bookId - 1] as Map<String, dynamic>;

      final rawChapters = bookJson['chapters'];
      List<dynamic> chaptersJson = [];
      if (rawChapters is List) {
        chaptersJson = rawChapters;
      } else if (rawChapters is Map) {
        try {
          final keys = rawChapters.keys.toList();
          keys.sort((a, b) {
            final ai = int.tryParse(a.toString()) ?? 0;
            final bi = int.tryParse(b.toString()) ?? 0;
            return ai.compareTo(bi);
          });
          for (var k in keys) {
            chaptersJson.add(rawChapters[k]);
          }
        } catch (_) {
          chaptersJson = rawChapters.values.toList();
        }
      }

      if (chapter < 1 || chapter > chaptersJson.length) {
        print('Chapter $chapter out of range (1-${chaptersJson.length}) for book $bookId');
        return _getFallbackChapter(bookId, chapter);
      }

      final chapterJson = chaptersJson[chapter - 1];

      List<BibleVerse> verses = [];
      if (chapterJson == null) {
        return _getFallbackChapter(bookId, chapter);
      }

      dynamic versesRaw;
      if (chapterJson is Map && chapterJson.containsKey('verses')) {
        versesRaw = chapterJson['verses'];
      } else {
        versesRaw = chapterJson;
      }

      if (versesRaw is List) {
        for (int i = 0; i < versesRaw.length; i++) {
          final v = versesRaw[i];
          if (v is Map) {
            final intVerse = (v['verse'] ?? v['id'] ?? (i + 1)) as dynamic;
            final intVerseNum = int.tryParse(intVerse.toString()) ?? (i + 1);
            verses.add(BibleVerse(
              id: intVerseNum,
              book: bookId,
              chapter: chapter,
              verse: intVerseNum,
              text: (v['text'] ?? v['verse_text'] ?? v['content'] ?? v.toString()).toString(),
            ));
          } else {
            verses.add(BibleVerse(
              id: i + 1,
              book: bookId,
              chapter: chapter,
              verse: i + 1,
              text: v.toString(),
            ));
          }
        }
      } else if (versesRaw is Map) {
        final keys = versesRaw.keys.toList();
        keys.sort((a, b) {
          final ai = int.tryParse(a.toString()) ?? 0;
          final bi = int.tryParse(b.toString()) ?? 0;
          return ai.compareTo(bi);
        });
        for (var k in keys) {
          final text = versesRaw[k];
          final vnum = int.tryParse(k.toString()) ?? 0;
          verses.add(BibleVerse(
            id: vnum,
            book: bookId,
            chapter: chapter,
            verse: vnum,
            text: text.toString(),
          ));
        }
      } else {
        return _getFallbackChapter(bookId, chapter);
      }
      
      _chapterCache[cacheKey] = verses;
      return verses;
      
    } catch (e) {
      print('Error loading chapter: $e');
      return _getFallbackChapter(bookId, chapter);
    }
  }
  
  Future<void> _loadBibleFromAssets(String version) async {
    try {
      final assetPath = _availableVersions[version];
      if (assetPath == null) {
        print('Version $version not found in available versions');
        return;
      }
      
      print('Loading Bible from: $assetPath');
      final jsonString = await rootBundle.loadString(assetPath);
      final Map<String, dynamic> bibleData = json.decode(jsonString);
      
      _bibleCache[version] = bibleData;
      print('✅ Successfully loaded $version Bible (${jsonString.length} chars)');
      
    } catch (e) {
      print('❌ Error loading Bible from assets: $e');
    }
  }
  
  List<BibleBook> _getFallbackBooks() {
    return [
      BibleBook(id: 1, name: 'Genesis', chapters: 50, testament: 'OT'),
      BibleBook(id: 2, name: 'Exodus', chapters: 40, testament: 'OT'),
      BibleBook(id: 3, name: 'Leviticus', chapters: 27, testament: 'OT'),
      BibleBook(id: 4, name: 'Numbers', chapters: 36, testament: 'OT'),
      BibleBook(id: 5, name: 'Deuteronomy', chapters: 34, testament: 'OT'),
      BibleBook(id: 6, name: 'Joshua', chapters: 24, testament: 'OT'),
      BibleBook(id: 7, name: 'Judges', chapters: 21, testament: 'OT'),
      BibleBook(id: 8, name: 'Ruth', chapters: 4, testament: 'OT'),
      BibleBook(id: 9, name: '1 Samuel', chapters: 31, testament: 'OT'),
      BibleBook(id: 10, name: '2 Samuel', chapters: 24, testament: 'OT'),
      BibleBook(id: 11, name: '1 Kings', chapters: 22, testament: 'OT'),
      BibleBook(id: 12, name: '2 Kings', chapters: 25, testament: 'OT'),
      BibleBook(id: 13, name: '1 Chronicles', chapters: 29, testament: 'OT'),
      BibleBook(id: 14, name: '2 Chronicles', chapters: 36, testament: 'OT'),
      BibleBook(id: 15, name: 'Ezra', chapters: 10, testament: 'OT'),
      BibleBook(id: 16, name: 'Nehemiah', chapters: 13, testament: 'OT'),
      BibleBook(id: 17, name: 'Esther', chapters: 10, testament: 'OT'),
      BibleBook(id: 18, name: 'Job', chapters: 42, testament: 'OT'),
      BibleBook(id: 19, name: 'Psalms', chapters: 150, testament: 'OT'),
      BibleBook(id: 20, name: 'Proverbs', chapters: 31, testament: 'OT'),
      BibleBook(id: 21, name: 'Ecclesiastes', chapters: 12, testament: 'OT'),
      BibleBook(id: 22, name: 'Song of Solomon', chapters: 8, testament: 'OT'),
      BibleBook(id: 23, name: 'Isaiah', chapters: 66, testament: 'OT'),
      BibleBook(id: 24, name: 'Jeremiah', chapters: 52, testament: 'OT'),
      BibleBook(id: 25, name: 'Lamentations', chapters: 5, testament: 'OT'),
      BibleBook(id: 26, name: 'Ezekiel', chapters: 48, testament: 'OT'),
      BibleBook(id: 27, name: 'Daniel', chapters: 12, testament: 'OT'),
      BibleBook(id: 28, name: 'Hosea', chapters: 14, testament: 'OT'),
      BibleBook(id: 29, name: 'Joel', chapters: 3, testament: 'OT'),
      BibleBook(id: 30, name: 'Amos', chapters: 9, testament: 'OT'),
      BibleBook(id: 31, name: 'Obadiah', chapters: 1, testament: 'OT'),
      BibleBook(id: 32, name: 'Jonah', chapters: 4, testament: 'OT'),
      BibleBook(id: 33, name: 'Micah', chapters: 7, testament: 'OT'),
      BibleBook(id: 34, name: 'Nahum', chapters: 3, testament: 'OT'),
      BibleBook(id: 35, name: 'Habakkuk', chapters: 3, testament: 'OT'),
      BibleBook(id: 36, name: 'Zephaniah', chapters: 3, testament: 'OT'),
      BibleBook(id: 37, name: 'Haggai', chapters: 2, testament: 'OT'),
      BibleBook(id: 38, name: 'Zechariah', chapters: 14, testament: 'OT'),
      BibleBook(id: 39, name: 'Malachi', chapters: 4, testament: 'OT'),
      
      BibleBook(id: 40, name: 'Matthew', chapters: 28, testament: 'NT'),
      BibleBook(id: 41, name: 'Mark', chapters: 16, testament: 'NT'),
      BibleBook(id: 42, name: 'Luke', chapters: 24, testament: 'NT'),
      BibleBook(id: 43, name: 'John', chapters: 21, testament: 'NT'),
      BibleBook(id: 44, name: 'Acts', chapters: 28, testament: 'NT'),
      BibleBook(id: 45, name: 'Romans', chapters: 16, testament: 'NT'),
      BibleBook(id: 46, name: '1 Corinthians', chapters: 16, testament: 'NT'),
      BibleBook(id: 47, name: '2 Corinthians', chapters: 13, testament: 'NT'),
      BibleBook(id: 48, name: 'Galatians', chapters: 6, testament: 'NT'),
      BibleBook(id: 49, name: 'Ephesians', chapters: 6, testament: 'NT'),
      BibleBook(id: 50, name: 'Philippians', chapters: 4, testament: 'NT'),
      BibleBook(id: 51, name: 'Colossians', chapters: 4, testament: 'NT'),
      BibleBook(id: 52, name: '1 Thessalonians', chapters: 5, testament: 'NT'),
      BibleBook(id: 53, name: '2 Thessalonians', chapters: 3, testament: 'NT'),
      BibleBook(id: 54, name: '1 Timothy', chapters: 6, testament: 'NT'),
      BibleBook(id: 55, name: '2 Timothy', chapters: 4, testament: 'NT'),
      BibleBook(id: 56, name: 'Titus', chapters: 3, testament: 'NT'),
      BibleBook(id: 57, name: 'Philemon', chapters: 1, testament: 'NT'),
      BibleBook(id: 58, name: 'Hebrews', chapters: 13, testament: 'NT'),
      BibleBook(id: 59, name: 'James', chapters: 5, testament: 'NT'),
      BibleBook(id: 60, name: '1 Peter', chapters: 5, testament: 'NT'),
      BibleBook(id: 61, name: '2 Peter', chapters: 3, testament: 'NT'),
      BibleBook(id: 62, name: '1 John', chapters: 5, testament: 'NT'),
      BibleBook(id: 63, name: '2 John', chapters: 1, testament: 'NT'),
      BibleBook(id: 64, name: '3 John', chapters: 1, testament: 'NT'),
      BibleBook(id: 65, name: 'Jude', chapters: 1, testament: 'NT'),
      BibleBook(id: 66, name: 'Revelation', chapters: 22, testament: 'NT'),
    ];
  }
  
  List<BibleVerse> _getFallbackChapter(int bookId, int chapter) {
    return List.generate(10, (index) {
      final verse = index + 1;
      return BibleVerse(
        id: verse,
        book: bookId,
        chapter: chapter,
        verse: verse,
        text: 'This is verse $verse. The complete Bible content is being loaded from the JSON files. Please ensure the Bible files are in the assets/bible/ folder.',
      );
    });
  }
}
