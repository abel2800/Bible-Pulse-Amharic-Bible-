import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/devotional_author.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EnhancedVODService {
  static final EnhancedVODService _instance = EnhancedVODService._internal();
  factory EnhancedVODService() => _instance;
  EnhancedVODService._internal();
  
  List<EnhancedDevotional> _allDevotionals = [];
  EnhancedDevotional? _todaysVOD;
  
  Future<void> loadAllDevotionals() async {
    _allDevotionals = [];
    
    final authors = ['billygraham', 'charlesspurgeon', 'rickwarren', 'ourdailyjourney'];
    
    for (final authorId in authors) {
      try {
        final String jsonString = await rootBundle.loadString('assets/devotionals/$authorId.json');
        final List<dynamic> jsonData = json.decode(jsonString);
        
        for (var item in jsonData) {
          item['id'] = '${authorId}_${item['date']}';
          item['author']['id'] = authorId;
          
          final devotional = EnhancedDevotional.fromJson(item);
          _allDevotionals.add(devotional);
        }
      } catch (e) {
        print('Error loading devotionals from $authorId: $e');
      }
    }
  }
  
  Future<EnhancedDevotional?> getTodaysVOD({String? authorId}) async {
    if (_allDevotionals.isEmpty) {
      await loadAllDevotionals();
    }
    
    final now = DateTime.now();
    final todayDate = '${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    
    List<EnhancedDevotional> filteredDevotionals = _allDevotionals;
    if (authorId != null) {
      filteredDevotionals = _allDevotionals.where((d) => d.author.id == authorId).toList();
    }
    
    try {
      _todaysVOD = filteredDevotionals.firstWhere((d) => d.date == todayDate);
    } catch (e) {
      if (filteredDevotionals.isNotEmpty) {
        _todaysVOD = filteredDevotionals[now.day % filteredDevotionals.length];
      }
    }
    
    return _todaysVOD;
  }
  
  Future<EnhancedDevotional?> getDevotionalByDate(DateTime date, {String? authorId}) async {
    if (_allDevotionals.isEmpty) {
      await loadAllDevotionals();
    }
    
    final dateString = '${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
    
    List<EnhancedDevotional> filteredDevotionals = _allDevotionals;
    if (authorId != null) {
      filteredDevotionals = _allDevotionals.where((d) => d.author.id == authorId).toList();
    }
    
    try {
      return filteredDevotionals.firstWhere((d) => d.date == dateString);
    } catch (e) {
      return null;
    }
  }
  
  List<EnhancedDevotional> getDevotionalsByAuthor(String authorId) {
    return _allDevotionals.where((d) => d.author.id == authorId).toList();
  }
  
  Future<void> scheduleVODNotification() async {
    final vod = await getTodaysVOD();
    if (vod != null) {
    }
  }
  
  Future<String?> getPreferredAuthor() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('preferred_devotional_author');
  }
  
  Future<void> setPreferredAuthor(String? authorId) async {
    final prefs = await SharedPreferences.getInstance();
    if (authorId != null) {
      await prefs.setString('preferred_devotional_author', authorId);
    } else {
      await prefs.remove('preferred_devotional_author');
    }
  }
  
  List<String> getAvailableAuthors() {
    final authors = <String>{};
    for (var devotional in _allDevotionals) {
      authors.add(devotional.author.id);
    }
    return authors.toList();
  }
}

