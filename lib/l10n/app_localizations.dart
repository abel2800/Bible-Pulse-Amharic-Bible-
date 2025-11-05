import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en', ''), // English
    Locale('am', ''), // Amharic
  ];

  String get appName => locale.languageCode == 'am' ? 'የመጽሐፍ ህይወት' : 'BiblePulse';
  String get goodMorning => locale.languageCode == 'am' ? 'እንደምን አደርክ' : 'Good Morning';
  String get goodAfternoon => locale.languageCode == 'am' ? 'እንደምን ዋልክ' : 'Good Afternoon';
  String get goodEvening => locale.languageCode == 'am' ? 'እንደምን አመሽህ' : 'Good Evening';
  String get welcomeBack => locale.languageCode == 'am' ? 'እንኳን ደህና መጣህ' : 'Welcome back to your daily devotional';
  
  String get readBible => locale.languageCode == 'am' ? 'መጽሐፍ ቅዱስ አንብብ' : 'Read Bible';
  String get myStudy => locale.languageCode == 'am' ? 'ጥናቴ' : 'My Study';
  String get createWallpaper => locale.languageCode == 'am' ? 'ልስ ፡ ሥዕል ፍጠር' : 'Create Wallpaper';
  String get setReminder => locale.languageCode == 'am' ? 'ማስታወሻ ያስቀምጡ' : 'Set Reminder';
  String get quickActions => locale.languageCode == 'am' ? 'ፈጣን እርምጃዎች' : 'Quick Actions';
  
  String get verseOfTheDay => locale.languageCode == 'am' ? 'የዛሬው ቃል' : 'Verse of the Day';
  String get dailyPrayer => locale.languageCode == 'am' ? 'የዕለት ፀሎት' : 'Daily Prayer';
  String get share => locale.languageCode == 'am' ? 'አጋራ' : 'Share';
  String get wallpaper => locale.languageCode == 'am' ? 'ልስ ፡ ሥዕል' : 'Wallpaper';
  
  String get selectBook => locale.languageCode == 'am' ? 'መጽሐፍ ይምረጡ' : 'Select Book';
  String get chapter => locale.languageCode == 'am' ? 'ምዕራፍ' : 'Chapter';
  String get chapters => locale.languageCode == 'am' ? 'ምዕራፎች' : 'chapters';
  String get previous => locale.languageCode == 'am' ? 'ቀዳሚ' : 'Previous';
  String get next => locale.languageCode == 'am' ? 'ቀጣይ' : 'Next';
  String get chooseBookToRead => locale.languageCode == 'am' ? 'ለማንበብ መጽሐፍ ይምረጡ' : 'Choose a Book to Read';
  String get tapBookName => locale.languageCode == 'am' ? 'ለመጀመር ከላይ የመጽሐፉን ስም መታ ያድርጉ' : 'Tap the book name above to get started';
  String get browseBooks => locale.languageCode == 'am' ? 'መጻሕፍትን አስስ' : 'Browse Books';
  String get changeVersion => locale.languageCode == 'am' ? 'ስሪት ይቀይሩ' : 'Change Version';
  String get loadingScripture => locale.languageCode == 'am' ? 'መጽሐፍ ቅዱስ በመጫን ላይ...' : 'Loading Scripture...';
  String get oldTestament => locale.languageCode == 'am' ? 'የብሉይ ኪዳን' : 'Old Testament';
  String get newTestament => locale.languageCode == 'am' ? 'የአዲስ ኪዳን' : 'New Testament';
  String get selectChapter => locale.languageCode == 'am' ? 'ምዕራፍ ይምረጡ' : 'Select Chapter';
  String get selectVersion => locale.languageCode == 'am' ? 'ስሪት ይምረጡ' : 'Select Version';
  
  String get highlights => locale.languageCode == 'am' ? 'ምርጥ ነጥቦች' : 'Highlights';
  String get notes => locale.languageCode == 'am' ? 'ማስታወሻዎች' : 'Notes';
  String get bookmarks => locale.languageCode == 'am' ? 'ምልክቶች' : 'Bookmarks';
  String get highlightColor => locale.languageCode == 'am' ? 'የማድመቅ ቀለም' : 'Highlight Color';
  String get addNote => locale.languageCode == 'am' ? 'ማስታወሻ አክል' : 'Add Note';
  String get bookmark => locale.languageCode == 'am' ? 'ምልክት' : 'Bookmark';
  String get bookmarked => locale.languageCode == 'am' ? 'ምልክት ተደርጓል' : 'Bookmarked';
  String get verseHighlighted => locale.languageCode == 'am' ? '✨ ጥቅስ ምርጥ ሆኗል!' : '✨ Verse highlighted!';
  String get highlightRemoved => locale.languageCode == 'am' ? 'ምርጥ ነጥብ ተወግዷል' : 'Highlight removed';
  String get noHighlights => locale.languageCode == 'am' ? 'ምርጥ ነጥቦች የሉም' : 'No highlights yet';
  String get noNotes => locale.languageCode == 'am' ? 'ማስታወሻዎች የሉም' : 'No notes yet';
  String get noBookmarks => locale.languageCode == 'am' ? 'ምልክቶች የሉም' : 'No bookmarks yet';
  
  String get settings => locale.languageCode == 'am' ? 'ቅንብሮች' : 'Settings';
  String get appearance => locale.languageCode == 'am' ? 'መልክ' : 'Appearance';
  String get theme => locale.languageCode == 'am' ? 'ገጽታ' : 'Theme';
  String get light => locale.languageCode == 'am' ? 'ብሩህ' : 'Light';
  String get dark => locale.languageCode == 'am' ? 'ጨለማ' : 'Dark';
  String get systemDefault => locale.languageCode == 'am' ? 'የስርዓት ነባሪ' : 'System Default';
  String get language => locale.languageCode == 'am' ? 'ቋንቋ' : 'Language';
  String get notifications => locale.languageCode == 'am' ? 'ማሳወቂያዎች' : 'Notifications';
  String get dailyDevotional => locale.languageCode == 'am' ? 'የዕለት ተከታታይ' : 'Daily Devotional';
  String get notificationTime => locale.languageCode == 'am' ? 'የማሳወቂያ ጊዜ' : 'Notification Time';
  String get receiveDailyVerse => locale.languageCode == 'am' ? 'የዕለት ቃልና ፀሎት ተቀበል' : 'Receive daily verse and prayer';
  String get chooseTheme => locale.languageCode == 'am' ? 'ገጽታ ይምረጡ' : 'Choose Theme';
  String get scheduledFor => locale.languageCode == 'am' ? 'ተይዟል ለ' : 'scheduled for';
  
  String get save => locale.languageCode == 'am' ? 'አስቀምጥ' : 'Save';
  String get cancel => locale.languageCode == 'am' ? 'ይቅር' : 'Cancel';
  String get ok => locale.languageCode == 'am' ? 'እሺ' : 'OK';
  String get close => locale.languageCode == 'am' ? 'ዝጋ' : 'Close';
  String get delete => locale.languageCode == 'am' ? 'ሰርዝ' : 'Delete';
  String get edit => locale.languageCode == 'am' ? 'አርትዕ' : 'Edit';
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'am'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

