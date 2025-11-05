class Hymn {
  final String id;
  final String number;
  final String title;
  final String? subtitle;
  final List<String> verses;
  final String? chorus;
  final String? author;
  final String? composer;
  final int? year;
  final String? category;
  final List<String> tags;
  final String? tune;
  final String? scripture;
  final String? audioUrl;
  final bool isFavorite;
  
  Hymn({
    required this.id,
    required this.number,
    required this.title,
    this.subtitle,
    required this.verses,
    this.chorus,
    this.author,
    this.composer,
    this.year,
    this.category,
    List<String>? tags,
    this.tune,
    this.scripture,
    this.audioUrl,
    this.isFavorite = false,
  }) : tags = tags ?? [];
  
  factory Hymn.fromJson(Map<String, dynamic> json) {
    return Hymn(
      id: json['id'] ?? '',
      number: json['number'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'],
      verses: List<String>.from(json['verses'] ?? []),
      chorus: json['chorus'],
      author: json['author'],
      composer: json['composer'],
      year: json['year'],
      category: json['category'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      tune: json['tune'],
      scripture: json['scripture'],
      audioUrl: json['audioUrl'],
      isFavorite: json['isFavorite'] ?? false,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'title': title,
      'subtitle': subtitle,
      'verses': verses,
      'chorus': chorus,
      'author': author,
      'composer': composer,
      'year': year,
      'category': category,
      'tags': tags,
      'tune': tune,
      'scripture': scripture,
      'audioUrl': audioUrl,
      'isFavorite': isFavorite,
    };
  }
  
  Hymn copyWith({
    String? id,
    String? number,
    String? title,
    String? subtitle,
    List<String>? verses,
    String? chorus,
    String? author,
    String? composer,
    int? year,
    String? category,
    List<String>? tags,
    String? tune,
    String? scripture,
    String? audioUrl,
    bool? isFavorite,
  }) {
    return Hymn(
      id: id ?? this.id,
      number: number ?? this.number,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      verses: verses ?? this.verses,
      chorus: chorus ?? this.chorus,
      author: author ?? this.author,
      composer: composer ?? this.composer,
      year: year ?? this.year,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      tune: tune ?? this.tune,
      scripture: scripture ?? this.scripture,
      audioUrl: audioUrl ?? this.audioUrl,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
  
  String get fullText {
    final buffer = StringBuffer();
    
    for (var i = 0; i < verses.length; i++) {
      buffer.writeln('${i + 1}. ${verses[i]}');
      
      if (chorus != null && i < verses.length - 1) {
        buffer.writeln('\nChorus:');
        buffer.writeln(chorus);
        buffer.writeln();
      }
    }
    
    return buffer.toString();
  }
}

class HymnCategory {
  final String id;
  final String name;
  final String? description;
  final String? iconName;
  
  HymnCategory({
    required this.id,
    required this.name,
    this.description,
    this.iconName,
  });
  
  static List<HymnCategory> get defaultCategories => [
    HymnCategory(
      id: 'worship',
      name: 'Worship & Praise',
      description: 'Songs of worship and adoration',
      iconName: 'music',
    ),
    HymnCategory(
      id: 'thanksgiving',
      name: 'Thanksgiving',
      description: 'Songs of gratitude',
      iconName: 'heart',
    ),
    HymnCategory(
      id: 'prayer',
      name: 'Prayer & Devotion',
      description: 'Devotional hymns',
      iconName: 'hands_praying',
    ),
    HymnCategory(
      id: 'christmas',
      name: 'Christmas',
      description: 'Christmas carols',
      iconName: 'star',
    ),
    HymnCategory(
      id: 'easter',
      name: 'Easter',
      description: 'Easter hymns',
      iconName: 'cross',
    ),
    HymnCategory(
      id: 'missions',
      name: 'Missions & Evangelism',
      description: 'Songs about spreading the gospel',
      iconName: 'globe',
    ),
    HymnCategory(
      id: 'comfort',
      name: 'Comfort & Assurance',
      description: 'Songs of comfort and peace',
      iconName: 'dove',
    ),
    HymnCategory(
      id: 'consecration',
      name: 'Consecration & Dedication',
      description: 'Songs of commitment',
      iconName: 'flame',
    ),
  ];
}

