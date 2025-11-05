import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bible_version.dart';

class VersionManagerProvider extends ChangeNotifier {
  List<BibleVersion> _versions = [];
  String? _activeVersionId;
  bool _isLoading = false;
  String? _error;
  
  List<BibleVersion> get versions => _versions;
  List<BibleVersion> get downloadedVersions =>
      _versions.where((v) => v.isDownloaded).toList();
  List<BibleVersion> get availableVersions =>
      _versions.where((v) => !v.isDownloaded).toList();
  
  BibleVersion? get activeVersion {
    if (_activeVersionId == null) return null;
    try {
      return _versions.firstWhere((v) => v.id == _activeVersionId);
    } catch (e) {
      return null;
    }
  }
  
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> loadVersions() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _versions = BibleVersion.availableVersions;
      
      final prefs = await SharedPreferences.getInstance();
      _activeVersionId = prefs.getString('active_bible_version') ?? 'kjv';
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load versions: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> setActiveVersion(String versionId) async {
    try {
      final version = _versions.firstWhere((v) => v.id == versionId);
      
      if (!version.isDownloaded) {
        _error = 'Version not downloaded';
        notifyListeners();
        return;
      }
      
      _versions = _versions.map((v) {
        return v.copyWith(isActive: v.id == versionId);
      }).toList();
      
      _activeVersionId = versionId;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('active_bible_version', versionId);
      
      notifyListeners();
    } catch (e) {
      _error = 'Failed to set active version: $e';
      notifyListeners();
    }
  }
  
  Future<void> downloadVersion(String versionId) async {
    try {
      final index = _versions.indexWhere((v) => v.id == versionId);
      if (index == -1) return;
      
      _versions[index] = _versions[index].copyWith(isDownloaded: true);
      
      notifyListeners();
    } catch (e) {
      _error = 'Failed to download version: $e';
      notifyListeners();
    }
  }
  
  Future<void> deleteVersion(String versionId) async {
    try {
      if (versionId == _activeVersionId) {
        _error = 'Cannot delete active version';
        notifyListeners();
        return;
      }
      
      final index = _versions.indexWhere((v) => v.id == versionId);
      if (index == -1) return;
      
      _versions[index] = _versions[index].copyWith(isDownloaded: false, isActive: false);
      
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete version: $e';
      notifyListeners();
    }
  }
  
  BibleVersion? getVersionById(String id) {
    try {
      return _versions.firstWhere((v) => v.id == id);
    } catch (e) {
      return null;
    }
  }
  
  List<BibleVersion> getVersionsByLanguage(String language) {
    return _versions.where((v) => v.language == language).toList();
  }
  
  List<String> getAvailableLanguages() {
    final languages = <String>{};
    for (var version in _versions) {
      languages.add(version.language);
    }
    return languages.toList()..sort();
  }
}

