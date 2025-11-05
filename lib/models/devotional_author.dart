class DevotionalAuthor {
  final String id;
  final String name;
  final String? url;
  final String? imageUrl;
  final String? bio;
  
  DevotionalAuthor({
    required this.id,
    required this.name,
    this.url,
    this.imageUrl,
    this.bio,
  });
  
  factory DevotionalAuthor.fromJson(Map<String, dynamic> json) {
    return DevotionalAuthor(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      url: json['url'],
      imageUrl: json['imageUrl'],
      bio: json['bio'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'imageUrl': imageUrl,
      'bio': bio,
    };
  }
}

class EnhancedDevotional {
  final String id;
  final String name;
  final String text;
  final String verse;
  final String verseIndex;
  final String prayer;
  final String date; // Format: MMDD
  final String? ari; // Bible reference index
  final String? figure; // Image URL
  final String orgUrl;
  final DevotionalAuthor author;
  
  EnhancedDevotional({
    required this.id,
    required this.name,
    required this.text,
    required this.verse,
    required this.verseIndex,
    required this.prayer,
    required this.date,
    this.ari,
    this.figure,
    required this.orgUrl,
    required this.author,
  });
  
  factory EnhancedDevotional.fromJson(Map<String, dynamic> json) {
    return EnhancedDevotional(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      text: json['text'] ?? '',
      verse: json['verse'] ?? '',
      verseIndex: json['verseIndex'] ?? '',
      prayer: json['prayer'] ?? '',
      date: json['date'] ?? '',
      ari: json['ari'],
      figure: json['figure'],
      orgUrl: json['orgUrl'] ?? '',
      author: DevotionalAuthor.fromJson(json['author'] ?? {}),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'text': text,
      'verse': verse,
      'verseIndex': verseIndex,
      'prayer': prayer,
      'date': date,
      'ari': ari,
      'figure': figure,
      'orgUrl': orgUrl,
      'author': author.toJson(),
    };
  }
  
  int get month => int.parse(date.substring(0, 2));
  int get day => int.parse(date.substring(2, 4));
  
  DateTime get dateTime {
    final now = DateTime.now();
    return DateTime(now.year, month, day);
  }
}

class DevotionalAuthors {
  static final billyGraham = DevotionalAuthor(
    id: 'billy_graham',
    name: 'Billy Graham',
    url: 'http://billygraham.org/author/billy-graham/',
    bio: 'Billy Graham was a renowned evangelist and spiritual adviser to U.S. presidents.',
  );
  
  static final charlesSpurgeon = DevotionalAuthor(
    id: 'charles_spurgeon',
    name: 'Charles Spurgeon',
    url: 'https://www.spurgeon.org/',
    bio: 'Charles Spurgeon was a British Baptist preacher known as the "Prince of Preachers".',
  );
  
  static final rickWarren = DevotionalAuthor(
    id: 'rick_warren',
    name: 'Rick Warren',
    url: 'https://pastorrick.com/',
    bio: 'Rick Warren is the founding pastor of Saddleback Church and author of "The Purpose Driven Life".',
  );
  
  static final ourDailyJourney = DevotionalAuthor(
    id: 'our_daily_journey',
    name: 'Our Daily Journey',
    url: 'https://ourdailyjourney.org/',
    bio: 'Our Daily Journey provides daily devotional readings for spiritual growth.',
  );
  
  static List<DevotionalAuthor> get all => [
    billyGraham,
    charlesSpurgeon,
    rickWarren,
    ourDailyJourney,
  ];
  
  static DevotionalAuthor? getById(String id) {
    try {
      return all.firstWhere((author) => author.id == id);
    } catch (e) {
      return null;
    }
  }
}

