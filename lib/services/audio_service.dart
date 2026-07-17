import 'dart:async';

import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';

import 'audio_cache.dart';
import 'audio_contracts.dart';

class AudioService with ChangeNotifier {
  AudioService({
    bool enabled = false,
    this.resolver,
    AudioChapterCache? cache,
    this.maxCacheBytes = 512 * 1024 * 1024,
  })  : cache = cache ?? PersistentAudioChapterCache(),
        enabled = enabled && resolver != null {
    if (this.enabled) {
      _init();
    }
  }

  final bool enabled;
  final AudioChapterResolver? resolver;
  final AudioChapterCache cache;
  final int maxCacheBytes;
  final AudioPlayer _player = AudioPlayer();
  final List<StreamSubscription<dynamic>> _subscriptions = [];

  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  double _speed = 1.0;
  String? _lastError;
  String? _attribution;
  String? _filesetId;
  List<AudioVerseTiming> _verseTimings = const [];
  int? _currentVerse;

  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;
  Duration get duration => _duration;
  Duration get position => _position;
  double get speed => _speed;
  String? get lastError => _lastError;
  String? get attribution => _attribution;
  String? get filesetId => _filesetId;
  int? get currentVerse => _currentVerse;
  bool get hasVerseTimings => _verseTimings.isNotEmpty;
  Stream<Duration> get positionStream => _player.positionStream;

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());

    _subscriptions.add(_player.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      _isLoading = state.processingState == ProcessingState.loading ||
          state.processingState == ProcessingState.buffering;
      notifyListeners();
    }));

    _subscriptions.add(_player.durationStream.listen((d) {
      if (d != null) {
        _duration = d;
        notifyListeners();
      }
    }));

    _subscriptions.add(_player.positionStream.listen((p) {
      _position = p;
      _currentVerse = _verseAt(p);
      notifyListeners();
    }));
  }

  Future<void> playChapter(String version, int bookId, int chapter) async {
    if (!enabled) {
      _lastError =
          'Audio is unavailable until a licensed provider is configured.';
      notifyListeners();
      return;
    }
    try {
      _isLoading = true;
      _lastError = null;
      notifyListeners();

      final source = await resolver!.resolve(
        versionId: version,
        bookId: bookId,
        chapter: chapter,
      );
      if (source == null) {
        _lastError = 'No licensed audio is available for this chapter.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      if (source.uri.scheme != 'https') {
        throw StateError('Remote audio must use HTTPS.');
      }
      _attribution = source.attribution;
      _filesetId = source.filesetId;
      _verseTimings = const [];
      _currentVerse = null;
      final timingResolver = resolver;
      if (timingResolver is AudioTimingResolver) {
        try {
          _verseTimings =
              await (timingResolver as AudioTimingResolver).resolveTimings(
            filesetId: source.filesetId,
            bookId: bookId,
            chapter: chapter,
          );
        } catch (_) {
          _verseTimings = const [];
        }
      }
      final cacheKey = '$version/$bookId/$chapter';
      final cached = await cache.lookup(cacheKey, source);
      final playbackUri = cached ?? source.uri;
      await _player.setAudioSource(AudioSource.uri(playbackUri));
      await _player.play();
      if (cached == null && source.downloadPermitted) {
        unawaited(
          cache
              .prepare(cacheKey, source, maxBytes: maxCacheBytes)
              .catchError((_) => source.uri),
        );
      }
    } catch (e) {
      _lastError = 'Unable to play this chapter.';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> play() => _player.play();
  Future<void> pause() => _player.pause();
  Future<void> seek(Duration position) => _player.seek(position);

  Future<void> setSpeed(double speed) async {
    _speed = speed;
    await _player.setSpeed(speed);
    notifyListeners();
  }

  Future<int> cacheSizeBytes() => cache.sizeBytes();

  Future<void> clearCache() => cache.clear();

  int? _verseAt(Duration position) {
    AudioVerseTiming? active;
    for (final timing in _verseTimings) {
      if (timing.start > position) break;
      if (timing.end == null || timing.end! > position) active = timing;
    }
    return active?.verse;
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _player.dispose();
    super.dispose();
  }
}
