class ReadingHistory {
  final String id;
  final String bookName;
  final int chapter;
  final int? verse;
  final DateTime timestamp;
  final String? bibleVersion;
  final int durationSeconds;
  
  ReadingHistory({
    required this.id,
    required this.bookName,
    required this.chapter,
    this.verse,
    required this.timestamp,
    this.bibleVersion,
    this.durationSeconds = 0,
  });
  
  factory ReadingHistory.fromJson(Map<String, dynamic> json) {
    return ReadingHistory(
      id: json['id'],
      bookName: json['bookName'],
      chapter: json['chapter'],
      verse: json['verse'],
      timestamp: DateTime.parse(json['timestamp']),
      bibleVersion: json['bibleVersion'],
      durationSeconds: json['durationSeconds'] ?? 0,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookName': bookName,
      'chapter': chapter,
      'verse': verse,
      'timestamp': timestamp.toIso8601String(),
      'bibleVersion': bibleVersion,
      'durationSeconds': durationSeconds,
    };
  }
  
  String get reference {
    if (verse != null) {
      return '$bookName $chapter:$verse';
    }
    return '$bookName $chapter';
  }
  
  String get formattedDuration {
    if (durationSeconds < 60) {
      return '$durationSeconds seconds';
    } else if (durationSeconds < 3600) {
      final minutes = (durationSeconds / 60).floor();
      return '$minutes minute${minutes > 1 ? 's' : ''}';
    } else {
      final hours = (durationSeconds / 3600).floor();
      final minutes = ((durationSeconds % 3600) / 60).floor();
      return '$hours hour${hours > 1 ? 's' : ''} $minutes minute${minutes > 1 ? 's' : ''}';
    }
  }
}

class ReadingStats {
  final int totalReadingSessions;
  final int totalReadingTimeSeconds;
  final int totalChaptersRead;
  final int consecutiveDays;
  final DateTime? lastReadDate;
  final Map<String, int> booksRead;
  final List<DateTime> readingDates;
  
  ReadingStats({
    this.totalReadingSessions = 0,
    this.totalReadingTimeSeconds = 0,
    this.totalChaptersRead = 0,
    this.consecutiveDays = 0,
    this.lastReadDate,
    Map<String, int>? booksRead,
    List<DateTime>? readingDates,
  }) : booksRead = booksRead ?? {},
       readingDates = readingDates ?? [];
  
  String get formattedTotalTime {
    if (totalReadingTimeSeconds < 3600) {
      final minutes = (totalReadingTimeSeconds / 60).floor();
      return '$minutes minute${minutes != 1 ? 's' : ''}';
    } else {
      final hours = (totalReadingTimeSeconds / 3600).floor();
      return '$hours hour${hours != 1 ? 's' : ''}';
    }
  }
  
  int get uniqueBooksRead => booksRead.length;
  
  double get averageSessionMinutes {
    if (totalReadingSessions == 0) return 0;
    return (totalReadingTimeSeconds / 60) / totalReadingSessions;
  }
}

