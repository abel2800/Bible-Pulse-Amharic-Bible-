import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../models/bible_verse.dart';
import '../models/devotional_author.dart';
import '../models/hymn.dart';

class ShareService {
  static final ShareService _instance = ShareService._internal();
  factory ShareService() => _instance;
  ShareService._internal();
  
  Future<void> shareVerse({
    required String text,
    required String reference,
    String? version,
  }) async {
    final versionText = version != null ? ' ($version)' : '';
    final shareText = '''
"$text"

— $reference$versionText

Shared from BiblePulse 📖
''';
    
    await Share.share(
      shareText,
      subject: reference,
    );
  }
  
  Future<void> shareVerses({
    required List<String> verses,
    required String reference,
    String? version,
  }) async {
    final versionText = version != null ? ' ($version)' : '';
    final versesText = verses.map((v) => '"$v"').join('\n\n');
    final shareText = '''
$versesText

— $reference$versionText

Shared from BiblePulse 📖
''';
    
    await Share.share(
      shareText,
      subject: reference,
    );
  }
  
  Future<void> shareDevotional(EnhancedDevotional devotional) async {
    final shareText = '''
📖 ${devotional.name}
by ${devotional.author.name}

${devotional.text}

Scripture: ${devotional.verse}
${devotional.verseIndex}

Prayer: ${devotional.prayer}

Shared from BiblePulse 📖
''';
    
    await Share.share(
      shareText,
      subject: devotional.name,
    );
  }
  
  Future<void> shareHymn(Hymn hymn) async {
    final shareText = '''
🎵 Hymn #${hymn.number}: ${hymn.title}

${hymn.fullText}

${hymn.author != null ? 'By ${hymn.author}' : ''}

Shared from BiblePulse 📖
''';
    
    await Share.share(
      shareText,
      subject: '${hymn.number}. ${hymn.title}',
    );
  }
  
  Future<void> shareReadingPlanProgress({
    required String planName,
    required int daysCompleted,
    required int totalDays,
    required double progress,
  }) async {
    final progressPercent = (progress * 100).toStringAsFixed(0);
    final shareText = '''
📚 Reading Plan Progress

Plan: $planName
Days Completed: $daysCompleted of $totalDays
Progress: $progressPercent%

Join me in reading God's Word! 

Shared from BiblePulse 📖
''';
    
    await Share.share(
      shareText,
      subject: 'My Reading Plan Progress',
    );
  }
  
  Future<void> shareReadingStreak(int consecutiveDays) async {
    String emoji = '🔥';
    String message = 'I\'ve been reading God\'s Word for $consecutiveDays consecutive day${consecutiveDays > 1 ? 's' : ''}!';
    
    if (consecutiveDays >= 365) {
      emoji = '🏆';
      message = 'Amazing! I\'ve maintained a reading streak for over a year!';
    } else if (consecutiveDays >= 100) {
      emoji = '🎉';
      message = 'I\'ve been reading God\'s Word for $consecutiveDays days straight!';
    } else if (consecutiveDays >= 30) {
      emoji = '⭐';
    }
    
    final shareText = '''
$emoji Reading Streak: $consecutiveDays Days!

$message

#BibleReading #Consistency #Faith

Shared from BiblePulse 📖
''';
    
    await Share.share(
      shareText,
      subject: 'My Reading Streak',
    );
  }
  
  Future<void> copyToClipboard({
    required String text,
    required String reference,
    required BuildContext context,
  }) async {
    final copyText = '"$text"\n\n— $reference';
    
    await Clipboard.setData(ClipboardData(text: copyText));
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
  
  Future<void> shareAppInvitation() async {
    const shareText = '''
📱 Check out BiblePulse!

A beautiful Bible app with:
📖 Multiple translations
✨ Daily devotionals
📚 Reading plans
🎵 Hymn library
📊 Progress tracking

Download now and grow in your faith! 🙏

[App Store / Play Store Link]

Shared from BiblePulse 📖
''';
    
    await Share.share(shareText, subject: 'Try BiblePulse App');
  }
  
  Future<void> shareCustomMessage({
    required String message,
    String? reference,
  }) async {
    final referenceText = reference != null ? '\n\n— $reference' : '';
    final shareText = '''
$message$referenceText

Shared from BiblePulse 📖
''';
    
    await Share.share(shareText);
  }
  
  Future<void> shareVerseAsImage({
    required String text,
    required String reference,
    required BuildContext context,
  }) async {
    
    await shareVerse(text: text, reference: reference);
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image sharing coming soon! Shared as text.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}

