import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/bible_version.dart';
import 'package:uuid/uuid.dart';

class LabelsProvider extends ChangeNotifier {
  final Uuid _uuid = const Uuid();
  List<VerseLabel> _labels = [];
  
  List<VerseLabel> get labels => _labels;
  
  Future<void> loadLabels() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final labelsJson = prefs.getString('verse_labels');
      
      if (labelsJson != null) {
        final List<dynamic> decoded = json.decode(labelsJson);
        _labels = decoded.map((l) => VerseLabel.fromJson(l)).toList();
        notifyListeners();
      } else {
        _createDefaultLabels();
      }
    } catch (e) {
      debugPrint('Error loading labels: $e');
    }
  }
  
  void _createDefaultLabels() {
    _labels = [
      VerseLabel(
        id: _uuid.v4(),
        name: 'Favorite',
        color: 0xFFFF5722,
        createdAt: DateTime.now(),
      ),
      VerseLabel(
        id: _uuid.v4(),
        name: 'Prayer',
        color: 0xFF9C27B0,
        createdAt: DateTime.now(),
      ),
      VerseLabel(
        id: _uuid.v4(),
        name: 'Promise',
        color: 0xFF4CAF50,
        createdAt: DateTime.now(),
      ),
      VerseLabel(
        id: _uuid.v4(),
        name: 'Wisdom',
        color: 0xFF2196F3,
        createdAt: DateTime.now(),
      ),
      VerseLabel(
        id: _uuid.v4(),
        name: 'Encouragement',
        color: 0xFFFFEB3B,
        createdAt: DateTime.now(),
      ),
    ];
    _saveLabels();
  }
  
  Future<void> addLabel(String name, int color) async {
    try {
      final label = VerseLabel(
        id: _uuid.v4(),
        name: name,
        color: color,
        createdAt: DateTime.now(),
      );
      
      _labels.add(label);
      await _saveLabels();
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding label: $e');
    }
  }
  
  Future<void> updateLabel(String id, String name, int color) async {
    try {
      final index = _labels.indexWhere((l) => l.id == id);
      if (index == -1) return;
      
      final oldLabel = _labels[index];
      _labels[index] = VerseLabel(
        id: oldLabel.id,
        name: name,
        color: color,
        createdAt: oldLabel.createdAt,
        verseReferences: oldLabel.verseReferences,
      );
      
      await _saveLabels();
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating label: $e');
    }
  }
  
  Future<void> deleteLabel(String id) async {
    try {
      _labels.removeWhere((l) => l.id == id);
      await _saveLabels();
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting label: $e');
    }
  }
  
  Future<void> addVerseToLabel(String labelId, String verseReference) async {
    try {
      final index = _labels.indexWhere((l) => l.id == labelId);
      if (index == -1) return;
      
      final label = _labels[index];
      if (!label.verseReferences.contains(verseReference)) {
        label.verseReferences.add(verseReference);
        await _saveLabels();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error adding verse to label: $e');
    }
  }
  
  Future<void> removeVerseFromLabel(String labelId, String verseReference) async {
    try {
      final index = _labels.indexWhere((l) => l.id == labelId);
      if (index == -1) return;
      
      final label = _labels[index];
      label.verseReferences.remove(verseReference);
      await _saveLabels();
      notifyListeners();
    } catch (e) {
      debugPrint('Error removing verse from label: $e');
    }
  }
  
  List<VerseLabel> getLabelsForVerse(String verseReference) {
    return _labels.where((l) => l.verseReferences.contains(verseReference)).toList();
  }
  
  List<String> getVersesForLabel(String labelId) {
    try {
      final label = _labels.firstWhere((l) => l.id == labelId);
      return label.verseReferences;
    } catch (e) {
      return [];
    }
  }
  
  Future<void> _saveLabels() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final labelsJson = json.encode(
        _labels.map((l) => l.toJson()).toList(),
      );
      await prefs.setString('verse_labels', labelsJson);
    } catch (e) {
      debugPrint('Error saving labels: $e');
    }
  }
}

