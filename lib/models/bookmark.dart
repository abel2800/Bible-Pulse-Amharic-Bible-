class Bookmark {
  final String id;
  final String verseReference;
  final String text;
  final DateTime createdAt;
  
  Bookmark({
    required this.id,
    required this.verseReference,
    required this.text,
    required this.createdAt,
  });
  
  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      id: json['id'] as String,
      verseReference: json['verseReference'] as String,
      text: json['text'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'verseReference': verseReference,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

