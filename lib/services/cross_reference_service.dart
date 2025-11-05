import '../models/bible_version.dart';

class CrossReferenceService {
  static final CrossReferenceService _instance = CrossReferenceService._internal();
  factory CrossReferenceService() => _instance;
  CrossReferenceService._internal();
  
  final Map<String, List<CrossReference>> _crossReferences = {
    'Genesis 1:1': [
      CrossReference(
        fromReference: 'Genesis 1:1',
        toReference: 'John 1:1',
        relationshipType: 'parallel',
        description: 'Both speak of the beginning',
      ),
      CrossReference(
        fromReference: 'Genesis 1:1',
        toReference: 'Hebrews 11:3',
        relationshipType: 'quoted',
        description: 'Faith and creation',
      ),
    ],
    'John 3:16': [
      CrossReference(
        fromReference: 'John 3:16',
        toReference: 'Romans 5:8',
        relationshipType: 'parallel',
        description: 'God\'s love demonstrated',
      ),
      CrossReference(
        fromReference: 'John 3:16',
        toReference: '1 John 4:9',
        relationshipType: 'parallel',
        description: 'God\'s love through His Son',
      ),
    ],
    'Matthew 5:3': [
      CrossReference(
        fromReference: 'Matthew 5:3',
        toReference: 'Luke 6:20',
        relationshipType: 'parallel',
        description: 'Beatitudes in Luke',
      ),
      CrossReference(
        fromReference: 'Matthew 5:3',
        toReference: 'Isaiah 57:15',
        relationshipType: 'allusion',
        description: 'Poor in spirit',
      ),
    ],
  };
  
  List<CrossReference> getCrossReferences(String reference) {
    return _crossReferences[reference] ?? [];
  }
  
  bool hasCrossReferences(String reference) {
    return _crossReferences.containsKey(reference) &&
           _crossReferences[reference]!.isNotEmpty;
  }
  
  int getCrossReferenceCount(String reference) {
    return _crossReferences[reference]?.length ?? 0;
  }
  
  List<String> getAllReferencedVerses(String reference) {
    final refs = getCrossReferences(reference);
    return refs.map((r) => r.toReference).toList();
  }
  
  Future<List<CrossReference>> searchCrossReferences(String query) async {
    final lowerQuery = query.toLowerCase();
    final results = <CrossReference>[];
    
    for (var entry in _crossReferences.entries) {
      if (entry.key.toLowerCase().contains(lowerQuery)) {
        results.addAll(entry.value);
      }
    }
    
    return results;
  }
}

