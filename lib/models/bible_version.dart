class BibleVersion {
  final String id;
  final String name;
  final String shortName;
  final String language;
  final String description;
  final bool isDownloaded;
  final bool isActive;
  final int sizeInMB;
  final String downloadUrl;
  final String year;
  final List<String> features;
  
  BibleVersion({
    required this.id,
    required this.name,
    required this.shortName,
    required this.language,
    required this.description,
    this.isDownloaded = false,
    this.isActive = false,
    this.sizeInMB = 0,
    required this.downloadUrl,
    required this.year,
    List<String>? features,
  }) : features = features ?? [];
  
  factory BibleVersion.fromJson(Map<String, dynamic> json) {
    return BibleVersion(
      id: json['id'],
      name: json['name'],
      shortName: json['shortName'],
      language: json['language'],
      description: json['description'] ?? '',
      isDownloaded: json['isDownloaded'] ?? false,
      isActive: json['isActive'] ?? false,
      sizeInMB: json['sizeInMB'] ?? 0,
      downloadUrl: json['downloadUrl'] ?? '',
      year: json['year'] ?? '',
      features: json['features'] != null ? List<String>.from(json['features']) : [],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'shortName': shortName,
      'language': language,

      'description': description,
      'isDownloaded': isDownloaded,
      'isActive': isActive,
      'sizeInMB': sizeInMB,
      'downloadUrl': downloadUrl,
      'year': year,
      'features': features,
    };
  }
  
  BibleVersion copyWith({
    String? id,
    String? name,
    String? shortName,
    String? language,
    String? description,
    bool? isDownloaded,
    bool? isActive,
    int? sizeInMB,
    String? downloadUrl,
    String? year,
    List<String>? features,
  }) {
    return BibleVersion(
      id: id ?? this.id,
      name: name ?? this.name,
      shortName: shortName ?? this.shortName,
      language: language ?? this.language,
      description: description ?? this.description,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      isActive: isActive ?? this.isActive,
      sizeInMB: sizeInMB ?? this.sizeInMB,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      year: year ?? this.year,
      features: features ?? this.features,
    );
  }
  
  static List<BibleVersion> get availableVersions => [
    BibleVersion(
      id: 'kjv',
      name: 'King James Version',
      shortName: 'KJV',
      language: 'English',
      description: 'The classic 1611 translation',
      year: '1611',
      isDownloaded: true,
      isActive: true,
      sizeInMB: 4,
      downloadUrl: '',
    ),
    BibleVersion(
      id: 'niv',
      name: 'New International Version',
      shortName: 'NIV',
      language: 'English',
      description: 'Modern, accurate translation',
      year: '1978',
      sizeInMB: 4,
      downloadUrl: '',
    ),
    BibleVersion(
      id: 'nlt',
      name: 'New Living Translation',
      shortName: 'NLT',
      language: 'English',
      description: 'Easy-to-understand translation',
      year: '1996',
      sizeInMB: 4,
      downloadUrl: '',
    ),
    BibleVersion(
      id: 'esv',
      name: 'English Standard Version',
      shortName: 'ESV',
      language: 'English',
      description: 'Literal yet readable translation',
      year: '2001',
      sizeInMB: 4,
      downloadUrl: '',
    ),
    BibleVersion(
      id: 'nkjv',
      name: 'New King James Version',
      shortName: 'NKJV',
      language: 'English',
      description: 'Modern English with KJV accuracy',
      year: '1982',
      sizeInMB: 4,
      downloadUrl: '',
    ),
    BibleVersion(
      id: 'asv',
      name: 'American Standard Version',
      shortName: 'ASV',
      language: 'English',
      description: 'Literal translation',
      year: '1901',
      sizeInMB: 4,
      downloadUrl: '',
      isDownloaded: true,
    ),
  ];
}

class CrossReference {
  final String fromReference;
  final String toReference;
  final String relationshipType;
  final String? description;
  
  CrossReference({
    required this.fromReference,
    required this.toReference,
    required this.relationshipType,
    this.description,
  });
  
  factory CrossReference.fromJson(Map<String, dynamic> json) {
    return CrossReference(
      fromReference: json['fromReference'],
      toReference: json['toReference'],
      relationshipType: json['relationshipType'] ?? 'related',
      description: json['description'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'fromReference': fromReference,
      'toReference': toReference,
      'relationshipType': relationshipType,
      'description': description,
    };
  }
}

class VerseLabel {
  final String id;
  final String name;
  final int color;
  final DateTime createdAt;
  final List<String> verseReferences;
  
  VerseLabel({
    required this.id,
    required this.name,
    required this.color,
    required this.createdAt,
    List<String>? verseReferences,
  }) : verseReferences = verseReferences ?? [];
  
  factory VerseLabel.fromJson(Map<String, dynamic> json) {
    return VerseLabel(
      id: json['id'],
      name: json['name'],
      color: json['color'],
      createdAt: DateTime.parse(json['createdAt']),
      verseReferences: json['verseReferences'] != null
          ? List<String>.from(json['verseReferences'])
          : [],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'createdAt': createdAt.toIso8601String(),
      'verseReferences': verseReferences,
    };
  }
}

class NavigationHistory {
  final String id;
  final String reference;
  final DateTime timestamp;
  final String? bibleVersion;
  
  NavigationHistory({
    required this.id,
    required this.reference,
    required this.timestamp,
    this.bibleVersion,
  });
  
  factory NavigationHistory.fromJson(Map<String, dynamic> json) {
    return NavigationHistory(
      id: json['id'],
      reference: json['reference'],
      timestamp: DateTime.parse(json['timestamp']),
      bibleVersion: json['bibleVersion'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reference': reference,
      'timestamp': timestamp.toIso8601String(),
      'bibleVersion': bibleVersion,
    };
  }
}

