class Highlight {
  final String id;
  final String verseReference;
  final String text;
  final int color;
  final DateTime createdAt;
  
  Highlight({
    required this.id,
    required this.verseReference,
    required this.text,
    required this.color,
    required this.createdAt,
  });
  
  factory Highlight.fromJson(Map<String, dynamic> json) {
    return Highlight(
      id: json['id'] as String,
      verseReference: json['verseReference'] as String,
      text: json['text'] as String,
      color: json['color'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'verseReference': verseReference,
      'text': text,
      'color': color,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

