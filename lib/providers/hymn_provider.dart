import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../models/hymn.dart';
import '../services/database_service.dart';

class HymnProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  
  List<Hymn> _hymns = [];
  List<String> _favoriteIds = [];
  String? _selectedCategory;
  String _searchQuery = '';
  
  bool _isLoading = false;
  String? _error;
  
  List<Hymn> get hymns => _getFilteredHymns();
  List<Hymn> get allHymns => _hymns;
  List<Hymn> get favoriteHymns => _hymns.where((h) => _favoriteIds.contains(h.id)).toList();
  
  String? get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  List<Hymn> _getFilteredHymns() {
    var filtered = _hymns;
    
    if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
      filtered = filtered.where((h) => h.category == _selectedCategory).toList();
    }
    
    if (_searchQuery.isNotEmpty) {
      final lowerQuery = _searchQuery.toLowerCase();
      filtered = filtered.where((h) {
        return h.title.toLowerCase().contains(lowerQuery) ||
            h.number.toLowerCase().contains(lowerQuery) ||
            (h.author?.toLowerCase().contains(lowerQuery) ?? false) ||
            h.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
      }).toList();
    }
    
    return filtered;
  }
  
  Future<void> loadHymns() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _hymns = _getSampleHymns();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load hymns: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
  
  List<Hymn> _getSampleHymns() {
    return [
      Hymn(
        id: '1',
        number: '1',
        title: 'Amazing Grace',
        verses: [
          'Amazing grace! How sweet the sound\nThat saved a wretch like me!\nI once was lost, but now am found;\nWas blind, but now I see.',
          '\'Twas grace that taught my heart to fear,\nAnd grace my fears relieved;\nHow precious did that grace appear\nThe hour I first believed.',
        ],
        author: 'John Newton',
        year: 1772,
        category: 'Worship & Praise',
        tags: ['grace', 'salvation'],
      ),
      Hymn(
        id: '2',
        number: '2',
        title: 'How Great Thou Art',
        verses: [
          'O Lord my God, When I in awesome wonder,\nConsider all the worlds Thy Hands have made;\nI see the stars, I hear the rolling thunder,\nThy power throughout the universe displayed.',
        ],
        chorus: 'Then sings my soul, My Saviour God, to Thee,\nHow great Thou art, How great Thou art.',
        author: 'Carl Boberg',
        year: 1885,
        category: 'Worship & Praise',
        tags: ['worship', 'creation'],
      ),
    ];
  }
  
  Future<void> toggleFavorite(String hymnId) async {
    try {
      if (_favoriteIds.contains(hymnId)) {
        _favoriteIds.remove(hymnId);
      } else {
        _favoriteIds.add(hymnId);
      }
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update favorite: $e';
      notifyListeners();
    }
  }
  
  bool isFavorite(String hymnId) {
    return _favoriteIds.contains(hymnId);
  }
  
  void setCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }
  
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
}

