import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/bible_service.dart';
import '../services/daily_verse_service.dart';
import '../services/notification_service.dart';
import '../utils/streak_copy.dart';

class ReminderProvider extends ChangeNotifier {
  ReminderProvider({
    NotificationService? notificationService,
    BibleService? bibleService,
  })  : _notificationService = notificationService ?? NotificationService(),
        _bibleService = bibleService ?? BibleService() {
    _dailyVerseService = DailyVerseService(bibleService: _bibleService);
  }

  final NotificationService _notificationService;
  final BibleService _bibleService;
  late final DailyVerseService _dailyVerseService;

  static const themes = ['peace', 'strength', 'gratitude'];
  static const _enabledKey = 'daily_verse_reminder_enabled';
  static const _hourKey = 'daily_verse_reminder_hour';
  static const _minuteKey = 'daily_verse_reminder_minute';
  static const _themeKey = 'notification_theme';
  static const _streakNudgeHour = 19;

  String _theme = 'peace';
  bool _enabled = false;
  int _hour = 8;
  int _minute = 0;

  String get theme => _theme;
  bool get enabled => _enabled;
  int get hour => _hour;
  int get minute => _minute;

  Future<void> initialize() async {
    final preferences = await SharedPreferences.getInstance();
    _theme = preferences.getString(_themeKey) ?? 'peace';
    _enabled = preferences.getBool(_enabledKey) ?? true;
    _hour = preferences.getInt(_hourKey) ?? 8;
    _minute = preferences.getInt(_minuteKey) ?? 0;
    notifyListeners();

    if (_enabled && !kIsWeb) {
      await scheduleDailyVerseReminder(
        hour: _hour,
        minute: _minute,
        requestPermission: false,
      );
    }
  }

  Future<bool> enableThemeNotification({
    required String theme,
    required int hour,
    required int minute,
  }) async {
    _theme = theme;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_themeKey, theme);
    return scheduleDailyVerseReminder(
      hour: hour,
      minute: minute,
      requestPermission: true,
    );
  }

  /// Morning Verse of the Day + evening streak keep-alive.
  Future<bool> scheduleDailyVerseReminder({
    required int hour,
    required int minute,
    bool requestPermission = true,
    int streak = 0,
    bool readToday = false,
  }) async {
    if (kIsWeb) return false;

    if (requestPermission) {
      final granted = await _notificationService.requestPermissions();
      if (!granted) return false;
    }

    final verse = await _dailyVerseService.verseForToday(versionId: 'WEB');
    if (verse == null) return false;

    final bookName = _bookName(verse.book);
    final reference = '$bookName ${verse.chapter}:${verse.verse}';
    final preview = verse.text.length > 140
        ? '${verse.text.substring(0, 137)}…'
        : verse.text;

    await _notificationService.scheduleDailyDevotional(
      title: StreakCopy.morningNotificationTitle(streak),
      body: '$reference — $preview',
      hour: hour,
      minute: minute,
    );

    await _notificationService.scheduleStreakReminder(
      title: StreakCopy.eveningNotificationTitle(streak),
      body: StreakCopy.eveningNotificationBody(
        streak: streak,
        readToday: readToday,
      ),
      hour: _streakNudgeHour,
      minute: 0,
    );

    _enabled = true;
    _hour = hour;
    _minute = minute;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_enabledKey, true);
    await preferences.setInt(_hourKey, hour);
    await preferences.setInt(_minuteKey, minute);
    notifyListeners();
    return true;
  }

  /// Call after streak changes so evening nudge text stays accurate.
  Future<void> refreshStreakNotifications({
    required int streak,
    required bool readToday,
  }) async {
    if (!_enabled || kIsWeb) return;
    await scheduleDailyVerseReminder(
      hour: _hour,
      minute: _minute,
      requestPermission: false,
      streak: streak,
      readToday: readToday,
    );
  }

  Future<void> disableDailyVerseReminder() async {
    await _notificationService.cancelAllEngagementReminders();
    _enabled = false;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_enabledKey, false);
    notifyListeners();
  }

  String _bookName(int bookId) {
    const names = {
      1: 'Genesis',
      2: 'Exodus',
      3: 'Leviticus',
      4: 'Numbers',
      5: 'Deuteronomy',
      6: 'Joshua',
      8: 'Ruth',
      9: '1 Samuel',
      10: '2 Samuel',
      11: '1 Kings',
      13: '1 Chronicles',
      14: '2 Chronicles',
      16: 'Nehemiah',
      18: 'Job',
      19: 'Psalm',
      20: 'Proverbs',
      21: 'Ecclesiastes',
      23: 'Isaiah',
      24: 'Jeremiah',
      25: 'Lamentations',
      27: 'Daniel',
      29: 'Joel',
      33: 'Micah',
      35: 'Habakkuk',
      36: 'Zephaniah',
      40: 'Matthew',
      41: 'Mark',
      42: 'Luke',
      43: 'John',
      44: 'Acts',
      45: 'Romans',
      46: '1 Corinthians',
      47: '2 Corinthians',
      48: 'Galatians',
      49: 'Ephesians',
      50: 'Philippians',
      51: 'Colossians',
      52: '1 Thessalonians',
      55: '2 Timothy',
      58: 'Hebrews',
      59: 'James',
      60: '1 Peter',
      62: '1 John',
      66: 'Revelation',
    };
    return names[bookId] ?? 'Bible';
  }
}
