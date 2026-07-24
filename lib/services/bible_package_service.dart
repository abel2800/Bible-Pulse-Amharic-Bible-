import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/bible_package.dart';
import 'package_storage.dart';
import 'bible_package_io.dart' if (dart.library.html) 'bible_package_web.dart'
    as fs;

typedef DownloadProgressCallback = void Function(double progress);

class BiblePackageService {
  BiblePackageService({PackageStorage? storage})
      : _storage = storage ?? const CatalogUrlPackageStorage();

  final PackageStorage _storage;
  static const _registryKey = 'installed_bible_packages_v1';
  static const _catalogAsset = 'assets/catalog/bible_catalog.json';

  List<BiblePackageInfo> _catalog = [];
  final Map<String, InstalledBiblePackage> _installed = {};
  final Map<String, PackageDownloadProgress> _progress = {};

  List<BiblePackageInfo> get catalog => List.unmodifiable(_catalog);
  Map<String, InstalledBiblePackage> get installed =>
      Map.unmodifiable(_installed);
  Map<String, PackageDownloadProgress> get progress =>
      Map.unmodifiable(_progress);

  Future<void> initialize() async {
    await _loadCatalog();
    await _loadRegistry();
    await ensureBundledPackagesInstalled();
  }

  Future<void> _loadCatalog() async {
    final raw = await rootBundle.loadString(_catalogAsset);
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final packages = json['packages'] as List<dynamic>? ?? const [];
    _catalog = packages
        .map((e) =>
            BiblePackageInfo.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> _loadRegistry() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_registryKey);
    _installed.clear();
    if (raw == null || raw.isEmpty) return;
    final list = jsonDecode(raw) as List<dynamic>;
    for (final item in list) {
      final installed = InstalledBiblePackage.fromJson(
        Map<String, dynamic>.from(item as Map),
      );
      _installed[installed.packageId] = installed;
    }
  }

  Future<void> _saveRegistry() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _installed.values.map((e) => e.toJson()).toList();
    await prefs.setString(_registryKey, jsonEncode(list));
  }

  Future<void> ensureBundledPackagesInstalled() async {
    for (final pkg in _catalog) {
      // Only auto-install packages marked bundled (WEB). Optional asset
      // packs like KJV/ASV wait for an explicit Store install.
      if (pkg.install.type != 'asset' || !pkg.canInstall) continue;
      if (!pkg.category.contains('bundled')) continue;
      if (_installed.containsKey(pkg.id)) continue;
      await installPackage(pkg);
    }
  }

  bool isInstalled(String packageId) => _installed.containsKey(packageId);

  InstalledBiblePackage? installedByVersion(String versionId) {
    for (final item in _installed.values) {
      if (item.versionId == versionId) return item;
    }
    return null;
  }

  String? sourceForVersion(String versionId) {
    final installed = installedByVersion(versionId);
    if (installed == null) return null;
    return installed.localPath;
  }

  List<String> get installedVersionIds =>
      _installed.values.map((e) => e.versionId).toSet().toList()..sort();

  Future<void> installPackage(
    BiblePackageInfo pkg, {
    DownloadProgressCallback? onProgress,
  }) async {
    if (!pkg.canInstall) {
      throw StateError('Package ${pkg.id} is not legally installable');
    }
    if (kIsWeb && pkg.install.type == 'url') {
      throw UnsupportedError(
        'This translation must be installed from a bundled package on web. '
        'Try KJV or ASV from the Bible Store.',
      );
    }

    _progress[pkg.id] = PackageDownloadProgress(
      packageId: pkg.id,
      state: PackageDownloadState.downloading,
      progress: 0.05,
    );
    onProgress?.call(0.05);

    try {
      late final String outPath;
      late final int size;
      late final bool bundled;

      if (pkg.install.type == 'asset') {
        final assetPath = pkg.install.path!;
        if (kIsWeb) {
          outPath = 'asset:$assetPath';
          size = pkg.fileSizeBytes;
          bundled = true;
        } else {
          final raw = await rootBundle.loadString(assetPath);
          final bibleJson = jsonDecode(raw) as Map<String, dynamic>;
          outPath = await _writePackageFiles(pkg, bibleJson);
          size = await fs.fileLength(outPath);
          bundled = true;
        }
        _progress[pkg.id] = PackageDownloadProgress(
          packageId: pkg.id,
          state: PackageDownloadState.installing,
          progress: 0.8,
        );
        onProgress?.call(0.8);
      } else {
        final url = pkg.install.url!;
        final uri = await _storage.resolveBiblePackageUrl(pkg.id, url) ??
            Uri.parse(url);
        final response = await http.get(uri);
        if (response.statusCode < 200 || response.statusCode >= 300) {
          throw Exception('Download failed (${response.statusCode})');
        }
        _progress[pkg.id] = PackageDownloadProgress(
          packageId: pkg.id,
          state: PackageDownloadState.verifying,
          progress: 0.55,
        );
        onProgress?.call(0.55);
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        final bibleJson = _normalizeBibleJson(
          decoded,
          versionId: pkg.versionId,
          language: pkg.language,
          name: pkg.name,
        );
        outPath = await _writePackageFiles(pkg, bibleJson);
        size = await fs.fileLength(outPath);
        bundled = false;
      }

      _installed[pkg.id] = InstalledBiblePackage(
        packageId: pkg.id,
        versionId: pkg.versionId,
        language: pkg.language,
        localPath: outPath,
        installedAt: DateTime.now().toUtc().toIso8601String(),
        sizeBytes: size,
        bundled: bundled,
      );
      await _saveRegistry();

      _progress[pkg.id] = PackageDownloadProgress(
        packageId: pkg.id,
        state: PackageDownloadState.completed,
        progress: 1,
      );
      onProgress?.call(1);
    } catch (error) {
      _progress[pkg.id] = PackageDownloadProgress(
        packageId: pkg.id,
        state: PackageDownloadState.failed,
        progress: 0,
        error: error.toString(),
      );
      rethrow;
    }
  }

  Future<String> _writePackageFiles(
    BiblePackageInfo pkg,
    Map<String, dynamic> bibleJson,
  ) async {
    final support = await getApplicationSupportDirectory();
    final langDir = p.join(support.path, 'bibles', pkg.language);
    await fs.ensureDir(langDir);
    final outPath = p.join(langDir, '${pkg.versionId.toLowerCase()}.json');
    await fs.writeString(outPath, jsonEncode(bibleJson));
    final indexPath = p.join(langDir, '${pkg.versionId.toLowerCase()}.db.json');
    await fs.writeString(indexPath, jsonEncode(_verseIndex(bibleJson)));
    return outPath;
  }

  Future<void> uninstallPackage(String packageId) async {
    final installed = _installed[packageId];
    if (installed == null) return;
    if (installed.bundled) {
      throw StateError('Bundled packages cannot be removed');
    }
    _installed.remove(packageId);
    if (!installed.localPath.startsWith('asset:')) {
      await fs.deleteIfExists(installed.localPath);
      await fs.deleteIfExists(
        installed.localPath.replaceAll('.json', '.db.json'),
      );
    }
    await _saveRegistry();
    _progress.remove(packageId);
  }

  Future<int> totalStorageBytes() async {
    var total = 0;
    for (final item in _installed.values) {
      total += item.sizeBytes;
    }
    return total;
  }

  Map<String, dynamic> _normalizeBibleJson(
    dynamic decoded, {
    required String versionId,
    required String language,
    required String name,
  }) {
    if (decoded is Map<String, dynamic> && decoded['books'] is List) {
      return decoded;
    }

    if (decoded is List) {
      final byBook = <int, Map<String, dynamic>>{};
      for (final row in decoded) {
        if (row is! Map) continue;
        final map = Map<String, dynamic>.from(row);
        final bookId = (map['book'] as num?)?.toInt() ??
            (map['book_id'] as num?)?.toInt() ??
            0;
        if (bookId < 1) continue;
        final bookName =
            (map['book_name'] ?? map['bookName'] ?? 'Book $bookId').toString();
        final chapter = (map['chapter'] as num?)?.toInt() ?? 0;
        final verse = (map['verse'] as num?)?.toInt() ?? 0;
        final text = (map['text'] ?? map['verse_text'] ?? '').toString();
        if (chapter < 1 || verse < 1 || text.isEmpty) continue;

        final book = byBook.putIfAbsent(
          bookId,
          () => {
            'id': bookId,
            'name': bookName,
            'testament': bookId <= 39 ? 'OT' : 'NT',
            'chapters': <Map<String, dynamic>>[],
          },
        );
        final chapters = book['chapters'] as List<Map<String, dynamic>>;
        Map<String, dynamic>? chapterMap;
        for (final c in chapters) {
          if (c['number'] == chapter) {
            chapterMap = c;
            break;
          }
        }
        if (chapterMap == null) {
          chapterMap = {
            'number': chapter,
            'verses': <Map<String, dynamic>>[],
          };
          chapters.add(chapterMap);
        }
        (chapterMap['verses'] as List).add({'verse': verse, 'text': text});
      }

      final books = byBook.keys.toList()..sort();
      return {
        'schemaVersion': 1,
        'translation': {
          'id': versionId,
          'name': name,
          'language': language,
          'license': 'Public Domain',
        },
        'books': [
          for (final id in books) byBook[id]!,
        ],
      };
    }

    throw const FormatException('Unsupported Bible package JSON format');
  }

  Map<String, dynamic> _verseIndex(Map<String, dynamic> bibleJson) {
    final rows = <Map<String, dynamic>>[];
    final books = bibleJson['books'];
    if (books is! List) return {'verses': rows};
    for (var bi = 0; bi < books.length; bi++) {
      final book = books[bi] as Map<String, dynamic>;
      final bookId = (book['id'] as num?)?.toInt() ?? bi + 1;
      final chapters = book['chapters'];
      if (chapters is! List) continue;
      for (final chapterRaw in chapters) {
        final chapter = chapterRaw as Map<String, dynamic>;
        final chapterNum = (chapter['number'] as num?)?.toInt() ?? 0;
        final verses = chapter['verses'];
        if (verses is! List) continue;
        for (final verseRaw in verses) {
          final verse = verseRaw as Map<String, dynamic>;
          rows.add({
            'book': bookId,
            'chapter': chapterNum,
            'verse': (verse['verse'] as num?)?.toInt() ?? 0,
            'text': verse['text']?.toString() ?? '',
          });
        }
      }
    }
    return {'verses': rows};
  }
}
