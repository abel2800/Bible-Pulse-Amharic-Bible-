class Note {
  final String id;
  final String verseReference;
  final String text;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  Note({
    required this.id,
    required this.verseReference,
    required this.text,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as String,
      verseReference: json['verseReference'] as String,
      text: json['text'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'verseReference': verseReference,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
  
  Note copyWith({
    String? id,
    String? verseReference,
    String? text,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id ?? this.id,
      verseReference: verseReference ?? this.verseReference,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

