// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:html' as html;

/// HTMLAudioElement playback for Flutter web (basic play works without CORS).
abstract final class WebHtmlAudio {
  static bool get isSupported => true;

  static html.AudioElement? _audio;
  static Timer? _tick;
  static final _positionController = StreamController<Duration>.broadcast();
  static final _durationController = StreamController<Duration?>.broadcast();
  static final _playingController = StreamController<bool>.broadcast();

  static html.AudioElement get _element {
    return _audio ??= html.AudioElement()..preload = 'auto';
  }

  static Future<void> play(Uri uri) async {
    final audio = _element;
    _tick?.cancel();
    audio.pause();
    audio.src = uri.toString();
    audio.load();
    await audio.play();
    _playingController.add(true);
    _tick = Timer.periodic(const Duration(milliseconds: 250), (_) {
      _positionController.add(
        Duration(milliseconds: (audio.currentTime * 1000).round()),
      );
      final dur = audio.duration;
      if (dur.isFinite) {
        _durationController.add(
          Duration(milliseconds: (dur * 1000).round()),
        );
      }
      _playingController.add(!audio.paused);
    });
  }

  static Future<void> pause() async {
    _element.pause();
    _playingController.add(false);
  }

  static Future<void> stop() async {
    _tick?.cancel();
    _element.pause();
    _element.removeAttribute('src');
    _element.load();
    _playingController.add(false);
  }

  static Future<void> setSpeed(double speed) async {
    _element.playbackRate = speed;
  }

  static Stream<Duration> get positionStream => _positionController.stream;
  static Stream<Duration?> get durationStream => _durationController.stream;
  static Stream<bool> get playingStream => _playingController.stream;
}
