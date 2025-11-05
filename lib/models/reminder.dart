import 'package:flutter/material.dart';

class DevotionReminder {
  final String id;
  final String title;
  final String description;
  final TimeOfDay time;
  final List<int> daysOfWeek;
  final bool isEnabled;
  final String? sound;
  final bool vibrate;
  final DateTime createdAt;
  
  DevotionReminder({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.daysOfWeek,
    this.isEnabled = true,
    this.sound,
    this.vibrate = true,
    required this.createdAt,
  });
  
  factory DevotionReminder.fromJson(Map<String, dynamic> json) {
    return DevotionReminder(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      time: TimeOfDay(
        hour: json['hour'],
        minute: json['minute'],
      ),
      daysOfWeek: List<int>.from(json['daysOfWeek'] ?? [1, 2, 3, 4, 5, 6, 7]),
      isEnabled: json['isEnabled'] ?? true,
      sound: json['sound'],
      vibrate: json['vibrate'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'hour': time.hour,
      'minute': time.minute,
      'daysOfWeek': daysOfWeek,
      'isEnabled': isEnabled,
      'sound': sound,
      'vibrate': vibrate,
      'createdAt': createdAt.toIso8601String(),
    };
  }
  
  DevotionReminder copyWith({
    String? id,
    String? title,
    String? description,
    TimeOfDay? time,
    List<int>? daysOfWeek,
    bool? isEnabled,
    String? sound,
    bool? vibrate,
    DateTime? createdAt,
  }) {
    return DevotionReminder(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      time: time ?? this.time,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      isEnabled: isEnabled ?? this.isEnabled,
      sound: sound ?? this.sound,
      vibrate: vibrate ?? this.vibrate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
  
  String get formattedTime {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
  
  String get daysString {
    if (daysOfWeek.length == 7) return 'Every day';
    if (daysOfWeek.length == 5 && !daysOfWeek.contains(6) && !daysOfWeek.contains(7)) {
      return 'Weekdays';
    }
    if (daysOfWeek.length == 2 && daysOfWeek.contains(6) && daysOfWeek.contains(7)) {
      return 'Weekends';
    }
    
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return daysOfWeek.map((d) => dayNames[d - 1]).join(', ');
  }
  
  bool shouldTriggerToday() {
    final now = DateTime.now();
    final weekday = now.weekday;
    return isEnabled && daysOfWeek.contains(weekday);
  }
}

class PictureOfDay {
  final String id;
  final String imageUrl;
  final String verse;
  final String reference;
  final String date;
  final String? photographer;
  final String? location;
  
  PictureOfDay({
    required this.id,
    required this.imageUrl,
    required this.verse,
    required this.reference,
    required this.date,
    this.photographer,
    this.location,
  });
  
  factory PictureOfDay.fromJson(Map<String, dynamic> json) {
    return PictureOfDay(
      id: json['id'],
      imageUrl: json['imageUrl'],
      verse: json['verse'],
      reference: json['reference'],
      date: json['date'],
      photographer: json['photographer'],
      location: json['location'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'verse': verse,
      'reference': reference,
      'date': date,
      'photographer': photographer,
      'location': location,
    };
  }
}

