import 'package:flutter/material.dart';

class ReaderColorTheme {
  final String id;
  final String name;
  final Color backgroundColor;
  final Color textColor;
  final Color verseNumberColor;
  final Color headerColor;
  final bool isDark;

  const ReaderColorTheme({
    required this.id,
    required this.name,
    required this.backgroundColor,
    required this.textColor,
    required this.verseNumberColor,
    required this.headerColor,
    this.isDark = false,
  });

  factory ReaderColorTheme.fromJson(Map<String, dynamic> json) {
    return ReaderColorTheme(
      id: json['id'],
      name: json['name'],
      backgroundColor: Color(json['backgroundColor']),
      textColor: Color(json['textColor']),
      verseNumberColor: Color(json['verseNumberColor']),
      headerColor: Color(json['headerColor']),
      isDark: json['isDark'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'backgroundColor': backgroundColor.toARGB32(),
      'textColor': textColor.toARGB32(),
      'verseNumberColor': verseNumberColor.toARGB32(),
      'headerColor': headerColor.toARGB32(),
      'isDark': isDark,
    };
  }

  static List<ReaderColorTheme> get presets => [
        const ReaderColorTheme(
          id: 'light',
          name: 'Light',
          backgroundColor: Color(0xFFFFFFFF),
          textColor: Color(0xFF000000),
          verseNumberColor: Color(0xFF666666),
          headerColor: Color(0xFF333333),
          isDark: false,
        ),
        const ReaderColorTheme(
          id: 'sepia',
          name: 'Sepia',
          backgroundColor: Color(0xFFF4ECD8),
          textColor: Color(0xFF5C4A2E),
          verseNumberColor: Color(0xFF8B7355),
          headerColor: Color(0xFF3E2F1F),
          isDark: false,
        ),
        const ReaderColorTheme(
          id: 'dark',
          name: 'Dark',
          backgroundColor: Color(0xFF1E1E1E),
          textColor: Color(0xFFE0E0E0),
          verseNumberColor: Color(0xFFAAAAAA),
          headerColor: Color(0xFFCCCCCC),
          isDark: true,
        ),
        const ReaderColorTheme(
          id: 'black',
          name: 'True Black (AMOLED)',
          backgroundColor: Color(0xFF000000),
          textColor: Color(0xFFFFFFFF),
          verseNumberColor: Color(0xFFAAAAAA),
          headerColor: Color(0xFFDDDDDD),
          isDark: true,
        ),
        const ReaderColorTheme(
          id: 'blue_night',
          name: 'Blue Night',
          backgroundColor: Color(0xFF0D1B2A),
          textColor: Color(0xFFE0E1DD),
          verseNumberColor: Color(0xFF778DA9),
          headerColor: Color(0xFFB0C4DE),
          isDark: true,
        ),
        const ReaderColorTheme(
          id: 'forest',
          name: 'Forest',
          backgroundColor: Color(0xFF2C3E2C),
          textColor: Color(0xFFE8F5E9),
          verseNumberColor: Color(0xFFA5D6A7),
          headerColor: Color(0xFFC8E6C9),
          isDark: true,
        ),
      ];

  static ReaderColorTheme? getById(String id) {
    try {
      return presets.firstWhere((theme) => theme.id == id);
    } catch (e) {
      return null;
    }
  }
}
