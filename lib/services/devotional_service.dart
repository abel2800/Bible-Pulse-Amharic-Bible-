import 'dart:ui';
import '../models/devotional.dart';

class DevotionalService {
  Future<Devotional> getTodayDevotional({Locale? locale}) async {
    final now = DateTime.now();
    final dateKey = '${now.year}-${now.month}-${now.day}';

    if (locale != null && locale.languageCode == 'am') {
      return Devotional(
        id: dateKey,
        date: now,
        dailyVerse: 'እኔ ለናንተ ያገኘሁትን እቅዶች እነሆ የምልክት ነው፤ ሰላምና ለማግኘት እቅዶች ናቸው።',
        verseReference: 'ጄረሚያስ 29:11',
        dailyPrayer: 'ሰማያዊ አባታችን እየልክህ እናመስግናለን። በእርስዎ እቅድ እንዲመሩን ረዳን። እንዲሁም ሰላምን ስንፈልግ እርስዎን እንድናገኝ አስችል። አሜን።',
      );
    }

    return Devotional(
      id: dateKey,
      date: now,
      dailyVerse: 'For I know the plans I have for you, declares the LORD, plans for welfare and not for evil, to give you a future and a hope.',
      verseReference: 'Jeremiah 29:11',
      dailyPrayer: 'Heavenly Father, thank You for Your perfect plans for my life. Help me to trust in Your timing and guidance. Give me the strength to walk in faith, knowing that You are always working for my good. May I find peace in Your presence today and always. In Jesus\' name, Amen.',
    );
  }
  
  List<Devotional> getSampleDevotionals() {
    return [
      Devotional(
        id: '1',
        date: DateTime.now(),
        dailyVerse: 'Trust in the LORD with all your heart, and do not lean on your own understanding.',
        verseReference: 'Proverbs 3:5',
        dailyPrayer: 'Lord, help me to trust You completely and not rely on my own limited understanding. Guide my steps today.',
      ),
      Devotional(
        id: '2',
        date: DateTime.now().subtract(const Duration(days: 1)),
        dailyVerse: 'I can do all things through Christ who strengthens me.',
        verseReference: 'Philippians 4:13',
        dailyPrayer: 'Dear God, remind me that with Your strength, I can overcome any challenge. Fill me with Your power today.',
      ),
      Devotional(
        id: '3',
        date: DateTime.now().subtract(const Duration(days: 2)),
        dailyVerse: 'Be still, and know that I am God.',
        verseReference: 'Psalm 46:10',
        dailyPrayer: 'Father, in the midst of life\'s busyness, help me to be still and recognize Your sovereignty. Give me peace.',
      ),
    ];
  }
}

