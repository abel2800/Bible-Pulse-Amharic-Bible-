import 'dart:async';

import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'audio_cache.dart';
import 'audio_contracts.dart';
import 'web_html_audio_stub.dart'
    if (dart.library.html) 'web_html_audio_web.dart' as html_audio;

class AudioService with ChangeNotifier {
  AudioService({
    bool enabled = false,
    this.resolver,
    AudioChapterCache? cache,
    this.maxCacheBytes = 512 * 1024 * 1024,
  })  : cache = cache ?? PersistentAudioChapterCache(),
        enabled = enabled && resolver != null {
    if (this.enabled) {
      unawaited(_init());
    }
  }

  static const _speedPrefsKey = 'audio_playback_speed';
  static const preferredSpeeds = <double>[1.0, 1.25, 1.5, 1.75, 2.0];

  final bool enabled;
  final AudioChapterResolver? resolver;
  final AudioChapterCache cache;
  final int maxCacheBytes;
  final AudioPlayer _player = AudioPlayer();
  final List<StreamSubscription<dynamic>> _subscriptions = [];

  bool _useHtmlAudio = false;
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  double _speed = 1.25;
  String? _lastError;
  String? _attribution;
  String? _filesetId;
  List<AudioVerseTiming> _verseTimings = const [];
  int? _currentVerse;

  String? _activeVersion;
  int? _activeBookId;
  int? _activeChapter;
  String? _activeBookName;

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
  Stream<Duration> get positionStream => _useHtmlAudio
      ? html_audio.WebHtmlAudio.positionStream
      : _player.positionStream;

  bool get hasActiveSession => _activeBookId != null && _activeChapter != null;
  String? get activeVersion => _activeVersion;
  int? get activeBookId => _activeBookId;
  int? get activeChapter => _activeChapter;
  String? get activeBookName => _activeBookName;

  Future<void> _init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getDouble(_speedPrefsKey);
      if (saved != null && saved >= 0.8 && saved <= 2.5) {
        _speed = saved;
      }
    } catch (error) {
      debugPrint('Audio prefs unavailable: $error');
    }

    if (!kIsWeb) {
      try {
        final session = await AudioSession.instance;
        await session.configure(const AudioSessionConfiguration.music());
      } catch (error) {
        debugPrint('Audio session unavailable: $error');
      }
    }

    _subscriptions.add(_player.playerStateStream.listen((state) {
      if (_useHtmlAudio) return;
      _isPlaying = state.playing;
      _isLoading = state.processingState == ProcessingState.loading ||
          state.processingState == ProcessingState.buffering;
      notifyListeners();
    }));

    _subscriptions.add(_player.durationStream.listen((d) {
      if (_useHtmlAudio) return;
      if (d != null) {
        _duration = d;
        notifyListeners();
      }
    }));

    _subscriptions.add(_player.positionStream.listen((p) {
      if (_useHtmlAudio) return;
      _position = p;
      _currentVerse = _verseAt(p);
      notifyListeners();
    }));

    if (html_audio.WebHtmlAudio.isSupported) {
      _subscriptions
          .add(html_audio.WebHtmlAudio.playingStream.listen((playing) {
        if (!_useHtmlAudio) return;
        _isPlaying = playing;
        _isLoading = false;
        notifyListeners();
      }));
      _subscriptions
          .add(html_audio.WebHtmlAudio.durationStream.listen((duration) {
        if (!_useHtmlAudio || duration == null) return;
        _duration = duration;
        notifyListeners();
      }));
      _subscriptions
          .add(html_audio.WebHtmlAudio.positionStream.listen((position) {
        if (!_useHtmlAudio) return;
        _position = position;
        _currentVerse = _verseAt(position);
        notifyListeners();
      }));
    }

    try {
      await _player.setSpeed(_speed);
    } catch (_) {}
  }

  Future<void> playChapter(
    String version,
    int bookId,
    int chapter, {
    String? bookName,
  }) async {
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
        _lastError =
            'No audio for this chapter. Try WEB/KJV/ASV text, or another chapter.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      if (source.uri.scheme != 'https') {
        throw StateError('Remote audio must use HTTPS.');
      }
      debugPrint('Playing audio: ${source.uri}');
      _attribution = source.attribution;
      _filesetId = source.filesetId;
      _verseTimings = const [];
      _currentVerse = null;

      final rate = _speed.clamp(0.8, 2.5);
      _speed = rate;

      // On web, prefer HTML audio — eBible hosts often omit CORS headers,
      // which breaks just_audio's fetch path but still allow <audio> play.
      if (kIsWeb && html_audio.WebHtmlAudio.isSupported) {
        _useHtmlAudio = true;
        await html_audio.WebHtmlAudio.play(source.uri);
        await html_audio.WebHtmlAudio.setSpeed(rate);
      } else {
        _useHtmlAudio = false;
        final cacheKey = '$version/$bookId/$chapter';
        Uri playbackUri = source.uri;
        final cached = await cache.lookup(cacheKey, source);
        if (cached != null) playbackUri = cached;
        await _player.stop();
        await _player.setUrl(playbackUri.toString());
        await _player.setSpeed(rate);
        await _player.play();
        if (source.downloadPermitted) {
          unawaited(
            cache
                .prepare(cacheKey, source, maxBytes: maxCacheBytes)
                .catchError((_) => source.uri),
          );
        }
      }

      _activeVersion = version;
      _activeBookId = bookId;
      _activeChapter = chapter;
      _activeBookName = bookName;
      _isLoading = false;
      _isPlaying = true;
      notifyListeners();
    } catch (e, st) {
      debugPrint('Audio play failed: $e\n$st');
      _lastError = 'Unable to play this chapter. ($e)';
      _isLoading = false;
      _isPlaying = false;
      notifyListeners();
    }
  }

  Future<void> play() async {
    try {
      if (_useHtmlAudio) {
        // HTML element keeps the last src; resume via playChapter state.
        await html_audio.WebHtmlAudio.setSpeed(_speed.clamp(0.8, 2.5));
        if (_activeBookId != null &&
            _activeChapter != null &&
            _activeVersion != null) {
          final source = await resolver!.resolve(
            versionId: _activeVersion!,
            bookId: _activeBookId!,
            chapter: _activeChapter!,
          );
          if (source != null) {
            await html_audio.WebHtmlAudio.play(source.uri);
            await html_audio.WebHtmlAudio.setSpeed(_speed);
            return;
          }
        }
      }
      await _player.setSpeed(_speed.clamp(0.8, 2.5));
      await _player.play();
    } catch (e) {
      _lastError = 'Unable to resume audio. ($e)';
      notifyListeners();
    }
  }

  Future<void> pause() async {
    if (_useHtmlAudio) {
      await html_audio.WebHtmlAudio.pause();
      _isPlaying = false;
      notifyListeners();
      return;
    }
    await _player.pause();
  }

  Future<void> seek(Duration position) => _player.seek(position);

  Future<void> setSpeed(double speed) async {
    final rate = speed.clamp(0.8, 2.5);
    _speed = rate;
    if (_useHtmlAudio) {
      await html_audio.WebHtmlAudio.setSpeed(rate);
    } else {
      await _player.setSpeed(rate);
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_speedPrefsKey, rate);
  }

  Future<void> cycleSpeed() async {
    final current =
        preferredSpeeds.indexWhere((s) => (s - _speed).abs() < 0.01);
    final next = preferredSpeeds[(current + 1) % preferredSpeeds.length];
    await setSpeed(next);
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
    if (_useHtmlAudio) {
      unawaited(html_audio.WebHtmlAudio.stop());
    }
    _player.dispose();
    super.dispose();
  }
}
