import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/bible_service.dart';
import '../services/notification_service.dart';

class ReminderProvider extends ChangeNotifier {
  ReminderProvider({
    NotificationService? notificationService,
    BibleService? bibleService,
  })  : _notificationService = notificationService ?? NotificationService(),
        _bibleService = bibleService ?? BibleService();

  final NotificationService _notificationService;
  final BibleService _bibleService;

  static const themes = ['peace', 'strength', 'gratitude'];
  String _theme = 'peace';

  String get theme => _theme;

  Future<void> initialize() async {
    final preferences = await SharedPreferences.getInstance();
    _theme = preferences.getString('notification_theme') ?? 'peace';
    notifyListeners();
  }

  Future<bool> enableThemeNotification({
    required String theme,
    required int hour,
    required int minute,
  }) async {
    final selection =
        <String, ({int book, int chapter, int verse, String reference})>{
      'peace': (book: 19, chapter: 4, verse: 8, reference: 'Psalm 4:8'),
      'strength': (book: 23, chapter: 41, verse: 10, reference: 'Isaiah 41:10'),
      'gratitude': (
        book: 52,
        chapter: 5,
        verse: 18,
        reference: '1 Thessalonians 5:18',
      ),
    }[theme];
    if (selection == null) return false;

    final granted = await _notificationService.requestPermissions();
    if (!granted) return false;

    final chapter = await _bibleService.getChapter(
      'WEB',
      selection.book,
      selection.chapter,
    );
    final index = chapter.indexWhere((item) => item.verse == selection.verse);
    if (index == -1) return false;

    await _notificationService.scheduleDailyDevotional(
      title:
          '${theme[0].toUpperCase()}${theme.substring(1)} · ${selection.reference}',
      body: chapter[index].text,
      hour: hour,
      minute: minute,
    );
    _theme = theme;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('notification_theme', theme);
    notifyListeners();
    return true;
  }
}
