import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/audio_service.dart';
import '../models/bible_book.dart';
import '../providers/audio_download_provider.dart';
import '../utils/app_theme.dart';
import 'design/bp_widgets.dart';

class AudioPlayerBottomSheet extends StatelessWidget {
  final BibleBook book;
  final int chapter;
  final String versionId;

  const AudioPlayerBottomSheet({
    super.key,
    required this.book,
    required this.chapter,
    this.versionId = 'WEB',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<AudioService>(
      builder: (context, audioService, _) {
        final maxHeight = MediaQuery.sizeOf(context).height * 0.85;

        return Container(
          margin: const EdgeInsets.all(12),
          constraints: BoxConstraints(maxHeight: maxHeight),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
            ),
            boxShadow: List<BoxShadow>.from(AppTheme.cardShadow(isDark)),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color:
                          isDark ? AppTheme.borderDark : AppTheme.borderLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            book.name,
                            style: AppTheme.brandTitle(
                              fontSize: 20,
                              weight: FontWeight.w700,
                              color: isDark ? AppTheme.inkDark : AppTheme.ink,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Chapter $chapter · WORLD ENGLISH BIBLE',
                            style: AppTheme.ui(
                              fontSize: 11,
                              weight: FontWeight.w600,
                              letterSpacing: 0.6,
                              color: isDark
                                  ? AppTheme.inkSoftDark
                                  : AppTheme.inkSoft,
                            ),
                          ),
                          if (audioService.isLoading)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                'Loading…',
                                style: AppTheme.ui(
                                  fontSize: 11,
                                  color: AppTheme.gold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    BpIconButton(
                      icon: Icons.close_rounded,
                      tooltip: 'Close',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                StreamBuilder<Duration>(
                  stream: audioService.positionStream,
                  builder: (context, snapshot) {
                    final position = snapshot.data ?? Duration.zero;
                    final duration = audioService.duration;
                    final maxSeconds = duration.inSeconds > 0
                        ? duration.inSeconds.toDouble()
                        : 1.0;

                    return Column(
                      children: [
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: AppTheme.gold,
                            inactiveTrackColor: isDark
                                ? AppTheme.borderDark
                                : AppTheme.borderLight,
                            thumbColor: AppTheme.gold,
                            overlayColor: AppTheme.gold.withValues(alpha: 0.12),
                          ),
                          child: Slider(
                            value: position.inSeconds
                                .toDouble()
                                .clamp(0.0, maxSeconds),
                            max: maxSeconds,
                            onChanged: (value) {
                              audioService
                                  .seek(Duration(seconds: value.toInt()));
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(position),
                                style: AppTheme.ui(
                                  fontSize: 11,
                                  color: isDark
                                      ? AppTheme.inkSoftDark
                                      : AppTheme.inkSoft,
                                ),
                              ),
                              Text(
                                _formatDuration(duration),
                                style: AppTheme.ui(
                                  fontSize: 11,
                                  color: isDark
                                      ? AppTheme.inkSoftDark
                                      : AppTheme.inkSoft,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _SecondaryControl(
                      icon: Icons.replay_10_rounded,
                      onPressed: () {
                        if (audioService.position.inSeconds > 10) {
                          audioService.seek(
                            audioService.position - const Duration(seconds: 10),
                          );
                        } else {
                          audioService.seek(Duration.zero);
                        }
                      },
                    ),
                    const SizedBox(width: 20),
                    _GoldPlayButton(
                      isPlaying: audioService.isPlaying,
                      isLoading: audioService.isLoading,
                      size: 64,
                      iconSize: 32,
                      onPressed: () {
                        if (audioService.isPlaying) {
                          audioService.pause();
                        } else {
                          audioService.play();
                        }
                      },
                    ),
                    const SizedBox(width: 20),
                    _SecondaryControl(
                      icon: Icons.forward_30_rounded,
                      onPressed: () {
                        audioService.seek(
                          audioService.position + const Duration(seconds: 30),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    for (final rate in AudioService.preferredSpeeds)
                      ChoiceChip(
                        label: Text(
                          '${rate.toStringAsFixed(rate % 1 == 0 ? 0 : 2)}×',
                        ),
                        selected: (audioService.speed - rate).abs() < 0.01,
                        onSelected: (_) => audioService.setSpeed(rate),
                      ),
                  ],
                ),
                if (audioService.enabled) ...[
                  const SizedBox(height: 16),
                  Consumer<AudioDownloadProvider>(
                    builder: (context, downloads, _) => Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        OutlinedButton.icon(
                          onPressed: downloads.downloading
                              ? null
                              : () => downloads.downloadChapters(
                                    versionId: versionId,
                                    chapters: [
                                      (bookId: book.id, chapter: chapter),
                                    ],
                                  ),
                          icon: const Icon(Icons.download_rounded, size: 18),
                          label: const Text('Download chapter'),
                        ),
                        OutlinedButton.icon(
                          onPressed: downloads.downloading
                              ? null
                              : () => downloads.downloadBook(
                                    versionId: versionId,
                                    bookId: book.id,
                                    chapterCount: book.chapters,
                                  ),
                          icon: const Icon(Icons.library_add_rounded, size: 18),
                          label: const Text('Download book'),
                        ),
                      ],
                    ),
                  ),
                ],
                if (audioService.attribution != null) ...[
                  const SizedBox(height: 14),
                  Text(
                    audioService.attribution!,
                    style: AppTheme.ui(
                      fontSize: 10,
                      color: isDark ? AppTheme.inkFaintDark : AppTheme.inkFaint,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}

class _GoldPlayButton extends StatelessWidget {
  const _GoldPlayButton({
    required this.isPlaying,
    required this.isLoading,
    required this.onPressed,
    this.size = 64,
    this.iconSize = 32,
  });

  final bool isPlaying;
  final bool isLoading;
  final VoidCallback onPressed;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.goldSoft, AppTheme.gold],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x66C08A28),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: size,
            height: size,
            child: isLoading
                ? Padding(
                    padding: EdgeInsets.all(size * 0.28),
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppTheme.onGold,
                    ),
                  )
                : Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: AppTheme.onGold,
                    size: iconSize,
                  ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryControl extends StatelessWidget {
  const _SecondaryControl({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: isDark ? AppTheme.surface2Dark : AppTheme.surface2Light,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
        ),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            icon,
            size: 24,
            color: isDark ? AppTheme.inkSoftDark : AppTheme.inkSoft,
          ),
        ),
      ),
    );
  }
}
