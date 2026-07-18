import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_capabilities.dart';
import '../providers/bible_provider.dart';
import '../providers/color_theme_provider.dart';
import '../providers/font_settings_provider.dart';
import '../providers/study_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/engagement_provider.dart';
import '../providers/parallel_reading_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/book_selector_bottom_sheet.dart';
import '../widgets/chapter_selector_sheet.dart';
import '../widgets/version_selector_bottom_sheet.dart';
import '../widgets/audio_player_bottom_sheet.dart';
import '../widgets/design/bp_widgets.dart';
import '../services/audio_service.dart';
import '../l10n/app_localizations.dart';
import '../widgets/verse_card.dart';

class BibleReaderScreen extends StatefulWidget {
  const BibleReaderScreen({super.key});

  @override
  State<BibleReaderScreen> createState() => _BibleReaderScreenState();
}

class _BibleReaderScreenState extends State<BibleReaderScreen> {
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _verseKeys = {};
  int? _parallelBook;
  int? _parallelChapter;
  int? _lastAudioVerse;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bibleProvider = Provider.of<BibleProvider>(context);
    final studyProvider = Provider.of<StudyProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final readerTheme = context.watch<ColorThemeProvider>().currentTheme;
    final fontSettings = context.watch<FontSettingsProvider>().fontSettings;
    final capabilities = context.watch<AppCapabilities>();
    final audioService = context.watch<AudioService>();
    final parallel = context.watch<ParallelReadingProvider>();
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inkSoft = isDark ? AppTheme.inkSoftDark : AppTheme.inkSoft;
    final showAudioBar = audioService.isPlaying ||
        audioService.isLoading ||
        audioService.duration > Duration.zero;

    if (bibleProvider.currentChapter.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.read<EngagementProvider>().recordReading();
      });
    }
    final selectedBook = bibleProvider.selectedBook;
    if (parallel.enabled &&
        selectedBook != null &&
        (_parallelBook != selectedBook.id ||
            _parallelChapter != bibleProvider.selectedChapter)) {
      _parallelBook = selectedBook.id;
      _parallelChapter = bibleProvider.selectedChapter;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        parallel.loadChapter(selectedBook.id, bibleProvider.selectedChapter);
      });
    }
    if (audioService.currentVerse != null &&
        audioService.currentVerse != _lastAudioVerse) {
      _lastAudioVerse = audioService.currentVerse;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final verseContext = _verseKeys[_lastAudioVerse]?.currentContext;
        if (verseContext != null) {
          Scrollable.ensureVisible(
            verseContext,
            duration: const Duration(milliseconds: 350),
            alignment: 0.35,
          );
        }
      });
    }

    return Scaffold(
      backgroundColor: readerTheme.backgroundColor,
      body: ColoredBox(
        color: readerTheme.backgroundColor,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: Row(
                  children: [
                    if (Navigator.of(context).canPop())
                      BpIconButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        tooltip: 'Back',
                        onPressed: () => Navigator.pop(context),
                      )
                    else
                      BpIconButton(
                        icon: Icons.menu_book_rounded,
                        tooltip: 'Browse books',
                        onPressed: () => _showBookSelector(context),
                      ),
                    const Spacer(),
                    if (parallel.available)
                      BpIconButton(
                        icon: parallel.enabled
                            ? Icons.view_column_rounded
                            : Icons.view_column_outlined,
                        tooltip: parallel.enabled
                            ? 'Disable Amharic parallel reading'
                            : 'Enable Amharic parallel reading',
                        onPressed: () => parallel.setEnabled(!parallel.enabled),
                      ),
                    if (parallel.available) const SizedBox(width: 8),
                    BpIconButton(
                      icon: Icons.volume_up_rounded,
                      tooltip: capabilities.audio
                          ? 'Play chapter audio'
                          : 'Audio is not configured',
                      onPressed: capabilities.audio
                          ? () => _playChapterAudio(context, bibleProvider)
                          : null,
                    ),
                    const SizedBox(width: 8),
                    PopupMenuButton<String>(
                      tooltip: 'Language',
                      offset: const Offset(0, 40),
                      child:
                          const _MenuIconButton(icon: Icons.translate_rounded),
                      onSelected: (value) async {
                        if (value == 'am') {
                          await themeProvider.setLocale(const Locale('am', ''));
                        } else {
                          await themeProvider.setLocale(const Locale('en', ''));
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'en', child: Text('English')),
                        PopupMenuItem(value: 'am', child: Text('Amharic')),
                      ],
                    ),
                    const SizedBox(width: 8),
                    BpIconButton(
                      icon: Icons.palette_outlined,
                      tooltip: 'Reading appearance',
                      onPressed: () => _showReadingAppearance(context),
                    ),
                    const SizedBox(width: 8),
                    BpIconButton(
                      icon: Icons.more_vert_rounded,
                      tooltip: 'More options',
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) =>
                              const VersionSelectorBottomSheet(),
                        );
                      },
                    ),
                  ],
                ),
              ),
              if (bibleProvider.selectedBook != null) ...[
                const SizedBox(height: 12),
                InkWell(
                  onTap: () => _showBookSelector(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              bibleProvider.selectedBook!.name,
                              textAlign: TextAlign.center,
                              style: AppTheme.brandTitle(
                                fontSize: 26,
                                weight: FontWeight.w700,
                                color: readerTheme.headerColor,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              Icons.expand_more_rounded,
                              size: 22,
                              color: readerTheme.headerColor
                                  .withValues(alpha: 0.7),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'WORLD ENGLISH BIBLE',
                          textAlign: TextAlign.center,
                          style: AppTheme.ui(
                            fontSize: 10,
                            weight: FontWeight.w700,
                            letterSpacing: 1.4,
                            color: inkSoft,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${l10n.chapter} ${bibleProvider.selectedChapter}',
                  textAlign: TextAlign.center,
                  style: AppTheme.ui(
                    fontSize: 12,
                    weight: FontWeight.w600,
                    color: AppTheme.gold,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      BpIconButton(
                        icon: Icons.chevron_left_rounded,
                        tooltip: 'Previous chapter',
                        onPressed: () => bibleProvider.previousChapter(),
                      ),
                      const SizedBox(width: 8),
                      Material(
                        color: isDark
                            ? AppTheme.surface2Dark
                            : AppTheme.surface2Light,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                          side: BorderSide(
                            color: isDark
                                ? AppTheme.borderDark
                                : AppTheme.borderLight,
                          ),
                        ),
                        child: InkWell(
                          onTap: () =>
                              _showChapterSelector(context, bibleProvider),
                          onLongPress: () => _showBookSelector(context),
                          borderRadius: BorderRadius.circular(999),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.menu_book_rounded,
                                  size: 16,
                                  color: AppTheme.gold,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${bibleProvider.selectedBook!.name} ${bibleProvider.selectedChapter}',
                                  style: AppTheme.ui(
                                    fontSize: 13,
                                    weight: FontWeight.w600,
                                    color: readerTheme.headerColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      BpIconButton(
                        icon: Icons.chevron_right_rounded,
                        tooltip: 'Next chapter',
                        onPressed: () => bibleProvider.nextChapter(),
                      ),
                    ],
                  ),
                ),
                const BpRule(),
              ],
              Expanded(
                child: bibleProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : bibleProvider.currentChapter.isEmpty
                        ? _buildEmptyState(context, bibleProvider, l10n)
                        : ListView.builder(
                            controller: _scrollController,
                            padding: EdgeInsets.fromLTRB(
                              20,
                              4,
                              20,
                              showAudioBar ? 100 : 24,
                            ),
                            itemCount: bibleProvider.currentChapter.length,
                            itemBuilder: (context, index) {
                              final verse = bibleProvider.currentChapter[index];
                              final reference =
                                  bibleProvider.getVerseReference(verse);
                              final isHighlighted =
                                  studyProvider.isHighlighted(reference);
                              final highlightColor =
                                  studyProvider.getHighlightColor(reference);
                              final isSpoken =
                                  audioService.currentVerse == verse.verse;
                              final secondary = parallel.enabled
                                  ? parallel.verse(verse.verse)
                                  : null;

                              return KeyedSubtree(
                                key: _verseKeys.putIfAbsent(
                                  verse.verse,
                                  GlobalKey.new,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    VerseCard(
                                      verse: verse,
                                      reference: reference,
                                      isHighlighted: isHighlighted,
                                      highlightColor: highlightColor,
                                      isBookmarked:
                                          studyProvider.isBookmarked(reference),
                                      hasNote: studyProvider
                                              .getNoteForVerse(reference) !=
                                          null,
                                      isDropCap: index == 0,
                                      isAudioActive: isSpoken,
                                      textColor: readerTheme.textColor,
                                      verseNumberColor:
                                          readerTheme.verseNumberColor,
                                      fontSize: fontSettings.fontSize,
                                      lineHeight: fontSettings.lineHeight,
                                    ),
                                    if (secondary != null) ...[
                                      const SizedBox(height: 6),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 26),
                                        child: Text(
                                          secondary.text,
                                          style: AppTheme.ethopic(
                                            fontSize: fontSettings.fontSize - 1,
                                            color: readerTheme.textColor
                                                .withValues(alpha: 0.85),
                                          ),
                                        ),
                                      ),
                                    ],
                                    if (index <
                                        bibleProvider.currentChapter.length - 1)
                                      const SizedBox(height: 4),
                                  ],
                                ),
                              );
                            },
                          ),
              ),
              if (showAudioBar)
                _FloatingAudioBar(
                  bookName: bibleProvider.selectedBook?.name ?? '',
                  chapter: bibleProvider.selectedChapter,
                  onExpand: () {
                    if (bibleProvider.selectedBook == null) return;
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (context) => AudioPlayerBottomSheet(
                        book: bibleProvider.selectedBook!,
                        chapter: bibleProvider.selectedChapter,
                        versionId: bibleProvider.currentVersion,
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _playChapterAudio(BuildContext context, BibleProvider bibleProvider) {
    if (bibleProvider.selectedBook == null) return;

    final audioService = Provider.of<AudioService>(context, listen: false);
    audioService.playChapter(
      bibleProvider.currentVersion,
      bibleProvider.selectedBook!.id,
      bibleProvider.selectedChapter,
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => AudioPlayerBottomSheet(
        book: bibleProvider.selectedBook!,
        chapter: bibleProvider.selectedChapter,
        versionId: bibleProvider.currentVersion,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bibleProvider = Provider.of<BibleProvider>(context, listen: false);
      final pending = bibleProvider.pendingScrollVerse;
      if (pending != null &&
          bibleProvider.pendingScrollBookId == bibleProvider.selectedBook?.id &&
          bibleProvider.pendingScrollChapter == bibleProvider.selectedChapter) {
        final index =
            bibleProvider.currentChapter.indexWhere((v) => v.verse == pending);
        if (index != -1) {
          final verseContext = _verseKeys[pending]?.currentContext;
          if (verseContext != null) {
            Scrollable.ensureVisible(
              verseContext,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              alignment: 0.15,
            );
          }
        }
        bibleProvider.clearPendingScroll();
      }
    });
  }

  Future<void> _showReadingAppearance(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(
                color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
              ),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  Text(
                    'Reading appearance',
                    style: AppTheme.brandTitle(
                      fontSize: 19,
                      weight: FontWeight.w600,
                      color: isDark ? AppTheme.inkDark : AppTheme.ink,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Consumer<ColorThemeProvider>(
                    builder: (context, provider, _) => Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: provider.availableThemes
                          .map(
                            (theme) => ChoiceChip(
                              selected: provider.currentTheme.id == theme.id,
                              avatar: CircleAvatar(
                                backgroundColor: theme.backgroundColor,
                              ),
                              label: Text(theme.name),
                              onSelected: (_) => provider.setTheme(theme.id),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Consumer<FontSettingsProvider>(
                    builder: (context, provider, _) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Text size · ${provider.fontSize.round()}',
                            style: AppTheme.ui(
                              fontSize: 14,
                              weight: FontWeight.w600,
                              color: isDark ? AppTheme.inkDark : AppTheme.ink,
                            ),
                          ),
                          Slider(
                            min: 14,
                            max: 30,
                            divisions: 16,
                            activeColor: AppTheme.gold,
                            value: provider.fontSize.clamp(14, 30).toDouble(),
                            label: provider.fontSize.round().toString(),
                            onChanged: provider.setFontSize,
                          ),
                          Text(
                            'Line spacing · ${provider.lineHeight.toStringAsFixed(1)}',
                            style: AppTheme.ui(
                              fontSize: 14,
                              weight: FontWeight.w600,
                              color: isDark ? AppTheme.inkDark : AppTheme.ink,
                            ),
                          ),
                          Slider(
                            min: 1.2,
                            max: 2,
                            divisions: 8,
                            activeColor: AppTheme.gold,
                            value: provider.lineHeight.clamp(1.2, 2).toDouble(),
                            onChanged: provider.setLineHeight,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    BibleProvider bibleProvider,
    AppLocalizations l10n,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_stories_rounded,
              size: 64,
              color: AppTheme.gold.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.chooseBookToRead,
              textAlign: TextAlign.center,
              style: AppTheme.brandTitle(
                fontSize: 22,
                weight: FontWeight.w700,
                color: isDark ? AppTheme.inkDark : AppTheme.ink,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 200,
              child: BpPrimaryButton(
                label: l10n.browseBooks,
                onPressed: () => showBookSelector(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBookSelector(BuildContext context) {
    showBookSelector(context);
  }

  Future<void> _showChapterSelector(
    BuildContext context,
    BibleProvider bibleProvider,
  ) async {
    final book = bibleProvider.selectedBook;
    if (book == null) return;
    final chosen = await showChapterSelector(
      context,
      book: book.name,
      chapterCount: book.chapters,
      current: bibleProvider.selectedChapter,
    );
    if (chosen != null) {
      await bibleProvider.loadChapter(book.id, chosen);
    }
  }
}

class _MenuIconButton extends StatelessWidget {
  const _MenuIconButton({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
        ),
      ),
      child: InkWell(
        onTap: null,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 34,
          height: 34,
          child: Icon(
            icon,
            size: 18,
            color: isDark ? AppTheme.inkSoftDark : AppTheme.inkSoft,
          ),
        ),
      ),
    );
  }
}

class _FloatingAudioBar extends StatelessWidget {
  const _FloatingAudioBar({
    required this.bookName,
    required this.chapter,
    required this.onExpand,
  });

  final String bookName;
  final int chapter;
  final VoidCallback onExpand;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final audioService = context.watch<AudioService>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Material(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        elevation: 0,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
          ),
        ),
        child: InkWell(
          onTap: onExpand,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Row(
              children: [
                _GoldPlayButton(
                  isPlaying: audioService.isPlaying,
                  isLoading: audioService.isLoading,
                  onPressed: () {
                    if (audioService.isPlaying) {
                      audioService.pause();
                    } else {
                      audioService.play();
                    }
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        bookName.isEmpty ? 'Audio' : '$bookName $chapter',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.ui(
                          fontSize: 13,
                          weight: FontWeight.w600,
                          color: isDark ? AppTheme.inkDark : AppTheme.ink,
                        ),
                      ),
                      const SizedBox(height: 6),
                      StreamBuilder<Duration>(
                        stream: audioService.positionStream,
                        builder: (context, snapshot) {
                          final position =
                              snapshot.data ?? audioService.position;
                          final duration = audioService.duration;
                          final progress = duration.inMilliseconds > 0
                              ? position.inMilliseconds /
                                  duration.inMilliseconds
                              : 0.0;
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: progress.clamp(0.0, 1.0),
                              minHeight: 4,
                              backgroundColor: isDark
                                  ? AppTheme.borderDark
                                  : AppTheme.borderLight,
                              color: AppTheme.gold,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.open_in_full_rounded,
                  size: 18,
                  color: isDark ? AppTheme.inkFaintDark : AppTheme.inkFaint,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GoldPlayButton extends StatelessWidget {
  const _GoldPlayButton({
    required this.isPlaying,
    required this.isLoading,
    required this.onPressed,
  });

  final bool isPlaying;
  final bool isLoading;
  final VoidCallback onPressed;

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
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 44,
            height: 44,
            child: isLoading
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.onGold,
                    ),
                  )
                : Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: AppTheme.onGold,
                    size: 26,
                  ),
          ),
        ),
      ),
    );
  }
}
