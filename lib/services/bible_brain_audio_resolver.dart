import 'dart:convert';

import 'package:http/http.dart' as http;

import 'audio_contracts.dart';
import 'bible_brain_catalog_service.dart';

class BibleBrainAudioResolver
    implements AudioChapterResolver, AudioTimingResolver {
  BibleBrainAudioResolver({
    required this.apiKey,
    required this.versionBibleIds,
    required this.allowedMediaHosts,
    required this.catalog,
    http.Client? client,
    Uri? apiBase,
  })  : apiBase = apiBase ?? Uri.parse('https://4.dbt.io/api/'),
        _client = client ?? http.Client();

  final String apiKey;
  final Map<String, String> versionBibleIds;
  final Set<String> allowedMediaHosts;
  final BibleBrainCatalogGateway catalog;
  final http.Client _client;
  final Uri apiBase;

  static const _bookCodes = <String>[
    'GEN',
    'EXO',
    'LEV',
    'NUM',
    'DEU',
    'JOS',
    'JDG',
    'RUT',
    '1SA',
    '2SA',
    '1KI',
    '2KI',
    '1CH',
    '2CH',
    'EZR',
    'NEH',
    'EST',
    'JOB',
    'PSA',
    'PRO',
    'ECC',
    'SNG',
    'ISA',
    'JER',
    'LAM',
    'EZK',
    'DAN',
    'HOS',
    'JOL',
    'AMO',
    'OBA',
    'JON',
    'MIC',
    'NAM',
    'HAB',
    'ZEP',
    'HAG',
    'ZEC',
    'MAL',
    'MAT',
    'MRK',
    'LUK',
    'JHN',
    'ACT',
    'ROM',
    '1CO',
    '2CO',
    'GAL',
    'EPH',
    'PHP',
    'COL',
    '1TH',
    '2TH',
    '1TI',
    '2TI',
    'TIT',
    'PHM',
    'HEB',
    'JAS',
    '1PE',
    '2PE',
    '1JN',
    '2JN',
    '3JN',
    'JUD',
    'REV',
  ];

  @override
  Future<AudioChapterSource?> resolve({
    required String versionId,
    required int bookId,
    required int chapter,
  }) async {
    final bibleId = versionBibleIds[versionId];
    if (bibleId == null || bookId < 1 || bookId > _bookCodes.length) {
      return null;
    }
    final filesets = await catalog.audioFilesets(bibleId);
    if (filesets.isEmpty) return null;
    final fileset = filesets.first;
    final endpoint = apiBase.resolve(
      'bibles/filesets/${fileset.id}/${_bookCodes[bookId - 1]}/$chapter',
    );
    final uri = endpoint.replace(queryParameters: {'v': '4', 'key': apiKey});
    final response = await _client.get(uri);
    if (response.statusCode == 404) return null;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('Bible Brain returned ${response.statusCode}.');
    }
    final payload = jsonDecode(response.body);
    final mediaUri = _findHttpsMediaUri(payload);
    if (mediaUri == null || !allowedMediaHosts.contains(mediaUri.host)) {
      throw StateError('Bible Brain returned an unapproved media host.');
    }
    return AudioChapterSource(
      uri: mediaUri,
      filesetId: fileset.id,
      attribution: 'Audio provided by Faith Comes By Hearing / Bible Brain',
      downloadPermitted: fileset.downloadPermitted,
    );
  }

  @override
  Future<List<AudioVerseTiming>> resolveTimings({
    required String filesetId,
    required int bookId,
    required int chapter,
  }) {
    if (bookId < 1 || bookId > _bookCodes.length) {
      return Future.value(const []);
    }
    return catalog.chapterTimings(
      filesetId: filesetId,
      bookCode: _bookCodes[bookId - 1],
      chapter: chapter,
    );
  }

  Uri? _findHttpsMediaUri(Object? value) {
    if (value is String) {
      final uri = Uri.tryParse(value);
      return uri?.scheme == 'https' ? uri : null;
    }
    if (value is List) {
      for (final item in value) {
        final found = _findHttpsMediaUri(item);
        if (found != null) return found;
      }
    }
    if (value is Map) {
      const preferred = ['path', 'url', 'uri', 'cdn'];
      for (final key in preferred) {
        if (value.containsKey(key)) {
          final found = _findHttpsMediaUri(value[key]);
          if (found != null) return found;
        }
      }
      for (final item in value.values) {
        final found = _findHttpsMediaUri(item);
        if (found != null) return found;
      }
    }
    return null;
  }
}
