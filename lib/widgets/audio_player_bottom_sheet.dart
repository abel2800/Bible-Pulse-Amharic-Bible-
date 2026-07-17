import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/audio_service.dart';
import '../models/bible_book.dart';
import '../providers/audio_download_provider.dart';

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
    return Consumer<AudioService>(
      builder: (context, audioService, _) {
        return Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${book.name} $chapter',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (audioService.isLoading)
                          const Text(
                            'Loading...',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              StreamBuilder<Duration>(
                stream: audioService.positionStream,
                builder: (context, snapshot) {
                  final position = snapshot.data ?? Duration.zero;
                  final duration = audioService.duration;

                  return Column(
                    children: [
                      Slider(
                        value: position.inSeconds
                            .toDouble()
                            .clamp(0.0, duration.inSeconds.toDouble()),
                        max: duration.inSeconds > 0
                            ? duration.inSeconds.toDouble()
                            : 1.0,
                        onChanged: (value) {
                          audioService.seek(Duration(seconds: value.toInt()));
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_formatDuration(position)),
                            Text(_formatDuration(duration)),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              if (audioService.enabled)
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
                        icon: const Icon(Icons.download_rounded),
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
                        icon: const Icon(Icons.library_add_rounded),
                        label: const Text('Download book'),
                      ),
                    ],
                  ),
                ),
              if (audioService.attribution != null) ...[
                const SizedBox(height: 12),
                Text(
                  audioService.attribution!,
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.replay_10),
                    iconSize: 32,
                    onPressed: () {
                      if (audioService.position.inSeconds > 10) {
                        audioService.seek(audioService.position -
                            const Duration(seconds: 10));
                      } else {
                        audioService.seek(Duration.zero);
                      }
                    },
                  ),
                  const SizedBox(width: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        audioService.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                      ),
                      iconSize: 48,
                      onPressed: () {
                        if (audioService.isPlaying) {
                          audioService.pause();
                        } else {
                          audioService.play();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.forward_30),
                    iconSize: 32,
                    onPressed: () {
                      audioService.seek(
                          audioService.position + const Duration(seconds: 30));
                    },
                  ),
                ],
              ),
            ],
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
