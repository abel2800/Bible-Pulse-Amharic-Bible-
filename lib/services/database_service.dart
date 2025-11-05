import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import '../models/highlight.dart';
import '../models/note.dart';
import '../models/bookmark.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;
  
  factory DatabaseService() => _instance;
  
  DatabaseService._internal();
  
  Future<Database> get database async {
    if (kIsWeb) {
      throw UnsupportedError('Database not available on web');
    }
    
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'bible_pulse.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }
  
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE highlights (
        id TEXT PRIMARY KEY,
        verseReference TEXT NOT NULL,
        text TEXT NOT NULL,
        color INTEGER NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');
    
    await db.execute('''
      CREATE TABLE notes (
        id TEXT PRIMARY KEY,
        verseReference TEXT NOT NULL,
        text TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
    
    await db.execute('''
      CREATE TABLE bookmarks (
        id TEXT PRIMARY KEY,
        verseReference TEXT NOT NULL,
        text TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');
  }
  
  Future<void> insertHighlight(Highlight highlight) async {
    final db = await database;
    await db.insert(
      'highlights',
      highlight.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  Future<List<Highlight>> getHighlights() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('highlights');
    return List.generate(maps.length, (i) => Highlight.fromJson(maps[i]));
  }
  
  Future<void> deleteHighlight(String verseReference) async {
    final db = await database;
    await db.delete(
      'highlights',
      where: 'verseReference = ?',
      whereArgs: [verseReference],
    );
  }
  
  Future<void> insertNote(Note note) async {
    final db = await database;
    await db.insert(
      'notes',
      note.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  Future<void> updateNote(Note note) async {
    final db = await database;
    await db.update(
      'notes',
      note.toJson(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }
  
  Future<List<Note>> getNotes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('notes');
    return List.generate(maps.length, (i) => Note.fromJson(maps[i]));
  }
  
  Future<void> deleteNote(String id) async {
    final db = await database;
    await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  Future<void> insertBookmark(Bookmark bookmark) async {
    final db = await database;
    await db.insert(
      'bookmarks',
      bookmark.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  Future<List<Bookmark>> getBookmarks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('bookmarks');
    return List.generate(maps.length, (i) => Bookmark.fromJson(maps[i]));
  }
  
  Future<void> deleteBookmark(String verseReference) async {
    final db = await database;
    await db.delete(
      'bookmarks',
      where: 'verseReference = ?',
      whereArgs: [verseReference],
    );
  }
  
  Future<void> insertUserReadingPlan(dynamic plan) async {
    debugPrint('insertUserReadingPlan called - not yet implemented');
  }
  
  Future<void> updateUserReadingPlan(dynamic plan) async {
    debugPrint('updateUserReadingPlan called - not yet implemented');
  }
  
  Future<List> getUserReadingPlans() async {
    debugPrint('getUserReadingPlans called - not yet implemented');
    return [];
  }
  
  Future<dynamic> getUserReadingPlanByPlanId(String planId) async {
    debugPrint('getUserReadingPlanByPlanId called - not yet implemented');
    return null;
  }
  
  Future<void> deleteUserReadingPlan(String id) async {
    debugPrint('deleteUserReadingPlan called - not yet implemented');
  }
}

